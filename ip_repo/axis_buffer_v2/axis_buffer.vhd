library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity axis_buffer is
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
end entity;

architecture rtl of axis_buffer is

  type state_t is (init, wait_for_din_valid, wait_for_dout_ready, pass_thru);
  signal state : state_t;

  signal din_buffer_reg   : std_logic_vector(G_DWIDTH-1 downto 0);
  signal din_store        : std_logic_vector(G_DWIDTH-1 downto 0);
  signal last_buffer_reg  : std_logic;
  signal last_store       : std_logic;

  signal din_ready_int    : std_logic;
  signal dout_valid_int   : std_logic;

  signal din_go           : std_logic;
  signal dout_go          : std_logic;

begin

  din_ready   <= din_ready_int;
  dout_valid  <= dout_valid_int;
  dout        <= din_buffer_reg;
  dout_last   <= last_buffer_reg;

  din_go  <= din_valid and din_ready_int;
  dout_go <= dout_valid_int and dout_ready;

  p_state_machine : process(clk)
  begin
    if rising_edge(clk) then
        if reset = '1' or enable = '0' then
          state           <= init;
          din_buffer_reg  <= (others => '0');
          last_buffer_reg <= '0';
          din_store       <= (others => '0');
          din_ready_int   <= '0';
          dout_valid_int  <= '0';
        else
          case(state) is
            when init =>
              state           <= wait_for_din_valid;
              din_ready_int   <= '1';
              dout_valid_int  <= '0';
              din_buffer_reg  <= (others => '0');
              last_buffer_reg <= '0';
              din_store       <= (others => '0');
            when wait_for_din_valid =>
              if din_go = '1' then
                din_buffer_reg  <= din;
                last_buffer_reg <= din_last;
                dout_valid_int  <= '1';
                state           <= pass_thru;
              end if;
            when wait_for_dout_ready =>
              if dout_go = '1' then
                din_ready_int   <= '1';
                din_buffer_reg  <= din_store;
                last_buffer_reg <= last_store;
                state           <= pass_thru;
              end if;
            when pass_thru =>
              if din_go = '1' and dout_go = '1' then
                din_buffer_reg  <= din;
                last_buffer_reg <= din_last;
              elsif din_go = '0' and dout_go = '1' then
                din_ready_int   <= '1';
                dout_valid_int  <= '0';
                state <= wait_for_din_valid;
              elsif din_go = '1' and dout_go = '0' then
                din_ready_int   <= '0';
                dout_valid_int  <= '1';
                din_store       <= din;
                last_store      <= din_last;
                state           <= wait_for_dout_ready;
              end if;
            when others =>
              state <= init;
          end case;
        end if;
    end if;
  end process;

end rtl;
