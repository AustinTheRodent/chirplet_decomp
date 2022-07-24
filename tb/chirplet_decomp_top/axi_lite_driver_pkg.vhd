library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std. all;

package axi_lite_driver_pkg is

  constant C_S_AXI_DATA_WIDTH   : integer := 32;
  constant C_S_AXI_ADDR_WIDTH   : integer := 16;

  --number of cycles axi-lite device is held in reset
  --when using reset_axi_driver ():
  constant C_RESET_WAIT_CYCLES  : integer := 100;

  type axi_lite_bus_t is record
    axi_aresetn : std_logic;
    axi_awaddr  : std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
    axi_awprot  : std_logic_vector(2 downto 0);
    axi_awvalid : std_logic;
    axi_awready : std_logic;
    axi_wdata   : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
    axi_wstrb   : std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
    axi_wvalid  : std_logic;
    axi_wready  : std_logic;
    axi_bresp   : std_logic_vector(1 downto 0);
    axi_bvalid  : std_logic;
    axi_bready  : std_logic;
    axi_araddr  : std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
    axi_arprot  : std_logic_vector(2 downto 0);
    axi_arvalid : std_logic;
    axi_arready : std_logic;
    axi_rdata   : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
    axi_rresp   : std_logic_vector(1 downto 0);
    axi_rvalid  : std_logic;
    axi_rready  : std_logic;
  end record;

  procedure init_axi_driver
  (
    signal axi_lite_bus : inout axi_lite_bus_t
  );

  procedure reset_axi_driver
  (
    signal axi_lite_bus : inout axi_lite_bus_t;
    signal axi_aclk     : in    std_logic
  );

  procedure axi_write_reg
  (
    signal    axi_lite_bus  : inout axi_lite_bus_t;
    signal    axi_aclk      : in    std_logic;
    variable  address       : in    std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
    variable  d_value       : in    std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0)
  );

  procedure axi_write_bit
  (
    signal    axi_lite_bus  : inout axi_lite_bus_t;
    signal    axi_aclk      : in    std_logic;
    variable  address       : in    std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
    variable  bit_value     : in    std_logic;
    variable  bit_position  : in    integer range 0 to C_S_AXI_DATA_WIDTH-1
  );

  procedure axi_read_reg
  (
    signal    axi_lite_bus  : inout axi_lite_bus_t;
    signal    axi_aclk      : in    std_logic;
    variable  address       : in    std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
    variable  d_value       : out   std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0)
  );

  procedure axi_read_bit
  (
    signal    axi_lite_bus  : inout axi_lite_bus_t;
    signal    axi_aclk      : in    std_logic;
    variable  address       : in    std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
    variable  bit_value     : out   std_logic;
    variable  bit_position  : in    integer range 0 to C_S_AXI_DATA_WIDTH-1
  );

end package;

