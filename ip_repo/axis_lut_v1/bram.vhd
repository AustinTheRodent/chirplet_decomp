library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bram is
  generic
  (
    G_DATA_WIDTH  : integer range 1 to 64 := 8;
    G_ADDR_WIDTH  : integer range 1 to 24 := 8
  );
  port
  (
    clk           : in  std_logic;
    address       : in  std_logic_vector(G_ADDR_WIDTH-1 downto 0);
    we            : in  std_logic;
    data_in       : in  std_logic_vector(G_DATA_WIDTH-1 downto 0);
    data_out      : out std_logic_vector(G_DATA_WIDTH-1 downto 0)
  );
end entity;

architecture rtl of bram is
  constant RAM_DEPTH :integer := 2**G_ADDR_WIDTH;
  type RAM is array (integer range <>)of std_logic_vector (G_DATA_WIDTH-1 downto 0);
  signal mem : RAM (0 to RAM_DEPTH-1);
begin

  p_mem_write : process (clk) begin
    if (rising_edge(clk)) then
      if we = '1' then
        mem(to_integer(unsigned(address))) <= data_in;
      end if;
    end if;
  end process;

  p_mem_read : process (clk) begin
    if rising_edge(clk) then
      if we = '0' then
         data_out <= mem(to_integer(unsigned(address)));
      end if;
    end if;
  end process;

end architecture;
