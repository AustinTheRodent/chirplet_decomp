library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- todo: add buffers

entity sync_fifo is
  generic
  (
    G_ADDR_WIDTH : integer := 4;
    G_DATA_WIDTH : integer := 8
  );
  port
  (
    data_in  : in  std_logic_vector(G_DATA_WIDTH-1 downto 0);  -- data
    data_out : out std_logic_vector(G_DATA_WIDTH-1 downto 0);  -- data_out
    clk      : in  std_logic;           -- clock signal
    rst      : in  std_logic;           -- reset signal
    we       : in  std_logic;           --write enable signal
    re       : in  std_logic;           -- read enable signal
    full     : out std_logic;           -- full signal
    empty    : out std_logic;
    count    : out std_logic_vector(G_ADDR_WIDTH-1 downto 0)
  );
end entity;

architecture rtl of sync_fifo is

  constant C_DEPTH  : integer := 2**G_ADDR_WIDTH;  -- depth of ram

  signal rd_point   : std_logic_vector(G_ADDR_WIDTH-1 downto 0) := (others => '0');  -- read pointer
  signal wr_point   : std_logic_vector(G_ADDR_WIDTH-1 downto 0) := (others => '0');  -- write pointer
  signal status     : std_logic_vector(G_ADDR_WIDTH-1 downto 0) := (others => '0');  -- status pointer
  signal ram_out    : std_logic_vector(G_DATA_WIDTH-1 downto 0);  -- data out from ram
  signal full_s     : std_logic;
  signal empty_s    : std_logic;
  
begin

  full  <= full_s;
  empty <= empty_s;
  count <= status;

  full_s <=
    '1' when unsigned(status) = C_DEPTH-1 else
    '0';

  empty_s <=
    '1' when unsigned(status)= 0 else
    '0';

  read_pointer: process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        rd_point <= (others => '0');
      else
        if re='1' then
          rd_point <= std_logic_vector(unsigned(rd_point) + 1);
        end if;
      end if;
    end if;
  end process read_pointer;

  write_pointer: process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        wr_point <= (others => '0');
      else
        if we='1' then
          wr_point <= std_logic_vector(unsigned(wr_point) + 1);
        end if;
      end if;
    end if;
  end process;

  status_count: process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        status <= (others => '0');
      else
        if we = '1' and re = '0' and unsigned(status) /= C_DEPTH-1 then
          status <= std_logic_vector(unsigned(status) + 1);
        elsif we = '0' and re = '1' and unsigned(status) /= 0 then
          status <= std_logic_vector(unsigned(status) - 1);        
        end if;
      end if;
    end if;
  end process;

  u_ram : entity work.dual_port_ram
    generic map
    (
      G_ADDR_WIDTH => G_ADDR_WIDTH,
      G_DATA_WIDTH => G_DATA_WIDTH
    )
    port map
    (
      clk       => clk,

      wr_addr   => wr_point,
      wr_data   => data_in,
      we        => we,

      rd_addr   => rd_point,
      rd_data   => data_out,
      re        => re
    );

end rtl;
