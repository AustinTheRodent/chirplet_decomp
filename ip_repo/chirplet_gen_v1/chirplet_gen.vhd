library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity chirplet_gen is
  port
  (
    clk             : in std_logic;
    reset           : in std_logic;
    enable          : in std_logic;

    din             : in  std_logic_vector(G_AWIDTH-1 downto 0);
    din_valid       : in  std_logic;
    din_ready       : out std_logic;
    din_last        : in  std_logic;

    dout            : out std_logic_vector(G_DWIDTH-1 downto 0);
    dout_valid      : out std_logic;
    dout_ready      : in  std_logic;
    dout_last       : out std_logic
  );
end entity;

architecture rtl of chirplet_gen is

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

  component bram is
    generic
    (
      G_DATA_WIDTH  : integer := 8;
      G_ADDR_WIDTH  : integer := 8
    );
    port
    (
      clk           : in  std_logic;
      address       : in  std_logic_vector(G_ADDR_WIDTH-1 downto 0);
      we            : in  std_logic;
      data_in       : in  std_logic_vector(G_DATA_WIDTH-1 downto 0);
      data_out      : out std_logic_vector(G_DATA_WIDTH-1 downto 0)
    );
  end component;

  signal din_ready_int          : std_logic;
  signal dout_int               : std_logic_vector(G_DWIDTH-1 downto 0);
  signal dout_valid_int         : std_logic;
  signal dout_last_int          : std_logic;
  signal din_accepted           : std_logic;
  signal dout_accepted          : std_logic;
  signal dout_last_hold         : std_logic;

  signal buff_enable            : std_logic;

  signal input_buff_din         : std_logic_vector(G_AWIDTH-1 downto 0);
  signal input_buff_din_valid   : std_logic;
  signal input_buff_din_ready   : std_logic;
  signal input_buff_din_last    : std_logic;
  signal input_buff_dout        : std_logic_vector(G_AWIDTH-1 downto 0);
  signal input_buff_dout_valid  : std_logic;
  signal input_buff_dout_ready  : std_logic;
  signal input_buff_dout_last   : std_logic;

  signal output_buff_din        : std_logic_vector(G_DWIDTH-1 downto 0);
  signal output_buff_din_valid  : std_logic;
  signal output_buff_din_ready  : std_logic;
  signal output_buff_din_last   : std_logic;
  signal output_buff_dout       : std_logic_vector(G_DWIDTH-1 downto 0);
  signal output_buff_dout_valid : std_logic;
  signal output_buff_dout_ready : std_logic;
  signal output_buff_dout_last  : std_logic;

  type state_t is (init, use_buffer_wait, use_buffer_go, use_bram_dout);
  signal state : state_t;

  signal bram_buffer            : std_logic_vector(G_DWIDTH-1 downto 0);

  signal bram_rd_addr           : std_logic_vector(G_AWIDTH-1 downto 0);
  signal bram_wr_addr           : std_logic_vector(G_AWIDTH-1 downto 0);
  signal bram_addr              : std_logic_vector(G_AWIDTH-1 downto 0);
  signal bram_dout              : std_logic_vector(G_DWIDTH-1 downto 0);

begin

  input_buff_din        <= din;
  input_buff_din_valid  <= din_valid;
  din_ready_int         <= input_buff_din_ready;
  input_buff_din_last   <= din_last;

  g_buff_in : if G_BUFFER_INPUT = true generate
    u_buff_in : axis_buffer
      generic map
      (
        G_DWIDTH    => G_AWIDTH
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

  buff_enable   <= enable and prog_done;

  input_buff_dout_ready <=
    '0' when prog_done = '0' else
    '1' when state = init else
    '1' when state = use_bram_dout and output_buff_din_ready = '1' else
    '1' when (state = use_buffer_wait or state = use_buffer_go) and output_buff_din_ready = '1' else
    '0';

  output_buff_din_valid <=
    '0' when state = init else
    '1';

  output_buff_din_last <=
    '1' when dout_accepted = '1' and dout_last_hold = '1' else
    '0';

  output_buff_din <=
    bram_dout when state = use_bram_dout else
    bram_buffer;

  p_din_last_hold : process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' or enable = '0' or prog_done = '0' then
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
      if reset = '1' or enable = '0' or prog_done = '0' then
        bram_buffer <= (others => '0');
        state       <= init;
      else
        case state is
          when init =>
            if din_accepted = '1' then
              state <= use_bram_dout;
            end if;
          when use_bram_dout =>
            if din_accepted = '0' and dout_accepted = '0' then
              bram_buffer <= bram_dout;
              state       <= use_buffer_wait;
            elsif din_accepted = '1' and dout_accepted = '0' then
              bram_buffer <= bram_dout;
              state       <= use_buffer_go;
            elsif din_accepted = '0' and dout_accepted = '1' then
              state       <= init;
            end if;
          when use_buffer_wait =>
            if din_accepted = '0' and dout_accepted = '1' then
              state <= init;
            elsif din_accepted = '1' and dout_accepted = '1' then
              state <= use_bram_dout;
            elsif din_accepted = '1' and dout_accepted = '0' then
              state <= use_buffer_go;
            end if;
          when use_buffer_go =>
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

  bram_rd_addr  <= input_buff_dout;
  bram_wr_addr  <= prog_addr;
  bram_addr     <= bram_wr_addr when prog_en = '1' else bram_rd_addr;

  u_bram : bram
    generic map
    (
      G_DATA_WIDTH  => G_DWIDTH,
      G_ADDR_WIDTH  => G_AWIDTH
    )
    port map
    (
      clk           => clk,
      address       => bram_addr,
      we            => prog_en,
      data_in       => prog_data,
      data_out      => bram_dout
    );

  g_buff_out : if G_BUFFER_OUTPUT = true generate
    u_buff_out : axis_buffer
      generic map
      (
        G_DWIDTH    => G_DWIDTH
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
 
   dout_int               <= output_buff_dout;
   dout_valid_int         <= output_buff_dout_valid;
   output_buff_dout_ready <= dout_ready;
   dout_last_int          <= output_buff_dout_last;

  din_ready               <= din_ready_int;
  dout                    <= dout_int;
  dout_valid              <= dout_valid_int;
  dout_last               <= dout_last_int;

end rtl;

