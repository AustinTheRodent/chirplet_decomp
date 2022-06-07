


fout = open("sine_rom.vhd", "w")
line = """
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sine_rom is
  port
  (
    clk       : in  std_logic;
    address   : in  std_logic_vector(15 downto 0);
    data_out  : out std_logic_vector(31 downto 0)
  );
end entity;

architecture rtl of sine_rom is

  constant C_DATA_WIDTH  : integer := 32;
  constant C_ADDR_WIDTH  : integer := 16;

  constant RAM_DEPTH :integer := 2**C_ADDR_WIDTH;

  type RAM is array (integer range <>) of std_logic_vector (C_DATA_WIDTH-1 downto 0);
  signal mem : RAM (0 to RAM_DEPTH-1) :=
  (
"""
fout.write(line)
f_rom = open("sine_rom.txt")
for line in f_rom:
  fout.write("    x\"")
  fout.write(line[0:len(line)-1])
  fout.write("\",\n")


line = """
  );

begin

  p_mem_read : process (clk) begin
    if rising_edge(clk) then
      data_out <= mem(to_integer(unsigned(address)));
    end if;
  end process;

end architecture;
"""

fout.write(line)

f_rom.close()
fout.close()
