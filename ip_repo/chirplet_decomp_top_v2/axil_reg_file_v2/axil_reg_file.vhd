library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package axil_reg_file_pkg is

  constant C_REG_FILE_DATA_WIDTH : integer := 32;
  constant C_REG_FILE_ADDR_WIDTH : integer := 12;

  type CONTROL_subreg_t is record
    ENABLE : std_logic_vector(0 downto 0);
    FEEDBACK_MODE : std_logic_vector(0 downto 0);
  end record;

  type CHIRP_GEN_NUM_SAMPS_OUT_subreg_t is record
    CHIRP_GEN_NUM_SAMPS_OUT : std_logic_vector(31 downto 0);
  end record;

  type DIN_TAU_subreg_t is record
    DIN_TAU : std_logic_vector(31 downto 0);
  end record;

  type DIN_T_STEP_subreg_t is record
    DIN_T_STEP : std_logic_vector(31 downto 0);
  end record;

  type DIN_ALPHA1_subreg_t is record
    DIN_ALPHA1 : std_logic_vector(31 downto 0);
  end record;

  type DIN_F_C_subreg_t is record
    DIN_F_C : std_logic_vector(31 downto 0);
  end record;

  type DIN_ALPHA2_subreg_t is record
    DIN_ALPHA2 : std_logic_vector(31 downto 0);
  end record;

  type DIN_PHI_subreg_t is record
    DIN_PHI : std_logic_vector(31 downto 0);
  end record;

  type DIN_BETA_subreg_t is record
    DIN_BETA : std_logic_vector(31 downto 0);
  end record;

  type XCORR_REF_SAMP_subreg_t is record
    XCORR_REF_SAMP : std_logic_vector(31 downto 0);
  end record;

  type LED_CONTROL_subreg_t is record
    LED_CONTROL : std_logic_vector(31 downto 0);
  end record;

  type GPIO_subreg_t is record
    GPIO : std_logic_vector(31 downto 0);
  end record;


  type reg_t is record
    CONTROL_REG : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    STATUS_REG : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    CHIRP_GEN_NUM_SAMPS_OUT_REG : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    DIN_TAU_REG : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    DIN_T_STEP_REG : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    DIN_ALPHA1_REG : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    DIN_F_C_REG : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    DIN_ALPHA2_REG : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    DIN_PHI_REG : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    DIN_BETA_REG : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    XCORR_REF_SAMP_REG : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    XCORR_DOUT_RE_MSBS_REG : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    XCORR_DOUT_RE_LSBS_REG : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    XCORR_DOUT_IM_MSBS_REG : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    XCORR_DOUT_IM_LSBS_REG : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    CHIRPLET_FEEDBACK_REG : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    LED_CONTROL_REG : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    GPIO_REG : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    XCORR_DOUT_RE32_REG : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    XCORR_DOUT_IM32_REG : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    CONTROL : CONTROL_subreg_t;
    CHIRP_GEN_NUM_SAMPS_OUT : CHIRP_GEN_NUM_SAMPS_OUT_subreg_t;
    DIN_TAU : DIN_TAU_subreg_t;
    DIN_T_STEP : DIN_T_STEP_subreg_t;
    DIN_ALPHA1 : DIN_ALPHA1_subreg_t;
    DIN_F_C : DIN_F_C_subreg_t;
    DIN_ALPHA2 : DIN_ALPHA2_subreg_t;
    DIN_PHI : DIN_PHI_subreg_t;
    DIN_BETA : DIN_BETA_subreg_t;
    XCORR_REF_SAMP : XCORR_REF_SAMP_subreg_t;
    LED_CONTROL : LED_CONTROL_subreg_t;
    GPIO : GPIO_subreg_t;
    CONTROL_REG_wr_pulse : std_logic;
    STATUS_REG_wr_pulse : std_logic;
    CHIRP_GEN_NUM_SAMPS_OUT_REG_wr_pulse : std_logic;
    DIN_TAU_REG_wr_pulse : std_logic;
    DIN_T_STEP_REG_wr_pulse : std_logic;
    DIN_ALPHA1_REG_wr_pulse : std_logic;
    DIN_F_C_REG_wr_pulse : std_logic;
    DIN_ALPHA2_REG_wr_pulse : std_logic;
    DIN_PHI_REG_wr_pulse : std_logic;
    DIN_BETA_REG_wr_pulse : std_logic;
    XCORR_REF_SAMP_REG_wr_pulse : std_logic;
    XCORR_DOUT_RE_MSBS_REG_wr_pulse : std_logic;
    XCORR_DOUT_RE_LSBS_REG_wr_pulse : std_logic;
    XCORR_DOUT_IM_MSBS_REG_wr_pulse : std_logic;
    XCORR_DOUT_IM_LSBS_REG_wr_pulse : std_logic;
    CHIRPLET_FEEDBACK_REG_wr_pulse : std_logic;
    LED_CONTROL_REG_wr_pulse : std_logic;
    GPIO_REG_wr_pulse : std_logic;
    XCORR_DOUT_RE32_REG_wr_pulse : std_logic;
    XCORR_DOUT_IM32_REG_wr_pulse : std_logic;
    CONTROL_REG_rd_pulse : std_logic;
    STATUS_REG_rd_pulse : std_logic;
    CHIRP_GEN_NUM_SAMPS_OUT_REG_rd_pulse : std_logic;
    DIN_TAU_REG_rd_pulse : std_logic;
    DIN_T_STEP_REG_rd_pulse : std_logic;
    DIN_ALPHA1_REG_rd_pulse : std_logic;
    DIN_F_C_REG_rd_pulse : std_logic;
    DIN_ALPHA2_REG_rd_pulse : std_logic;
    DIN_PHI_REG_rd_pulse : std_logic;
    DIN_BETA_REG_rd_pulse : std_logic;
    XCORR_REF_SAMP_REG_rd_pulse : std_logic;
    XCORR_DOUT_RE_MSBS_REG_rd_pulse : std_logic;
    XCORR_DOUT_RE_LSBS_REG_rd_pulse : std_logic;
    XCORR_DOUT_IM_MSBS_REG_rd_pulse : std_logic;
    XCORR_DOUT_IM_LSBS_REG_rd_pulse : std_logic;
    CHIRPLET_FEEDBACK_REG_rd_pulse : std_logic;
    LED_CONTROL_REG_rd_pulse : std_logic;
    GPIO_REG_rd_pulse : std_logic;
    XCORR_DOUT_RE32_REG_rd_pulse : std_logic;
    XCORR_DOUT_IM32_REG_rd_pulse : std_logic;
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

    s_STATUS_CHIRP_GEN_READY : in std_logic_vector(0 downto 0);
    s_STATUS_CHIRP_GEN_READY_v : in std_logic;

    s_STATUS_XCORR_DOUT_VALID : in std_logic_vector(0 downto 0);
    s_STATUS_XCORR_DOUT_VALID_v : in std_logic;

    s_XCORR_DOUT_RE_MSBS_XCORR_DOUT_RE_MSBS : in std_logic_vector(31 downto 0);
    s_XCORR_DOUT_RE_MSBS_XCORR_DOUT_RE_MSBS_v : in std_logic;

    s_XCORR_DOUT_RE_LSBS_XCORR_DOUT_RE_LSBS : in std_logic_vector(31 downto 0);
    s_XCORR_DOUT_RE_LSBS_XCORR_DOUT_RE_LSBS_v : in std_logic;

    s_XCORR_DOUT_IM_MSBS_XCORR_DOUT_IM_MSBS : in std_logic_vector(31 downto 0);
    s_XCORR_DOUT_IM_MSBS_XCORR_DOUT_IM_MSBS_v : in std_logic;

    s_XCORR_DOUT_IM_LSBS_XCORR_DOUT_IM_LSBS : in std_logic_vector(31 downto 0);
    s_XCORR_DOUT_IM_LSBS_XCORR_DOUT_IM_LSBS_v : in std_logic;

    s_CHIRPLET_FEEDBACK_CHIRPLET_FEEDBACK : in std_logic_vector(31 downto 0);
    s_CHIRPLET_FEEDBACK_CHIRPLET_FEEDBACK_v : in std_logic;

    s_XCORR_DOUT_RE32_XCORR_DOUT_RE32 : in std_logic_vector(31 downto 0);
    s_XCORR_DOUT_RE32_XCORR_DOUT_RE32_v : in std_logic;

    s_XCORR_DOUT_IM32_XCORR_DOUT_IM32 : in std_logic_vector(31 downto 0);
    s_XCORR_DOUT_IM32_XCORR_DOUT_IM32_v : in std_logic;


    s_axi_awaddr  : in  std_logic_vector(C_REG_FILE_ADDR_WIDTH-1 downto 0);
    s_axi_awvalid : in  std_logic;
    s_axi_awready : out std_logic;

    s_axi_wdata   : in  std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    s_axi_wstrb   : in  std_logic_vector(C_REG_FILE_DATA_WIDTH/8-1 downto 0);
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
    s_axi_rready  : in  std_logic;

    registers_out : out reg_t
  );
