library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity symbol_decomp is
  generic
  (
    G_DIN_WIDTH           : integer range 1 to 256;
    G_DIN_OVER_DOUT_WIDTH : integer range 1 to 256;
    G_READ_LSBS_FIRST     : boolean := true
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

    dout                  : out std_logic_vector(G_DIN_WIDTH/G_DIN_OVER_DOUT_WIDTH-1 downto 0);
    dout_valid            : out std_logic;
    dout_ready            : in  std_logic;
    dout_last             : out std_logic
  );
end entity;

architecture rtl of symbol_decomp is

  signal din_ready_int      : std_logic;
  signal dout_valid_int     : std_logic;
  signal dout_last_int      : std_logic;

  signal din_last_flag      : std_logic;

  type state_t is (init, get_sym, deconstruct_sym);
  signal state              : state_t;

  signal registered_input   : std_logic_vector(G_DIN_WIDTH-1 downto 0);
  signal symbol_counter     : integer range 0 to 255;

  signal dout_lsbs          : std_logic_vector(dout'range);
  signal dout_msbs          : std_logic_vector(dout'range);

begin

  --dout        <= registered_output;
  g_lsbs_first : if G_READ_LSBS_FIRST = true generate
    --g_lsbs_count : for i in 0 to G_DIN_OVER_DOUT_WIDTH-1 generate
      dout <= registered_input((symbol_counter+1)*dout'length-1 downto symbol_counter*dout'length);
    --end generate;
  end generate;

  g_msbs_first : if G_READ_LSBS_FIRST = false generate
    --g_msbs_count : for i in 0 to G_DIN_OVER_DOUT_WIDTH-1 generate
      dout <= registered_input(registered_input'length-dout'length*symbol_counter-1 downto registered_input'length-dout'length*(symbol_counter+1));
    --end generate;
  end generate;

  --dout <=
  --  dout_lsbs when G_READ_LSBS_FIRST = true else
  --  dout_msbs;

  din_ready   <= din_ready_int;
  dout_valid  <= dout_valid_int;
  dout_last   <= dout_last_int;

  din_ready_int <=
    '1' when state = get_sym else
    '1' when state = deconstruct_sym and symbol_counter = G_DIN_OVER_DOUT_WIDTH-1 and dout_ready = '1' else
    '0';

  dout_valid_int <=
    '1' when state = deconstruct_sym else
    '0';

  dout_last_int <=
    '1' when dout_valid_int = '1' and dout_ready = '1' and din_last_flag = '1' and symbol_counter = G_DIN_OVER_DOUT_WIDTH-1 else
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
        registered_input  <= (others => '0');
        symbol_counter    <= 0;
        state             <= init;
      else
        case state is
          when init =>
            registered_input  <= (others => '0');
            symbol_counter    <= 0;
            state             <= get_sym;

          when get_sym =>
            if din_valid = '1' and din_ready_int = '1' then
              registered_input  <= din;
              state             <= deconstruct_sym;
              symbol_counter    <= 0;
            end if;

          when deconstruct_sym =>
            if dout_valid_int = '1' and dout_ready = '1' then
              if symbol_counter = G_DIN_OVER_DOUT_WIDTH-1 then
                symbol_counter      <= 0;
                if din_valid = '1' and din_ready_int = '1' then
                  registered_input  <= din;
                else
                  state             <= get_sym;
                end if;
              else
                symbol_counter      <= symbol_counter + 1;
              end if;
            end if;

          when others =>
            state <= init;
        end case;
      end if;
    end if;
  end process;

end rtl;
