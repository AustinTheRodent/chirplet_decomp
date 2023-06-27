library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sine_lut is
  generic
  (
    G_BUFFER_INPUT  : boolean               := false;
    G_BUFFER_OUTPUT : boolean               := false;
    G_ADDR_WIDTH    : integer range 4 to 18 := 16
  );
  port
  (
    clk             : in std_logic;
    reset           : in std_logic;
    enable          : in std_logic;

    din             : in  std_logic_vector((G_ADDR_WIDTH-1) downto 0);
    din_valid       : in  std_logic;
    din_ready       : out std_logic;
    din_last        : in  std_logic;

    dout            : out std_logic_vector(31 downto 0);
    dout_valid      : out std_logic;
    dout_ready      : in  std_logic;
    dout_last       : out std_logic
  );
end entity;

architecture rtl of sine_lut is

  component axis_buffer is
    generic
    (
      G_DWIDTH    : integer := 8
    );
    port
    (
      clk         : in  std_logic;
      reset       : in  std_logic;
      enable      : in  std_logic;

      din         : in  std_logic_vector(G_DWIDTH-1 downto 0);
      din_valid   : in  std_logic;
      din_ready   : out std_logic;
      din_last    : in  std_logic;

      dout        : out std_logic_vector(G_DWIDTH-1 downto 0);
      dout_valid  : out std_logic;
      dout_ready  : in  std_logic;
      dout_last   : out std_logic
    );
  end component;

  component sine_rom is
    generic
    (
      G_DATA_WIDTH  : integer := 32;
      G_ADDR_WIDTH  : integer := 14
    );
    port
    (
      clk           : in  std_logic;
      address       : in  std_logic_vector(G_ADDR_WIDTH-1 downto 0);
      data_out      : out std_logic_vector(G_DATA_WIDTH-1 downto 0)
    );
  end component;

  signal din_adjusted           : std_logic_vector((G_ADDR_WIDTH-2) downto 0);
  signal pi_m_theta             : std_logic_vector((G_ADDR_WIDTH-1) downto 0);
  signal theta_m_pi             : std_logic_vector((G_ADDR_WIDTH-1) downto 0);
  signal twopi_m_theta          : std_logic_vector((G_ADDR_WIDTH-1) downto 0);
  signal invert_output          : std_logic;
  signal invert_output_delay    : std_logic;

  signal din_ready_int          : std_logic;
  signal dout_int               : std_logic_vector(31 downto 0);
  signal dout_valid_int         : std_logic;
  signal dout_last_int          : std_logic;
  signal din_accepted           : std_logic;
  signal dout_accepted          : std_logic;
  signal dout_last_hold         : std_logic;

  signal buff_enable            : std_logic;

  signal input_buff_din         : std_logic_vector((G_ADDR_WIDTH-1) downto 0);
  signal input_buff_din_valid   : std_logic;
  signal input_buff_din_ready   : std_logic;
  signal input_buff_din_last    : std_logic;
  signal input_buff_dout        : std_logic_vector((G_ADDR_WIDTH-1) downto 0);
  signal input_buff_dout_valid  : std_logic;
  signal input_buff_dout_ready  : std_logic;
  signal input_buff_dout_last   : std_logic;

  signal output_buff_din        : std_logic_vector(31 downto 0);
  signal output_buff_din_valid  : std_logic;
  signal output_buff_din_ready  : std_logic;
  signal output_buff_din_last   : std_logic;
  signal output_buff_dout       : std_logic_vector(31 downto 0);
  signal output_buff_dout_valid : std_logic;
  signal output_buff_dout_ready : std_logic;
  signal output_buff_dout_last  : std_logic;

  type state_t is (init, use_buffer, use_bram_dout);
  signal state : state_t;

  signal bram_buffer            : std_logic_vector(31 downto 0);

  signal bram_rd_addr           : std_logic_vector((G_ADDR_WIDTH-3) downto 0);
  signal bram_addr              : std_logic_vector((G_ADDR_WIDTH-3) downto 0);
  signal bram_dout              : std_logic_vector(31 downto 0);
  signal bram_adjusted          : std_logic_vector(31 downto 0);

  signal unity_out              : std_logic;