end entity;

architecture rtl of axil_reg_file is

  constant CONTROL_addr : integer range 0 to 2**C_REG_FILE_ADDR_WIDTH-1 := 0;
  constant STATUS_addr : integer range 0 to 2**C_REG_FILE_ADDR_WIDTH-1 := 4;
  constant CHIRP_GEN_NUM_SAMPS_OUT_addr : integer range 0 to 2**C_REG_FILE_ADDR_WIDTH-1 := 8;
  constant DIN_TAU_addr : integer range 0 to 2**C_REG_FILE_ADDR_WIDTH-1 := 12;
  constant DIN_T_STEP_addr : integer range 0 to 2**C_REG_FILE_ADDR_WIDTH-1 := 16;
  constant DIN_ALPHA1_addr : integer range 0 to 2**C_REG_FILE_ADDR_WIDTH-1 := 20;
  constant DIN_F_C_addr : integer range 0 to 2**C_REG_FILE_ADDR_WIDTH-1 := 24;
  constant DIN_ALPHA2_addr : integer range 0 to 2**C_REG_FILE_ADDR_WIDTH-1 := 28;
  constant DIN_PHI_addr : integer range 0 to 2**C_REG_FILE_ADDR_WIDTH-1 := 32;
  constant DIN_BETA_addr : integer range 0 to 2**C_REG_FILE_ADDR_WIDTH-1 := 36;
  constant XCORR_REF_SAMP_addr : integer range 0 to 2**C_REG_FILE_ADDR_WIDTH-1 := 40;
  constant XCORR_DOUT_RE_MSBS_addr : integer range 0 to 2**C_REG_FILE_ADDR_WIDTH-1 := 44;
  constant XCORR_DOUT_RE_LSBS_addr : integer range 0 to 2**C_REG_FILE_ADDR_WIDTH-1 := 48;
  constant XCORR_DOUT_IM_MSBS_addr : integer range 0 to 2**C_REG_FILE_ADDR_WIDTH-1 := 52;
  constant XCORR_DOUT_IM_LSBS_addr : integer range 0 to 2**C_REG_FILE_ADDR_WIDTH-1 := 56;
  constant CHIRPLET_FEEDBACK_addr : integer range 0 to 2**C_REG_FILE_ADDR_WIDTH-1 := 60;
  constant LED_CONTROL_addr : integer range 0 to 2**C_REG_FILE_ADDR_WIDTH-1 := 64;
  constant GPIO_addr : integer range 0 to 2**C_REG_FILE_ADDR_WIDTH-1 := 68;
  constant XCORR_DOUT_RE32_addr : integer range 0 to 2**C_REG_FILE_ADDR_WIDTH-1 := 72;
  constant XCORR_DOUT_IM32_addr : integer range 0 to 2**C_REG_FILE_ADDR_WIDTH-1 := 76;

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

  registers.CONTROL.ENABLE <= registers.CONTROL_REG(0 downto 0);
  registers.CONTROL.FEEDBACK_MODE <= registers.CONTROL_REG(1 downto 1);
  registers.CHIRP_GEN_NUM_SAMPS_OUT.CHIRP_GEN_NUM_SAMPS_OUT <= registers.CHIRP_GEN_NUM_SAMPS_OUT_REG(31 downto 0);
  registers.DIN_TAU.DIN_TAU <= registers.DIN_TAU_REG(31 downto 0);
  registers.DIN_T_STEP.DIN_T_STEP <= registers.DIN_T_STEP_REG(31 downto 0);
  registers.DIN_ALPHA1.DIN_ALPHA1 <= registers.DIN_ALPHA1_REG(31 downto 0);
  registers.DIN_F_C.DIN_F_C <= registers.DIN_F_C_REG(31 downto 0);
  registers.DIN_ALPHA2.DIN_ALPHA2 <= registers.DIN_ALPHA2_REG(31 downto 0);
  registers.DIN_PHI.DIN_PHI <= registers.DIN_PHI_REG(31 downto 0);
  registers.DIN_BETA.DIN_BETA <= registers.DIN_BETA_REG(31 downto 0);
  registers.XCORR_REF_SAMP.XCORR_REF_SAMP <= registers.XCORR_REF_SAMP_REG(31 downto 0);
  registers.LED_CONTROL.LED_CONTROL <= registers.LED_CONTROL_REG(31 downto 0);
  registers.GPIO.GPIO <= registers.GPIO_REG(31 downto 0);

  registers_out <= registers;

  s_axi_rresp   <= (others => '0');
  s_axi_bresp   <= (others => '0');
  s_axi_bvalid  <= '1';

  s_axi_awready <= s_axi_awready_int;
  s_axi_wready  <= s_axi_wready_int;

  p_read_only_regs : process(s_axi_aclk)
  begin
    if rising_edge(s_axi_aclk) then
      if a_axi_aresetn = '0' then
        registers.STATUS_REG <= x"00000000";
        registers.XCORR_DOUT_RE_MSBS_REG <= x"00000000";
        registers.XCORR_DOUT_RE_LSBS_REG <= x"00000000";
        registers.XCORR_DOUT_IM_MSBS_REG <= x"00000000";
        registers.XCORR_DOUT_IM_LSBS_REG <= x"00000000";
        registers.CHIRPLET_FEEDBACK_REG <= x"00000000";
        registers.XCORR_DOUT_RE32_REG <= x"00000000";
        registers.XCORR_DOUT_IM32_REG <= x"00000000";
      else
        if s_STATUS_CHIRP_GEN_READY_v = '1' then 
          registers.STATUS_REG(0 downto 0) <= s_STATUS_CHIRP_GEN_READY;
        end if;
        if s_STATUS_XCORR_DOUT_VALID_v = '1' then 
          registers.STATUS_REG(1 downto 1) <= s_STATUS_XCORR_DOUT_VALID;
        end if;
        if s_XCORR_DOUT_RE_MSBS_XCORR_DOUT_RE_MSBS_v = '1' then 
          registers.XCORR_DOUT_RE_MSBS_REG(31 downto 0) <= s_XCORR_DOUT_RE_MSBS_XCORR_DOUT_RE_MSBS;
        end if;
        if s_XCORR_DOUT_RE_LSBS_XCORR_DOUT_RE_LSBS_v = '1' then 
          registers.XCORR_DOUT_RE_LSBS_REG(31 downto 0) <= s_XCORR_DOUT_RE_LSBS_XCORR_DOUT_RE_LSBS;
        end if;
        if s_XCORR_DOUT_IM_MSBS_XCORR_DOUT_IM_MSBS_v = '1' then 
          registers.XCORR_DOUT_IM_MSBS_REG(31 downto 0) <= s_XCORR_DOUT_IM_MSBS_XCORR_DOUT_IM_MSBS;
        end if;
        if s_XCORR_DOUT_IM_LSBS_XCORR_DOUT_IM_LSBS_v = '1' then 
          registers.XCORR_DOUT_IM_LSBS_REG(31 downto 0) <= s_XCORR_DOUT_IM_LSBS_XCORR_DOUT_IM_LSBS;
        end if;
        if s_CHIRPLET_FEEDBACK_CHIRPLET_FEEDBACK_v = '1' then 
          registers.CHIRPLET_FEEDBACK_REG(31 downto 0) <= s_CHIRPLET_FEEDBACK_CHIRPLET_FEEDBACK;
        end if;
        if s_XCORR_DOUT_RE32_XCORR_DOUT_RE32_v = '1' then 
          registers.XCORR_DOUT_RE32_REG(31 downto 0) <= s_XCORR_DOUT_RE32_XCORR_DOUT_RE32;
        end if;
        if s_XCORR_DOUT_IM32_XCORR_DOUT_IM32_v = '1' then 
          registers.XCORR_DOUT_IM32_REG(31 downto 0) <= s_XCORR_DOUT_IM32_XCORR_DOUT_IM32;
        end if;
      end if;
    end if;
  end process;

  p_wr_state_machine : process(s_axi_aclk)
  begin
    if rising_edge(s_axi_aclk) then
      if a_axi_aresetn = '0' then
        registers.CONTROL_REG <= x"00000000";
        registers.CHIRP_GEN_NUM_SAMPS_OUT_REG <= x"00000000";
        registers.DIN_TAU_REG <= x"00000000";
        registers.DIN_T_STEP_REG <= x"00000000";
        registers.DIN_ALPHA1_REG <= x"00000000";
        registers.DIN_F_C_REG <= x"00000000";
        registers.DIN_ALPHA2_REG <= x"00000000";
        registers.DIN_PHI_REG <= x"00000000";
        registers.DIN_BETA_REG <= x"00000000";
        registers.XCORR_REF_SAMP_REG <= x"00000000";
        registers.LED_CONTROL_REG <= x"00000000";
        registers.GPIO_REG <= x"00000000";
        awaddr            <= (others => '0');
        registers.CONTROL_REG_wr_pulse <= '0';
        registers.STATUS_REG_wr_pulse <= '0';
        registers.CHIRP_GEN_NUM_SAMPS_OUT_REG_wr_pulse <= '0';
        registers.DIN_TAU_REG_wr_pulse <= '0';
        registers.DIN_T_STEP_REG_wr_pulse <= '0';
        registers.DIN_ALPHA1_REG_wr_pulse <= '0';
        registers.DIN_F_C_REG_wr_pulse <= '0';
        registers.DIN_ALPHA2_REG_wr_pulse <= '0';
        registers.DIN_PHI_REG_wr_pulse <= '0';
        registers.DIN_BETA_REG_wr_pulse <= '0';
        registers.XCORR_REF_SAMP_REG_wr_pulse <= '0';
        registers.XCORR_DOUT_RE_MSBS_REG_wr_pulse <= '0';
        registers.XCORR_DOUT_RE_LSBS_REG_wr_pulse <= '0';
        registers.XCORR_DOUT_IM_MSBS_REG_wr_pulse <= '0';
        registers.XCORR_DOUT_IM_LSBS_REG_wr_pulse <= '0';
        registers.CHIRPLET_FEEDBACK_REG_wr_pulse <= '0';
        registers.LED_CONTROL_REG_wr_pulse <= '0';
        registers.GPIO_REG_wr_pulse <= '0';
        registers.XCORR_DOUT_RE32_REG_wr_pulse <= '0';
        registers.XCORR_DOUT_IM32_REG_wr_pulse <= '0';
        s_axi_awready_int <= '0';
        s_axi_wready_int  <= '0';
        wr_state          <= init;
      else
        case wr_state is
          when init =>
            registers.CONTROL_REG_wr_pulse <= '0';
            registers.STATUS_REG_wr_pulse <= '0';
            registers.CHIRP_GEN_NUM_SAMPS_OUT_REG_wr_pulse <= '0';
            registers.DIN_TAU_REG_wr_pulse <= '0';
            registers.DIN_T_STEP_REG_wr_pulse <= '0';
            registers.DIN_ALPHA1_REG_wr_pulse <= '0';
            registers.DIN_F_C_REG_wr_pulse <= '0';
            registers.DIN_ALPHA2_REG_wr_pulse <= '0';
            registers.DIN_PHI_REG_wr_pulse <= '0';
            registers.DIN_BETA_REG_wr_pulse <= '0';
            registers.XCORR_REF_SAMP_REG_wr_pulse <= '0';
            registers.XCORR_DOUT_RE_MSBS_REG_wr_pulse <= '0';
            registers.XCORR_DOUT_RE_LSBS_REG_wr_pulse <= '0';
            registers.XCORR_DOUT_IM_MSBS_REG_wr_pulse <= '0';
            registers.XCORR_DOUT_IM_LSBS_REG_wr_pulse <= '0';
            registers.CHIRPLET_FEEDBACK_REG_wr_pulse <= '0';
            registers.LED_CONTROL_REG_wr_pulse <= '0';
            registers.GPIO_REG_wr_pulse <= '0';
            registers.XCORR_DOUT_RE32_REG_wr_pulse <= '0';
            registers.XCORR_DOUT_IM32_REG_wr_pulse <= '0';
            s_axi_awready_int <= '1';
            s_axi_wready_int  <= '0';
            awaddr            <= (others => '0');
            wr_state          <= get_addr;

          when get_addr =>
            registers.CONTROL_REG_wr_pulse <= '0';
            registers.STATUS_REG_wr_pulse <= '0';
            registers.CHIRP_GEN_NUM_SAMPS_OUT_REG_wr_pulse <= '0';
            registers.DIN_TAU_REG_wr_pulse <= '0';
            registers.DIN_T_STEP_REG_wr_pulse <= '0';
            registers.DIN_ALPHA1_REG_wr_pulse <= '0';
            registers.DIN_F_C_REG_wr_pulse <= '0';
            registers.DIN_ALPHA2_REG_wr_pulse <= '0';
            registers.DIN_PHI_REG_wr_pulse <= '0';
            registers.DIN_BETA_REG_wr_pulse <= '0';
            registers.XCORR_REF_SAMP_REG_wr_pulse <= '0';
            registers.XCORR_DOUT_RE_MSBS_REG_wr_pulse <= '0';
            registers.XCORR_DOUT_RE_LSBS_REG_wr_pulse <= '0';
            registers.XCORR_DOUT_IM_MSBS_REG_wr_pulse <= '0';
            registers.XCORR_DOUT_IM_LSBS_REG_wr_pulse <= '0';
            registers.CHIRPLET_FEEDBACK_REG_wr_pulse <= '0';
            registers.LED_CONTROL_REG_wr_pulse <= '0';
            registers.GPIO_REG_wr_pulse <= '0';
            registers.XCORR_DOUT_RE32_REG_wr_pulse <= '0';
            registers.XCORR_DOUT_IM32_REG_wr_pulse <= '0';
            if s_axi_awvalid = '1' and s_axi_awready_int = '1' then
              s_axi_awready_int <= '0';
              s_axi_wready_int  <= '1';
              awaddr            <= s_axi_awaddr;
              wr_state          <= wr_data;
            end if;

          when wr_data =>

            if s_axi_wvalid = '1' and s_axi_wready_int = '1' then
              case awaddr is
                when std_logic_vector(to_unsigned(CONTROL_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.CONTROL_REG <= s_axi_wdata;
                  registers.CONTROL_REG_wr_pulse <= '1';
                when std_logic_vector(to_unsigned(CHIRP_GEN_NUM_SAMPS_OUT_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.CHIRP_GEN_NUM_SAMPS_OUT_REG <= s_axi_wdata;
                  registers.CHIRP_GEN_NUM_SAMPS_OUT_REG_wr_pulse <= '1';
                when std_logic_vector(to_unsigned(DIN_TAU_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.DIN_TAU_REG <= s_axi_wdata;
                  registers.DIN_TAU_REG_wr_pulse <= '1';
                when std_logic_vector(to_unsigned(DIN_T_STEP_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.DIN_T_STEP_REG <= s_axi_wdata;
                  registers.DIN_T_STEP_REG_wr_pulse <= '1';
                when std_logic_vector(to_unsigned(DIN_ALPHA1_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.DIN_ALPHA1_REG <= s_axi_wdata;
                  registers.DIN_ALPHA1_REG_wr_pulse <= '1';
                when std_logic_vector(to_unsigned(DIN_F_C_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.DIN_F_C_REG <= s_axi_wdata;
                  registers.DIN_F_C_REG_wr_pulse <= '1';
                when std_logic_vector(to_unsigned(DIN_ALPHA2_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.DIN_ALPHA2_REG <= s_axi_wdata;
                  registers.DIN_ALPHA2_REG_wr_pulse <= '1';
                when std_logic_vector(to_unsigned(DIN_PHI_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.DIN_PHI_REG <= s_axi_wdata;
                  registers.DIN_PHI_REG_wr_pulse <= '1';
                when std_logic_vector(to_unsigned(DIN_BETA_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.DIN_BETA_REG <= s_axi_wdata;
                  registers.DIN_BETA_REG_wr_pulse <= '1';
                when std_logic_vector(to_unsigned(XCORR_REF_SAMP_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.XCORR_REF_SAMP_REG <= s_axi_wdata;
                  registers.XCORR_REF_SAMP_REG_wr_pulse <= '1';
                when std_logic_vector(to_unsigned(LED_CONTROL_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.LED_CONTROL_REG <= s_axi_wdata;
                  registers.LED_CONTROL_REG_wr_pulse <= '1';
                when std_logic_vector(to_unsigned(GPIO_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.GPIO_REG <= s_axi_wdata;
                  registers.GPIO_REG_wr_pulse <= '1';
                when others =>
                  null;
              end case;

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
  s_axi_rvalid      <= s_axi_rvalid_int;

  p_rd_state_machine : process(s_axi_aclk)
  begin
    if rising_edge(s_axi_aclk) then
      if a_axi_aresetn = '0' then
        araddr            <= (others => '0');
        s_axi_rdata       <= (others => '0');
        registers.CONTROL_REG_rd_pulse <= '0';
        registers.STATUS_REG_rd_pulse <= '0';
        registers.CHIRP_GEN_NUM_SAMPS_OUT_REG_rd_pulse <= '0';
        registers.DIN_TAU_REG_rd_pulse <= '0';
        registers.DIN_T_STEP_REG_rd_pulse <= '0';
        registers.DIN_ALPHA1_REG_rd_pulse <= '0';
        registers.DIN_F_C_REG_rd_pulse <= '0';
        registers.DIN_ALPHA2_REG_rd_pulse <= '0';
        registers.DIN_PHI_REG_rd_pulse <= '0';
        registers.DIN_BETA_REG_rd_pulse <= '0';
        registers.XCORR_REF_SAMP_REG_rd_pulse <= '0';
        registers.XCORR_DOUT_RE_MSBS_REG_rd_pulse <= '0';
        registers.XCORR_DOUT_RE_LSBS_REG_rd_pulse <= '0';
        registers.XCORR_DOUT_IM_MSBS_REG_rd_pulse <= '0';
        registers.XCORR_DOUT_IM_LSBS_REG_rd_pulse <= '0';
        registers.CHIRPLET_FEEDBACK_REG_rd_pulse <= '0';
        registers.LED_CONTROL_REG_rd_pulse <= '0';
        registers.GPIO_REG_rd_pulse <= '0';
        registers.XCORR_DOUT_RE32_REG_rd_pulse <= '0';
        registers.XCORR_DOUT_IM32_REG_rd_pulse <= '0';
        s_axi_arready_int <= '0';
        s_axi_rvalid_int  <= '0';
        rd_state          <= init;
      else
        case rd_state is
          when init =>
            registers.CONTROL_REG_rd_pulse <= '0';
            registers.STATUS_REG_rd_pulse <= '0';
            registers.CHIRP_GEN_NUM_SAMPS_OUT_REG_rd_pulse <= '0';
            registers.DIN_TAU_REG_rd_pulse <= '0';
            registers.DIN_T_STEP_REG_rd_pulse <= '0';
            registers.DIN_ALPHA1_REG_rd_pulse <= '0';
            registers.DIN_F_C_REG_rd_pulse <= '0';
            registers.DIN_ALPHA2_REG_rd_pulse <= '0';
            registers.DIN_PHI_REG_rd_pulse <= '0';
            registers.DIN_BETA_REG_rd_pulse <= '0';
            registers.XCORR_REF_SAMP_REG_rd_pulse <= '0';
            registers.XCORR_DOUT_RE_MSBS_REG_rd_pulse <= '0';
            registers.XCORR_DOUT_RE_LSBS_REG_rd_pulse <= '0';
            registers.XCORR_DOUT_IM_MSBS_REG_rd_pulse <= '0';
            registers.XCORR_DOUT_IM_LSBS_REG_rd_pulse <= '0';
            registers.CHIRPLET_FEEDBACK_REG_rd_pulse <= '0';
            registers.LED_CONTROL_REG_rd_pulse <= '0';
            registers.GPIO_REG_rd_pulse <= '0';
            registers.XCORR_DOUT_RE32_REG_rd_pulse <= '0';
            registers.XCORR_DOUT_IM32_REG_rd_pulse <= '0';
            s_axi_arready_int <= '1';
            s_axi_rvalid_int  <= '0';
            araddr            <= (others => '0');
            rd_state          <= get_addr;

          when get_addr =>
            registers.CONTROL_REG_rd_pulse <= '0';
            registers.STATUS_REG_rd_pulse <= '0';
            registers.CHIRP_GEN_NUM_SAMPS_OUT_REG_rd_pulse <= '0';
            registers.DIN_TAU_REG_rd_pulse <= '0';
            registers.DIN_T_STEP_REG_rd_pulse <= '0';
            registers.DIN_ALPHA1_REG_rd_pulse <= '0';
            registers.DIN_F_C_REG_rd_pulse <= '0';
            registers.DIN_ALPHA2_REG_rd_pulse <= '0';
            registers.DIN_PHI_REG_rd_pulse <= '0';
            registers.DIN_BETA_REG_rd_pulse <= '0';
            registers.XCORR_REF_SAMP_REG_rd_pulse <= '0';
            registers.XCORR_DOUT_RE_MSBS_REG_rd_pulse <= '0';
            registers.XCORR_DOUT_RE_LSBS_REG_rd_pulse <= '0';
            registers.XCORR_DOUT_IM_MSBS_REG_rd_pulse <= '0';
            registers.XCORR_DOUT_IM_LSBS_REG_rd_pulse <= '0';
            registers.CHIRPLET_FEEDBACK_REG_rd_pulse <= '0';
            registers.LED_CONTROL_REG_rd_pulse <= '0';
            registers.GPIO_REG_rd_pulse <= '0';
            registers.XCORR_DOUT_RE32_REG_rd_pulse <= '0';
            registers.XCORR_DOUT_IM32_REG_rd_pulse <= '0';
            if s_axi_arvalid = '1' and s_axi_arready_int = '1' then
              s_axi_arready_int <= '0';
              s_axi_rvalid_int  <= '0';
              araddr            <= s_axi_araddr;
              rd_state          <= rd_data;
            end if;

          when rd_data =>
            case araddr is
              when std_logic_vector(to_unsigned(CONTROL_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.CONTROL_REG;
              when std_logic_vector(to_unsigned(STATUS_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.STATUS_REG;
              when std_logic_vector(to_unsigned(CHIRP_GEN_NUM_SAMPS_OUT_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.CHIRP_GEN_NUM_SAMPS_OUT_REG;
              when std_logic_vector(to_unsigned(DIN_TAU_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.DIN_TAU_REG;
              when std_logic_vector(to_unsigned(DIN_T_STEP_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.DIN_T_STEP_REG;
              when std_logic_vector(to_unsigned(DIN_ALPHA1_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.DIN_ALPHA1_REG;
              when std_logic_vector(to_unsigned(DIN_F_C_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.DIN_F_C_REG;
              when std_logic_vector(to_unsigned(DIN_ALPHA2_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.DIN_ALPHA2_REG;
              when std_logic_vector(to_unsigned(DIN_PHI_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.DIN_PHI_REG;
              when std_logic_vector(to_unsigned(DIN_BETA_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.DIN_BETA_REG;
              when std_logic_vector(to_unsigned(XCORR_REF_SAMP_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.XCORR_REF_SAMP_REG;
              when std_logic_vector(to_unsigned(XCORR_DOUT_RE_MSBS_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.XCORR_DOUT_RE_MSBS_REG;
              when std_logic_vector(to_unsigned(XCORR_DOUT_RE_LSBS_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.XCORR_DOUT_RE_LSBS_REG;
              when std_logic_vector(to_unsigned(XCORR_DOUT_IM_MSBS_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.XCORR_DOUT_IM_MSBS_REG;
              when std_logic_vector(to_unsigned(XCORR_DOUT_IM_LSBS_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.XCORR_DOUT_IM_LSBS_REG;
              when std_logic_vector(to_unsigned(CHIRPLET_FEEDBACK_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.CHIRPLET_FEEDBACK_REG;
              when std_logic_vector(to_unsigned(LED_CONTROL_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.LED_CONTROL_REG;
              when std_logic_vector(to_unsigned(GPIO_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.GPIO_REG;
              when std_logic_vector(to_unsigned(XCORR_DOUT_RE32_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.XCORR_DOUT_RE32_REG;
              when std_logic_vector(to_unsigned(XCORR_DOUT_IM32_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.XCORR_DOUT_IM32_REG;
              when others =>
                null;
            end case;

            if s_axi_rvalid_int = '1' and s_axi_rready = '1' then
              case araddr is
                when std_logic_vector(to_unsigned(CONTROL_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.CONTROL_REG_rd_pulse <= '1';
                when std_logic_vector(to_unsigned(STATUS_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.STATUS_REG_rd_pulse <= '1';
                when std_logic_vector(to_unsigned(CHIRP_GEN_NUM_SAMPS_OUT_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.CHIRP_GEN_NUM_SAMPS_OUT_REG_rd_pulse <= '1';
                when std_logic_vector(to_unsigned(DIN_TAU_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.DIN_TAU_REG_rd_pulse <= '1';
                when std_logic_vector(to_unsigned(DIN_T_STEP_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.DIN_T_STEP_REG_rd_pulse <= '1';
                when std_logic_vector(to_unsigned(DIN_ALPHA1_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.DIN_ALPHA1_REG_rd_pulse <= '1';
                when std_logic_vector(to_unsigned(DIN_F_C_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.DIN_F_C_REG_rd_pulse <= '1';
                when std_logic_vector(to_unsigned(DIN_ALPHA2_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.DIN_ALPHA2_REG_rd_pulse <= '1';
                when std_logic_vector(to_unsigned(DIN_PHI_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.DIN_PHI_REG_rd_pulse <= '1';
                when std_logic_vector(to_unsigned(DIN_BETA_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.DIN_BETA_REG_rd_pulse <= '1';
                when std_logic_vector(to_unsigned(XCORR_REF_SAMP_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.XCORR_REF_SAMP_REG_rd_pulse <= '1';
                when std_logic_vector(to_unsigned(XCORR_DOUT_RE_MSBS_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.XCORR_DOUT_RE_MSBS_REG_rd_pulse <= '1';
                when std_logic_vector(to_unsigned(XCORR_DOUT_RE_LSBS_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.XCORR_DOUT_RE_LSBS_REG_rd_pulse <= '1';
                when std_logic_vector(to_unsigned(XCORR_DOUT_IM_MSBS_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.XCORR_DOUT_IM_MSBS_REG_rd_pulse <= '1';
                when std_logic_vector(to_unsigned(XCORR_DOUT_IM_LSBS_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.XCORR_DOUT_IM_LSBS_REG_rd_pulse <= '1';
                when std_logic_vector(to_unsigned(CHIRPLET_FEEDBACK_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.CHIRPLET_FEEDBACK_REG_rd_pulse <= '1';
                when std_logic_vector(to_unsigned(LED_CONTROL_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.LED_CONTROL_REG_rd_pulse <= '1';
                when std_logic_vector(to_unsigned(GPIO_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.GPIO_REG_rd_pulse <= '1';
                when std_logic_vector(to_unsigned(XCORR_DOUT_RE32_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.XCORR_DOUT_RE32_REG_rd_pulse <= '1';
                when std_logic_vector(to_unsigned(XCORR_DOUT_IM32_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.XCORR_DOUT_IM32_REG_rd_pulse <= '1';
                when others =>
                  null;
              end case;
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
