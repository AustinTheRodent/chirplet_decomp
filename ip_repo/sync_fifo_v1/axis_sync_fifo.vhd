library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity axis_sync_fifo is
  generic
  (
    G_ADDR_WIDTH    : integer range 2 to 32;
    G_DATA_WIDTH    : integer range 1 to 1024;
    G_BUFFER_INPUT  : boolean := false;
    G_BUFFER_OUTPUT : boolean := false
  );
  port
  (
    clk             : in  std_logic;
    reset           : in  std_logic;
    enable          : in  std_logic;

    din             : in  std_logic_vector(G_DATA_WIDTH-1 downto 0);
    din_valid       : in  std_logic;
    din_ready       : out std_logic;
    din_last        : in  std_logic;

    dout            : out std_logic_vector(G_DATA_WIDTH-1 downto 0);
    dout_valid      : out std_logic;
    dout_ready      : in  std_logic;
    dout_last       : out std_logic
  );
end entity;

architecture rtl of axis_sync_fifo is

  signal din_buff_din         : std_logic_vector(G_DATA_WIDTH-1 downto 0);
  signal din_buff_din_valid   : std_logic;
  signal din_buff_din_ready   : std_logic;
  signal din_buff_din_last    : std_logic;
  signal din_buff_dout        : std_logic_vector(G_DATA_WIDTH-1 downto 0);
  signal din_buff_dout_valid  : std_logic;
  signal din_buff_dout_ready  : std_logic;
  signal din_buff_dout_last   : std_logic;

  signal dout_buff_din        : std_logic_vector(G_DATA_WIDTH-1 downto 0);
  signal dout_buff_din_valid  : std_logic;
  signal dout_buff_din_ready  : std_logic;
  signal dout_buff_din_last   : std_logic;
  signal dout_buff_dout       : std_logic_vector(G_DATA_WIDTH-1 downto 0);
  signal dout_buff_dout_valid : std_logic;
  signal dout_buff_dout_ready : std_logic;
  signal dout_buff_dout_last  : std_logic;

  signal internal_reset       : std_logic;

  type state_t is (init, pull_fifo, use_fifo, use_buffer);
  signal state                : state_t;
  signal dout_buffer          : std_logic_vector(G_DATA_WIDTH-1 downto 0);

  signal core_full            : std_logic;
  signal core_empty           : std_logic;
  signal core_count           : std_logic_vector(G_ADDR_WIDTH-1 downto 0);
  signal core_din             : std_logic_vector(G_DATA_WIDTH-1 downto 0);
  signal core_dout            : std_logic_vector(G_DATA_WIDTH-1 downto 0);
  signal core_din_accepted    : std_logic;
  signal core_re              : std_logic;

  signal last_flag            : std_logic;