begin

  input_buff_din        <= din;
  input_buff_din_valid  <= din_valid;
  din_ready_int         <= input_buff_din_ready;
  input_buff_din_last   <= din_last;

  g_buff_in : if G_BUFFER_INPUT = true generate
    u_buff_in : axis_buffer
      generic map
      (
        G_DWIDTH    => G_ADDR_WIDTH
      )
      port map
      (
        clk         => clk,
        reset       => reset,
        enable      => buff_enable,

        din         => input_buff_din,
        din_valid   => input_buff_din_valid,
        din_ready   => input_buff_din_ready,
        din_last    => input_buff_din_last,

        dout        => input_buff_dout,
        dout_valid  => input_buff_dout_valid,
        dout_ready  => input_buff_dout_ready,
        dout_last   => input_buff_dout_last
      );
  end generate;

  g_no_buff_in : if G_BUFFER_INPUT = false generate

    input_buff_dout       <= input_buff_din;
    input_buff_dout_valid <= input_buff_din_valid;
    input_buff_din_ready  <= input_buff_dout_ready;
    input_buff_dout_last  <= input_buff_din_last;

  end generate;

  din_accepted  <= input_buff_dout_valid and input_buff_dout_ready;
  dout_accepted <= output_buff_din_valid and output_buff_din_ready;

  buff_enable   <= enable;

  input_buff_dout_ready <=
    '1' when state = init else
    '1' when state = use_bram_dout and output_buff_din_ready = '1' else
    '1' when state = use_buffer and output_buff_din_ready = '1' else
    '0';

  output_buff_din_valid <=
    '0' when state = init else
    '1';

  output_buff_din_last <=
    '1' when dout_accepted = '1' and dout_last_hold = '1' else
    '0';

  output_buff_din <=
    bram_adjusted when state = use_bram_dout else
    bram_buffer;

  p_din_last_hold : process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' or enable = '0' then
        dout_last_hold <= '0';
      else
        if din_accepted = '1' and input_buff_dout_last = '1' and dout_last_hold = '0' then
          dout_last_hold <= '1';
        elsif dout_accepted = '1' and output_buff_din_last = '1' and dout_last_hold = '1' then
          dout_last_hold <= '0';
        end if;
      end if;
    end if;
  end process;

  p_state_machine : process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' or enable = '0' then
        bram_buffer <= (others => '0');
        state       <= init;
      else
        case state is
          when init =>
            if din_accepted = '1' then
              state <= use_bram_dout;
            end if;
          when use_bram_dout =>
            if dout_accepted = '0' then
              bram_buffer <= bram_adjusted;
              state       <= use_buffer;
            elsif din_accepted = '0' and dout_accepted = '1' then
              state       <= init;
            end if;
          when use_buffer =>
            if din_accepted = '0' and dout_accepted = '1' then
              state <= init;
            elsif din_accepted = '1' and dout_accepted = '1' then
              state <= use_bram_dout;
            end if;
          when others =>
            state <= init;
        end case;
      end if;
    end if;
  end process;

  pi_m_theta    <= std_logic_vector(to_unsigned(2**(G_ADDR_WIDTH-1), G_ADDR_WIDTH) - unsigned(input_buff_dout));
  theta_m_pi    <= std_logic_vector(unsigned(input_buff_dout) - to_unsigned(2**(G_ADDR_WIDTH-1), G_ADDR_WIDTH));
  twopi_m_theta <= std_logic_vector(to_unsigned(0, G_ADDR_WIDTH) - unsigned(input_buff_dout));

  din_adjusted <=
    input_buff_dout((G_ADDR_WIDTH-2) downto 0)  when input_buff_dout((G_ADDR_WIDTH-1) downto (G_ADDR_WIDTH-2)) = "00" else
    pi_m_theta((G_ADDR_WIDTH-2) downto 0)       when input_buff_dout((G_ADDR_WIDTH-1) downto (G_ADDR_WIDTH-2)) = "01" else
    theta_m_pi((G_ADDR_WIDTH-2) downto 0)       when input_buff_dout((G_ADDR_WIDTH-1) downto (G_ADDR_WIDTH-2)) = "10" else
    twopi_m_theta((G_ADDR_WIDTH-2) downto 0);


  --bram_rd_addr  <= input_buff_dout;
  bram_rd_addr  <=
    --(others => '1') when din_adjusted((G_ADDR_WIDTH-2)) = '1' else
    din_adjusted((G_ADDR_WIDTH-3) downto 0);
  bram_addr     <= bram_rd_addr;

  invert_output <=
    '0' when input_buff_dout((G_ADDR_WIDTH-1) downto (G_ADDR_WIDTH-2)) = "00" else
    '0' when input_buff_dout((G_ADDR_WIDTH-1) downto (G_ADDR_WIDTH-2)) = "01" else
    '1' when input_buff_dout((G_ADDR_WIDTH-1) downto (G_ADDR_WIDTH-2)) = "01" else
    '1';

  p_delay_outputs : process(clk)
  begin
    if rising_edge(clk) then
      invert_output_delay <= invert_output;
      unity_out           <= din_adjusted((G_ADDR_WIDTH-2));
    end if;
  end process;

  u_bram : sine_rom
    generic map
    (
      G_DATA_WIDTH  => 32, -- floating point
      G_ADDR_WIDTH  => G_ADDR_WIDTH-2
    )
    port map
    (
      clk           => clk,
      address       => bram_addr,
      data_out      => bram_dout
    );

  bram_adjusted <=
    invert_output_delay & "011" & x"F800000" when unity_out = '1' else
    invert_output_delay & bram_dout(30 downto 0);

  g_buff_out : if G_BUFFER_OUTPUT = true generate
    u_buff_out : axis_buffer
      generic map
      (
        G_DWIDTH    => 32
      )
      port map
      (
        clk         => clk,
        reset       => reset,
        enable      => buff_enable,

        din         => output_buff_din,
        din_valid   => output_buff_din_valid,
        din_ready   => output_buff_din_ready,
        din_last    => output_buff_din_last,

        dout        => output_buff_dout,
        dout_valid  => output_buff_dout_valid,
        dout_ready  => output_buff_dout_ready,
        dout_last   => output_buff_dout_last
      );
  end generate;

  g_no_buff_out : if G_BUFFER_OUTPUT = false generate

    output_buff_dout        <= output_buff_din;
    output_buff_dout_valid  <= output_buff_din_valid;
    output_buff_din_ready   <= output_buff_dout_ready;
    output_buff_dout_last   <= output_buff_din_last;

  end generate;

  dout_int                <= output_buff_dout;
  dout_valid_int          <= output_buff_dout_valid;
  output_buff_dout_ready  <= dout_ready;
  dout_last_int           <= output_buff_dout_last;

  din_ready               <= din_ready_int;
  dout                    <= dout_int;
  dout_valid              <= dout_valid_int;
  dout_last               <= dout_last_int;

end rtl;