package body axi_lite_driver_pkg is

  procedure init_axi_driver
  (
    signal axi_lite_bus : inout axi_lite_bus_t
  ) is
  begin
    axi_lite_bus.axi_aresetn  <= '0';
    axi_lite_bus.axi_awaddr   <= (others => '0');
    axi_lite_bus.axi_awprot   <= (others => '0');
    axi_lite_bus.axi_awvalid  <= '0';
    axi_lite_bus.axi_awready  <= 'Z';
    axi_lite_bus.axi_wdata    <= (others => '0');
    axi_lite_bus.axi_wstrb    <= (others => '0');
    axi_lite_bus.axi_wvalid   <= '0';
    axi_lite_bus.axi_wready   <= 'Z';
    axi_lite_bus.axi_bresp    <= (others => 'Z');
    axi_lite_bus.axi_bvalid   <= 'Z';
    axi_lite_bus.axi_bready   <= '0';
    axi_lite_bus.axi_araddr   <= (others => '0');
    axi_lite_bus.axi_arprot   <= (others => '0');
    axi_lite_bus.axi_arvalid  <= '0';
    axi_lite_bus.axi_arready  <= 'Z';
    axi_lite_bus.axi_rdata    <= (others => 'Z');
    axi_lite_bus.axi_rresp    <= (others => 'Z');
    axi_lite_bus.axi_rvalid   <= 'Z';
    axi_lite_bus.axi_rready   <= '0';
  end procedure;

  procedure reset_axi_driver
  (
    signal axi_lite_bus : inout axi_lite_bus_t;
    signal axi_aclk     : in    std_logic
  ) is
  begin
    wait until rising_edge(axi_aclk);
    axi_lite_bus.axi_aresetn <= '0';
    wait until rising_edge(axi_aclk);
    for i in 1 to C_RESET_WAIT_CYCLES loop
      wait until rising_edge(axi_aclk);
    end loop;
    axi_lite_bus.axi_aresetn <= '1';
    return;
  end procedure;

  procedure axi_write_reg
  (
    signal    axi_lite_bus  : inout axi_lite_bus_t;
    signal    axi_aclk      : in    std_logic;
    variable  address       : in    std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
    variable  d_value       : in    std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0)
  ) is
  begin
    wait until rising_edge(axi_aclk);
    axi_lite_bus.axi_awaddr   <= address;
    axi_lite_bus.axi_awvalid  <= '1';
    axi_lite_bus.axi_wvalid   <= '0';
    wait until rising_edge(axi_aclk) and (axi_lite_bus.axi_awready = '1');
    axi_lite_bus.axi_awvalid  <= '0';
    axi_lite_bus.axi_wvalid   <= '1';
    axi_lite_bus.axi_wdata    <= d_value;
    axi_lite_bus.axi_wstrb    <= "1111"; -- bitmask
    wait until rising_edge(axi_aclk) and (axi_lite_bus.axi_wready = '1');
    axi_lite_bus.axi_wvalid   <= '0';
    return;
  end procedure;

  procedure axi_write_bit
  (
    signal    axi_lite_bus  : inout axi_lite_bus_t;
    signal    axi_aclk      : in    std_logic;
    variable  address       : in    std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
    variable  bit_value     : in    std_logic;
    variable  bit_position  : in    integer range 0 to C_S_AXI_DATA_WIDTH-1
  ) is
    variable tmp_reg_val : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
  begin
    wait until rising_edge(axi_aclk);
    axi_read_reg(axi_lite_bus, axi_aclk, address, tmp_reg_val);
    tmp_reg_val(bit_position) := bit_value;
    axi_write_reg(axi_lite_bus, axi_aclk, address, tmp_reg_val);
    return;
  end procedure;

  procedure axi_read_reg
  (
    signal    axi_lite_bus  : inout axi_lite_bus_t;
    signal    axi_aclk      : in    std_logic;
    variable  address       : in    std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
    variable  d_value       : out   std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0)
  ) is
  begin
    wait until rising_edge(axi_aclk);
    axi_lite_bus.axi_araddr   <= address;
    axi_lite_bus.axi_arvalid  <= '1';
    axi_lite_bus.axi_rready   <= '0';
    wait until rising_edge(axi_aclk) and (axi_lite_bus.axi_arready = '1');
    axi_lite_bus.axi_arvalid  <= '0';
    axi_lite_bus.axi_rready   <= '1';
    wait until rising_edge(axi_aclk) and (axi_lite_bus.axi_rvalid = '1');
    d_value := axi_lite_bus.axi_rdata;
    axi_lite_bus.axi_rready   <= '0';
    return;
  end procedure;

  procedure axi_read_bit
  (
    signal    axi_lite_bus  : inout axi_lite_bus_t;
    signal    axi_aclk      : in    std_logic;
    variable  address       : in    std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
    variable  bit_value     : out   std_logic;
    variable  bit_position  : in    integer range 0 to C_S_AXI_DATA_WIDTH-1
  ) is
  begin
    wait until rising_edge(axi_aclk);
    axi_lite_bus.axi_araddr   <= address;
    axi_lite_bus.axi_arvalid  <= '1';
    axi_lite_bus.axi_rready   <= '0';
    wait until rising_edge(axi_aclk) and (axi_lite_bus.axi_arready = '1');
    axi_lite_bus.axi_arvalid  <= '0';
    axi_lite_bus.axi_rready   <= '1';
    wait until rising_edge(axi_aclk) and (axi_lite_bus.axi_rvalid = '1');
    bit_value := axi_lite_bus.axi_rdata(bit_position);
    axi_lite_bus.axi_rready   <= '0';
    return;
  end procedure;

end package body;