begin

  din_buff_din        <= din;
  din_buff_din_valid  <= din_valid;
  din_ready           <= din_buff_din_ready;
  din_buff_din_last   <= din_last;

  g_buffer_din : if G_BUFFER_INPUT = true generate
    u_din_buff : entity work.axis_buffer
      generic map
      (
        G_DWIDTH    => G_DATA_WIDTH
      )
      port map
      (
        clk         => clk,
        reset       => internal_reset,
        enable      => '1',

        din         => din_buff_din,
        din_valid   => din_buff_din_valid,
        din_ready   => din_buff_din_ready,
        din_last    => din_buff_din_last,

        dout        => din_buff_dout,
        dout_valid  => din_buff_dout_valid,
        dout_ready  => din_buff_dout_ready,
        dout_last   => din_buff_dout_last
      );
  end generate;

  g_no_buffer_din : if G_BUFFER_INPUT = false generate
    din_buff_dout       <= din_buff_din;
    din_buff_dout_valid <= din_buff_din_valid;
    din_buff_din_ready  <= din_buff_dout_ready;
    din_buff_dout_last  <= din_buff_din_last;
  end generate;

  din_buff_dout_ready <= not core_full;

  dout_buff_din <=
    core_dout when state = use_fifo else
    dout_buffer;

  dout_buff_din_valid <=
    '1' when (state = use_fifo) or (state = use_buffer) else
    '0';

  dout_buff_din_last <=
    '1' when dout_buff_din_valid = '1' and dout_buff_din_ready = '1' and last_flag = '1' and unsigned(core_count) = 0 else
    '0';

  internal_reset <= reset or (not enable);

  core_din <= din_buff_dout;
  core_din_accepted <= din_buff_dout_valid and din_buff_dout_ready;

  core_re <=
    '1' when state = pull_fifo  and core_empty = '0' else
    '1' when state = use_fifo   and core_empty = '0' and dout_buff_din_ready = '1' else
    '1' when state = use_buffer and core_empty = '0' and dout_buff_din_ready = '1' else
    '0';

  u_fifo_core : entity work.sync_fifo
    generic map
    (
      G_ADDR_WIDTH  => G_ADDR_WIDTH,
      G_DATA_WIDTH  => G_DATA_WIDTH
    )
    port map
    (
      clk           => clk,
      rst           => internal_reset,

      data_in       => core_din,
      data_out      => core_dout,

      we            => core_din_accepted,
      re            => core_re,

      full          => core_full,
      empty         => core_empty,
      count         => core_count
    );

  p_last_flag : process(clk)
  begin
    if rising_edge(clk) then
      if internal_reset = '1' then
        last_flag <= '0';
      else
        if core_din_accepted = '1' and din_buff_dout_last = '1' then
          last_flag <= '1';
        elsif dout_buff_din_last = '1' then
          last_flag <= '0';
        end if;
      end if;
    end if;
  end process;

  p_state_machine : process(clk)
  begin
    if rising_edge(clk) then
      if internal_reset = '1' then
        dout_buffer <= (others => '0');
        state       <= init;
      else
        case state is
          when init =>
            dout_buffer <= (others => '0');
            state       <= pull_fifo;

          when pull_fifo =>
            if core_empty = '0' then
              state <= use_fifo;
            end if;

          when use_fifo =>
            if dout_buff_din_ready = '0' then
              dout_buffer <= core_dout;
              state       <= use_buffer;
            elsif dout_buff_din_ready = '1' and core_empty = '1' then
              state       <= pull_fifo;
            end if;

          when use_buffer =>
            if dout_buff_din_ready = '1' and core_empty = '1' then
              state <= pull_fifo;
            elsif dout_buff_din_ready = '1' and core_empty = '0' then
              state <= use_fifo;
            end if;

          when others =>
            state <= init;

        end case;
      end if;
    end if;
  end process;

  g_buffer_dout : if G_BUFFER_OUTPUT = true generate
    u_dout_buff : entity work.axis_buffer
      generic map
      (
        G_DWIDTH    => G_DATA_WIDTH
      )
      port map
      (
        clk         => clk,
        reset       => internal_reset,
        enable      => '1',

        din         => dout_buff_din,
        din_valid   => dout_buff_din_valid,
        din_ready   => dout_buff_din_ready,
        din_last    => dout_buff_din_last,

        dout        => dout_buff_dout,
        dout_valid  => dout_buff_dout_valid,
        dout_ready  => dout_buff_dout_ready,
        dout_last   => dout_buff_dout_last
      );
  end generate;

  g_no_buffer_dout : if G_BUFFER_OUTPUT = false generate
    dout_buff_dout        <= dout_buff_din;
    dout_buff_dout_valid  <= dout_buff_din_valid;
    dout_buff_din_ready   <= dout_buff_dout_ready;
    dout_buff_dout_last   <= dout_buff_din_last;
  end generate;

  dout                  <= dout_buff_dout;
  dout_valid            <= dout_buff_dout_valid;
  dout_buff_dout_ready  <= dout_ready;
  dout_last             <= dout_buff_dout_last;

end rtl;
