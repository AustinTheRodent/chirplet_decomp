library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity symbol_expander is
  generic
  (
    G_DIN_WIDTH           : integer range 1 to 256;
    G_DOUT_OVER_DIN_WIDTH : integer range 1 to 256;
    G_FILL_LSBS_FIRST     : boolean := true
  );
  port
  (
    clk                   : in std_logic;
    reset                 : in std_logic;
    enable                : in std_logic;

    din                   : in  std_logic_vector(G_DIN_WIDTH-1 downto 0);
    din_valid             : in  std_logic;
    din_ready             : out std_logic;
    din_last              : in  std_logic;

    dout                  : out std_logic_vector(G_DIN_WIDTH*G_DOUT_OVER_DIN_WIDTH-1 downto 0);
    dout_valid            : out std_logic;
    dout_ready            : in  std_logic;
    dout_last             : out std_logic
  );
end entity;

architecture rtl of symbol_expander is

  signal din_ready_int  : std_logic;
  signal dout_valid_int : std_logic;
  signal dout_last_int  : std_logic;

  signal din_last_flag  : std_logic;

  type state_t is (init, construct_sym, output);
  signal state : state_t;

  signal registered_output  : std_logic_vector(G_DIN_WIDTH*G_DOUT_OVER_DIN_WIDTH-1 downto 0);
  signal symbol_counter : integer range 0 to 255;

begin

  dout        <= registered_output;

  din_ready   <= din_ready_int;
  dout_valid  <= dout_valid_int;
  dout_last   <= dout_last_int;

  din_ready_int <=
    '1' when state = construct_sym else
    dout_ready when state = output else
    '0';

  dout_valid_int <=
    '1' when state = output else
    '0';

  dout_last_int <=
    '1' when state = output and dout_valid_int = '1' and dout_ready = '1' and din_last_flag = '1' else
    '0';

  p_din_last_flag : process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' or enable = '0' then
        din_last_flag   <= '0';
      else
        if din_last_flag = '1' and dout_valid_int = '1' and dout_ready = '1' and dout_last_int = '1' then
          din_last_flag <= '0';
        elsif din_valid = '1' and din_ready_int = '1' and din_last = '1' then
          din_last_flag <= '1';
        end if;
      end if;
    end if;
  end process;

  p_state_machine : process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' or enable = '0' then
        registered_output <= (others => '0');
        symbol_counter    <= 0;
        state             <= init;
      else
        case state is
          when init =>
            registered_output <= (others => '0');
            symbol_counter    <= 0;
            state             <= construct_sym;
          when construct_sym =>
            if din_valid = '1' and din_ready_int = '1' then

              if G_FILL_LSBS_FIRST = true then
                registered_output(G_DIN_WIDTH*(symbol_counter+1)-1 downto G_DIN_WIDTH*symbol_counter) <= din;
              else
                registered_output(G_DIN_WIDTH*(G_DOUT_OVER_DIN_WIDTH-symbol_counter)-1 downto G_DIN_WIDTH*(G_DOUT_OVER_DIN_WIDTH-(symbol_counter+1))) <= din;
              end if;

              if symbol_counter = G_DOUT_OVER_DIN_WIDTH-1 then
                symbol_counter  <= 0;
                state           <= output;
              else
                symbol_counter  <= symbol_counter + 1;
              end if;
            end if;

          when output =>
            if dout_valid_int = '1' and dout_ready = '1' then
              if din_valid = '1' and din_ready_int = '1' then

                if G_FILL_LSBS_FIRST = true then
                  registered_output(G_DIN_WIDTH-1 downto 0) <= din;
                else
                  registered_output(G_DIN_WIDTH*G_DOUT_OVER_DIN_WIDTH-1 downto G_DIN_WIDTH*(G_DOUT_OVER_DIN_WIDTH-1)) <= din;
                end if;

                symbol_counter <= 1;

              end if;
              state <= construct_sym;
            end if;

          when others =>
            state <= init;
        end case;
      end if;
    end if;
  end process;

end rtl;
