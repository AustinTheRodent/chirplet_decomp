library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dual_port_ram is
  generic
  (
    G_ADDR_WIDTH  : integer range 1 to 32  := 4;
    G_DATA_WIDTH  : integer range 1 to 256 := 8
  );
  port
  (
    clk           : in  std_logic;

    wr_addr       : in  std_logic_vector(G_ADDR_WIDTH-1 downto 0);
    wr_data       : in  std_logic_vector(G_DATA_WIDTH-1 downto 0);
    we            : in  std_logic;

    rd_addr       : in  std_logic_vector(G_ADDR_WIDTH-1 downto 0);
    rd_data       : out std_logic_vector(G_DATA_WIDTH-1 downto 0);
    re            : in  std_logic
  );
end entity;

architecture rtl of dual_port_ram is

	-- Build a 2-D array type for the RAM
	subtype word_t is std_logic_vector(G_DATA_WIDTH-1 downto 0);
	type memory_t is array(2**G_ADDR_WIDTH-1 downto 0) of word_t;

	-- Declare the RAM signal.	
	signal ram : memory_t;

begin

	p_write : process(clk)
	begin
    if rising_edge(clk) then 
      if we = '1' then
        ram(to_integer(unsigned(wr_addr))) <= wr_data;
      end if;
    end if;
	end process;

	p_read : process(clk)
	begin
    if rising_edge(clk) then 
      if re = '1' then
        rd_data <= ram(to_integer(unsigned(rd_addr)));
      end if;
    end if;
	end process;

end rtl;
