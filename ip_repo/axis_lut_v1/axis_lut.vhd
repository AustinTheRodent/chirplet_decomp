library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity axis_lut is
  generic
  (
    G_AWIDTH    : integer range 1 to 24 := 16;
    G_DWIDTH    : integer range 1 to 64 := 16
  );
  port
  (
    clk         : in std_logic;
    reset       : in std_logic;
    enable      : in std_logic;

    prog_data   : in  std_logic_vector(G_DWIDTH-1 downto 0);
    prog_addr   : in  std_logic_vector(G_AWIDTH-1 downto 0);
    prog_en     : in  std_logic;
    prog_done   : in  std_logic;

    din         : in  std_logic_vector(G_AWIDTH-1 downto 0);
    din_valid   : in  std_logic;
    din_ready   : out std_logic;
    din_last    : in  std_logic;
    dout        : out std_logic_vector(G_DWIDTH-1 downto 0);
    dout_valid  : out std_logic;
    dout_ready  : in  std_logic;
    dout_last   : out std_logic
  );
end entity;

architecture rtl of axis_lut is

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

    signal din_ready_int  : std_logic;
    signal dout_int       : std_logic_vector(G_DWIDTH-1 downto 0);
    signal dout_valid_int : std_logic;
    signal dout_last_int  : std_logic;
    signal din_accepted   : std_logic;
    signal dout_accepted  : std_logic;

    type state_t is (init, use_buffer_wait, use_buffer_go, use_bram_dout, done);
    signal state : state_t;

    signal bram_buffer    : std_logic_vector(G_DWIDTH-1 downto 0);

    signal bram_rd_addr   : std_logic_vector(G_AWIDTH-1 downto 0);
    signal bram_wr_addr   : std_logic_vector(G_AWIDTH-1 downto 0);
    signal bram_addr      : std_logic_vector(G_AWIDTH-1 downto 0);
    signal bram_dout      : std_logic_vector(G_DWIDTH-1 downto 0);

begin

  din_accepted  <= din_valid and din_ready_int;
  dout_accepted <= dout_valid_int and dout_ready;

  din_ready_int <=
    '1' when state = init else
    '1' when state = use_bram_dout and dout_ready = '1' else
    '1' when (state = use_buffer_wait or state = use_buffer_go) and dout_ready = '1' else
    '0';

  dout_valid_int <=
    '0' when state = init else
    '1';

  dout_int <=
    bram_dout when state = use_bram_dout else
    bram_buffer;

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
          when done =>
            state <= init;
          when others =>
            state <= init;
        end case;
      end if;
    end if;
  end process;

  bram_rd_addr  <= din;
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

  din_ready   <= din_ready_int;
  dout        <= dout_int;
  dout_valid  <= dout_valid_int;
  dout_last   <= dout_last_int;

end rtl;

