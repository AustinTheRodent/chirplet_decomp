library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package axil_reg_file_pkg is

  constant C_REG_FILE_DATA_WIDTH  : integer := 32;
  constant C_REG_FILE_ADDR_WIDTH  : integer := 16;
  constant C_REG_FILE_MSB_FIRST   : integer := 1;

  type reg_t is record
    TEST_REG        : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0); -- RW
    TEST_REG_pulse  : std_logic;
  end record;

  type transaction_state_t is (get_addr, load_reg, write_reg, read_reg);

end package;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.axil_reg_file_pkg.all;

entity axil_reg_file is
  port
  (
    s_axi_aclk    : in  std_logic;
    a_axi_aresetn : in  std_logic;

    s_axi_awaddr  : in  std_logic_vector(C_REG_FILE_ADDR_WIDTH-1 downto 0);
    s_axi_awvalid : in  std_logic;
    s_axi_awready : out std_logic;

    s_axi_wdata   : in  std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    s_axi_wstb    : in  std_logic_vector(C_REG_FILE_DATA_WIDTH/8-1 downto 0);
    s_axi_wvalid  : in  std_logic;
    s_axi_wready  : out std_logic;

    s_axi_bresp   : out std_logic_vector(1 downto 0);
    s_axi_bvalid  : out std_logic;
    s_axi_bready  : in  std_logic;

    s_axi_araddr  : in  std_logic_vector(C_REG_FILE_ADDR_WIDTH-1 downto 0);
    s_axi_arvalid : in  std_logic;
    s_axi_arready : out std_logic;

    s_axi_rdata   : out std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    s_axi_rresp   : out std_logic_vector(1 downto 0);
    s_axi_rvalid  : out std_logic;
    s_axi_rready  : in  std_logic
    
  );
end entity;

architecture rtl of axil_reg_file is

  constant TEST_REG_addr    : integer range 0 to 2**C_REG_FILE_ADDR_WIDTH-1 := 0;

  signal registers          : reg_t;

  signal awaddr             : std_logic_vector(C_REG_FILE_ADDR_WIDTH-1 downto 0);
  signal araddr             : std_logic_vector(C_REG_FILE_ADDR_WIDTH-1 downto 0);
  signal s_axi_awready_int  : std_logic;
  signal s_axi_wready_int   : std_logic;
  signal s_axi_rvalid_int   : std_logic;
  signal s_axi_arready_int  : std_logic;

  type wr_state_t is (init, get_addr, wr_data);
  signal wr_state : wr_state_t;
  type rd_state_t is (init, get_addr, rd_data);
  signal rd_state : rd_state_t;

begin

  s_axi_awready <= s_axi_awready_int;
  s_axi_wready  <= s_axi_wready_int;

  p_wr_state_machine : process(s_axi_aclk)
  begin
    if rising_edge(s_axi_aclk) then
      if a_axi_aresetn = '0' then
        awaddr            <= (others => '0');
        s_axi_awready_int <= '0';
        s_axi_wready_int  <= '0';
        wr_state          <= init;
      else
        case wr_state is
          when init =>
            s_axi_awready_int <= '1';
            s_axi_wready_int  <= '0';
            awaddr            <= (others => '0');
            wr_state          <= get_addr;

          when get_addr =>
            if s_axi_awvalid = '1' and s_axi_awready_int = '1' then
              s_axi_awready_int <= '0';
              s_axi_wready_int  <= '1';
              awaddr            <= s_axi_awaddr;
              wr_state          <= wr_data;
            end if;

          when wr_data =>
            case awaddr is
              when std_logic_vector(to_unsigned(TEST_REG_addr, C_REG_FILE_ADDR_WIDTH)) =>
                registers.TEST_REG <= s_axi_wdata;
              when others =>
                null;
            end case;

            if s_axi_wvalid = '1' and s_axi_wready_int = '1' then
              s_axi_awready_int <= '1';
              s_axi_wready_int  <= '0';
              wr_state          <= get_addr;
            end if;

          when others =>
            wr_state <= init;
        end case;
      end if;
    end if;
  end process;

  ----------------------------------------------------------------------------

  s_axi_arready     <= s_axi_arready_int;
  s_axi_rvalid_int  <= s_axi_rvalid_int;

  p_rd_state_machine : process(s_axi_aclk)
  begin
    if rising_edge(s_axi_aclk) then
      if a_axi_aresetn = '0' then
        araddr            <= (others => '0');
        s_axi_arready_int <= '0';
        s_axi_rvalid_int  <= '0';
        rd_state          <= init;
      else
        case rd_state is
          when init =>
            s_axi_arready_int <= '1';
            s_axi_rvalid_int  <= '0';
            araddr            <= (others => '0');
            rd_state          <= get_addr;

          when get_addr =>
            if s_axi_arvalid = '1' and s_axi_arready_int = '1' then
              s_axi_arready_int <= '0';
              s_axi_rvalid_int  <= '0';
              araddr            <= s_axi_araddr;
              rd_state          <= rd_data;
            end if;

          when rd_data =>
            case araddr is
              when std_logic_vector(to_unsigned(TEST_REG_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.TEST_REG;
              when others =>
                null;
            end case;

            if s_axi_rvalid_int = '1' and s_axi_rready = '1' then
              s_axi_arready_int <= '1';
              s_axi_rvalid_int  <= '0';
              rd_state          <= get_addr;
            else
              s_axi_rvalid_int  <= '1';
            end if;

          when others =>
            rd_state <= init;
        end case;
      end if;
    end if;
  end process;



end rtl;
