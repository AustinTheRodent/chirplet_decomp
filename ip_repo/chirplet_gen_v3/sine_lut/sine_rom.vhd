
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity sine_rom is
  generic
  (
    G_DATA_WIDTH  : integer := 32;
    G_ADDR_WIDTH  : integer := 14
  );
  port
  (
    clk       : in  std_logic;
    address   : in  std_logic_vector(G_ADDR_WIDTH-1 downto 0);
    data_out  : out std_logic_vector(G_DATA_WIDTH-1 downto 0)
  );
end entity;

architecture rtl of sine_rom is

  --constant G_DATA_WIDTH  : integer := 32;
  --constant G_ADDR_WIDTH  : integer := 14;

  constant ROM_DEPTH :integer := 2**G_ADDR_WIDTH;

  type ROM is array (integer range <>) of std_logic_vector (G_DATA_WIDTH-1 downto 0);

  function initialize_ROM
  (
    address_width : in integer
  ) return ROM is
    variable a        : real;
    variable b        : real;
    variable exp      : integer;
    variable ii       : real;
    variable ret_rom  : ROM(0 to 2**address_width-1);
  begin

    for i in 0 to integer(2.0**address_width)-1 loop

      a   := sin((MATH_PI/2.0) * (real(i)/(2.0**address_width)));
      exp := 0;

      if a = 0.0 then
        ret_rom(i) := (others => '0');
      else

        if a < 0.0 then
          ret_rom(i)(31)  := '1';
          b               := -a;
        else
          ret_rom(i)(31)  := '0';
          b               := a;
        end if;

        exp := 127;

        while b < 1.0 loop
          b   := b*2.0;
          exp := exp - 1;
        end loop;

        while b > 2.0 loop
          b   := b/2.0;
          exp := exp + 1;
        end loop;

        b := b/2.0;
        b := round(b*2.0**24);

        if b = 2.0**24 then
          exp := exp + 1;
          b   := 0.0;
        else
          b   := b - 2.0**23;
        end if;

        if exp > 255 then
          ret_rom(i)(30 downto 0)   := (others => '1');
        elsif exp <= 0 then
          ret_rom(i)(30 downto 0)   := (others => '0');
        else
          ret_rom(i)(30 downto 23)  := std_logic_vector(to_unsigned(exp, 8));
          ret_rom(i)(22 downto 0)   := std_logic_vector(to_unsigned(integer(b), 23));
        end if;

      end if;

    end loop;

    return ret_rom;

  end function;

  signal mem : ROM(0 to ROM_DEPTH-1) := initialize_ROM(G_ADDR_WIDTH);

begin

  p_mem_read : process (clk) begin
    if rising_edge(clk) then
      data_out <= mem(to_integer(unsigned(address)));
    end if;
  end process;

end architecture;
