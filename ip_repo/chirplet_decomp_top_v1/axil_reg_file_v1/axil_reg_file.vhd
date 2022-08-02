library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package axil_reg_file_pkg is

  constant C_REG_FILE_DATA_WIDTH : integer := 32;
  constant C_REG_FILE_ADDR_WIDTH : integer := 16;

  type reg_t is record
    CONTROL : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    STATUS : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    CHIRP_GEN_NUM_SAMPS_OUT : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    DIN_TAU : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    DIN_T_STEP : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    DIN_ALPHA1 : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    DIN_F_C : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    DIN_ALPHA2 : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    DIN_PHI : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    DIN_BETA : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    XCORR_REF_SAMP : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    XCORR_DOUT_RE_MSBS : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    XCORR_DOUT_RE_LSBS : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    XCORR_DOUT_IM_MSBS : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    XCORR_DOUT_IM_LSBS : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    CHIRPLET_FEEDBACK : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    CONTROL_wr_pulse : std_logic;
    STATUS_wr_pulse : std_logic;
    CHIRP_GEN_NUM_SAMPS_OUT_wr_pulse : std_logic;
    DIN_TAU_wr_pulse : std_logic;
    DIN_T_STEP_wr_pulse : std_logic;
    DIN_ALPHA1_wr_pulse : std_logic;
    DIN_F_C_wr_pulse : std_logic;
    DIN_ALPHA2_wr_pulse : std_logic;
    DIN_PHI_wr_pulse : std_logic;
    DIN_BETA_wr_pulse : std_logic;
    XCORR_REF_SAMP_wr_pulse : std_logic;
    XCORR_DOUT_RE_MSBS_wr_pulse : std_logic;
    XCORR_DOUT_RE_LSBS_wr_pulse : std_logic;
    XCORR_DOUT_IM_MSBS_wr_pulse : std_logic;
    XCORR_DOUT_IM_LSBS_wr_pulse : std_logic;
    CHIRPLET_FEEDBACK_wr_pulse : std_logic;
    CONTROL_rd_pulse : std_logic;
    STATUS_rd_pulse : std_logic;
    CHIRP_GEN_NUM_SAMPS_OUT_rd_pulse : std_logic;
    DIN_TAU_rd_pulse : std_logic;
    DIN_T_STEP_rd_pulse : std_logic;
    DIN_ALPHA1_rd_pulse : std_logic;
    DIN_F_C_rd_pulse : std_logic;
    DIN_ALPHA2_rd_pulse : std_logic;
    DIN_PHI_rd_pulse : std_logic;
    DIN_BETA_rd_pulse : std_logic;
    XCORR_REF_SAMP_rd_pulse : std_logic;
    XCORR_DOUT_RE_MSBS_rd_pulse : std_logic;
    XCORR_DOUT_RE_LSBS_rd_pulse : std_logic;
    XCORR_DOUT_IM_MSBS_rd_pulse : std_logic;
    XCORR_DOUT_IM_LSBS_rd_pulse : std_logic;
    CHIRPLET_FEEDBACK_rd_pulse : std_logic;
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

    s_STATUS : in  std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    s_XCORR_DOUT_RE_MSBS : in  std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    s_XCORR_DOUT_RE_LSBS : in  std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    s_XCORR_DOUT_IM_MSBS : in  std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    s_XCORR_DOUT_IM_LSBS : in  std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    s_CHIRPLET_FEEDBACK : in  std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);

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

  registers_out <= registers;

  s_axi_rresp   <= (others => '0');
  s_axi_bresp   <= (others => '0');
  s_axi_bvalid  <= '1';

  s_axi_awready <= s_axi_awready_int;
  s_axi_wready  <= s_axi_wready_int;

  p_read_only_regs : process(s_axi_aclk)
  begin
    if rising_edge(s_axi_aclk) then
      registers.STATUS <= s_STATUS;
      registers.XCORR_DOUT_RE_MSBS <= s_XCORR_DOUT_RE_MSBS;
      registers.XCORR_DOUT_RE_LSBS <= s_XCORR_DOUT_RE_LSBS;
      registers.XCORR_DOUT_IM_MSBS <= s_XCORR_DOUT_IM_MSBS;
      registers.XCORR_DOUT_IM_LSBS <= s_XCORR_DOUT_IM_LSBS;
      registers.CHIRPLET_FEEDBACK <= s_CHIRPLET_FEEDBACK;
    end if;
  end process;

  p_wr_state_machine : process(s_axi_aclk)
  begin
    if rising_edge(s_axi_aclk) then
      if a_axi_aresetn = '0' then
        registers.CONTROL <= x"00000000";
        registers.CHIRP_GEN_NUM_SAMPS_OUT <= x"00000000";
        registers.DIN_TAU <= x"00000000";
        registers.DIN_T_STEP <= x"00000000";
        registers.DIN_ALPHA1 <= x"00000000";
        registers.DIN_F_C <= x"00000000";
        registers.DIN_ALPHA2 <= x"00000000";
        registers.DIN_PHI <= x"00000000";
        registers.DIN_BETA <= x"00000000";
        registers.XCORR_REF_SAMP <= x"00000000";
        awaddr            <= (others => '0');
        registers.CONTROL_wr_pulse <= '0';
        registers.STATUS_wr_pulse <= '0';
        registers.CHIRP_GEN_NUM_SAMPS_OUT_wr_pulse <= '0';
        registers.DIN_TAU_wr_pulse <= '0';
        registers.DIN_T_STEP_wr_pulse <= '0';
        registers.DIN_ALPHA1_wr_pulse <= '0';
        registers.DIN_F_C_wr_pulse <= '0';
        registers.DIN_ALPHA2_wr_pulse <= '0';
        registers.DIN_PHI_wr_pulse <= '0';
        registers.DIN_BETA_wr_pulse <= '0';
        registers.XCORR_REF_SAMP_wr_pulse <= '0';
        registers.XCORR_DOUT_RE_MSBS_wr_pulse <= '0';
        registers.XCORR_DOUT_RE_LSBS_wr_pulse <= '0';
        registers.XCORR_DOUT_IM_MSBS_wr_pulse <= '0';
        registers.XCORR_DOUT_IM_LSBS_wr_pulse <= '0';
        registers.CHIRPLET_FEEDBACK_wr_pulse <= '0';
        s_axi_awready_int <= '0';
        s_axi_wready_int  <= '0';
        wr_state          <= init;
      else
        case wr_state is
          when init =>
            registers.CONTROL_wr_pulse <= '0';
            registers.STATUS_wr_pulse <= '0';
            registers.CHIRP_GEN_NUM_SAMPS_OUT_wr_pulse <= '0';
            registers.DIN_TAU_wr_pulse <= '0';
            registers.DIN_T_STEP_wr_pulse <= '0';
            registers.DIN_ALPHA1_wr_pulse <= '0';
            registers.DIN_F_C_wr_pulse <= '0';
            registers.DIN_ALPHA2_wr_pulse <= '0';
            registers.DIN_PHI_wr_pulse <= '0';
            registers.DIN_BETA_wr_pulse <= '0';
            registers.XCORR_REF_SAMP_wr_pulse <= '0';
            registers.XCORR_DOUT_RE_MSBS_wr_pulse <= '0';
            registers.XCORR_DOUT_RE_LSBS_wr_pulse <= '0';
            registers.XCORR_DOUT_IM_MSBS_wr_pulse <= '0';
            registers.XCORR_DOUT_IM_LSBS_wr_pulse <= '0';
            registers.CHIRPLET_FEEDBACK_wr_pulse <= '0';
            s_axi_awready_int <= '1';
            s_axi_wready_int  <= '0';
            awaddr            <= (others => '0');
            wr_state          <= get_addr;

          when get_addr =>
            registers.CONTROL_wr_pulse <= '0';
            registers.STATUS_wr_pulse <= '0';
            registers.CHIRP_GEN_NUM_SAMPS_OUT_wr_pulse <= '0';
            registers.DIN_TAU_wr_pulse <= '0';
            registers.DIN_T_STEP_wr_pulse <= '0';
            registers.DIN_ALPHA1_wr_pulse <= '0';
            registers.DIN_F_C_wr_pulse <= '0';
            registers.DIN_ALPHA2_wr_pulse <= '0';
            registers.DIN_PHI_wr_pulse <= '0';
            registers.DIN_BETA_wr_pulse <= '0';
            registers.XCORR_REF_SAMP_wr_pulse <= '0';
            registers.XCORR_DOUT_RE_MSBS_wr_pulse <= '0';
            registers.XCORR_DOUT_RE_LSBS_wr_pulse <= '0';
            registers.XCORR_DOUT_IM_MSBS_wr_pulse <= '0';
            registers.XCORR_DOUT_IM_LSBS_wr_pulse <= '0';
            registers.CHIRPLET_FEEDBACK_wr_pulse <= '0';
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
                  registers.CONTROL <= s_axi_wdata;
                  registers.CONTROL_wr_pulse <= '1';
                when std_logic_vector(to_unsigned(CHIRP_GEN_NUM_SAMPS_OUT_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.CHIRP_GEN_NUM_SAMPS_OUT <= s_axi_wdata;
                  registers.CHIRP_GEN_NUM_SAMPS_OUT_wr_pulse <= '1';
                when std_logic_vector(to_unsigned(DIN_TAU_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.DIN_TAU <= s_axi_wdata;
                  registers.DIN_TAU_wr_pulse <= '1';
                when std_logic_vector(to_unsigned(DIN_T_STEP_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.DIN_T_STEP <= s_axi_wdata;
                  registers.DIN_T_STEP_wr_pulse <= '1';
                when std_logic_vector(to_unsigned(DIN_ALPHA1_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.DIN_ALPHA1 <= s_axi_wdata;
                  registers.DIN_ALPHA1_wr_pulse <= '1';
                when std_logic_vector(to_unsigned(DIN_F_C_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.DIN_F_C <= s_axi_wdata;
                  registers.DIN_F_C_wr_pulse <= '1';
                when std_logic_vector(to_unsigned(DIN_ALPHA2_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.DIN_ALPHA2 <= s_axi_wdata;
                  registers.DIN_ALPHA2_wr_pulse <= '1';
                when std_logic_vector(to_unsigned(DIN_PHI_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.DIN_PHI <= s_axi_wdata;
                  registers.DIN_PHI_wr_pulse <= '1';
                when std_logic_vector(to_unsigned(DIN_BETA_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.DIN_BETA <= s_axi_wdata;
                  registers.DIN_BETA_wr_pulse <= '1';
                when std_logic_vector(to_unsigned(XCORR_REF_SAMP_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.XCORR_REF_SAMP <= s_axi_wdata;
                  registers.XCORR_REF_SAMP_wr_pulse <= '1';
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
        registers.CONTROL_rd_pulse <= '0';
        registers.STATUS_rd_pulse <= '0';
        registers.CHIRP_GEN_NUM_SAMPS_OUT_rd_pulse <= '0';
        registers.DIN_TAU_rd_pulse <= '0';
        registers.DIN_T_STEP_rd_pulse <= '0';
        registers.DIN_ALPHA1_rd_pulse <= '0';
        registers.DIN_F_C_rd_pulse <= '0';
        registers.DIN_ALPHA2_rd_pulse <= '0';
        registers.DIN_PHI_rd_pulse <= '0';
        registers.DIN_BETA_rd_pulse <= '0';
        registers.XCORR_REF_SAMP_rd_pulse <= '0';
        registers.XCORR_DOUT_RE_MSBS_rd_pulse <= '0';
        registers.XCORR_DOUT_RE_LSBS_rd_pulse <= '0';
        registers.XCORR_DOUT_IM_MSBS_rd_pulse <= '0';
        registers.XCORR_DOUT_IM_LSBS_rd_pulse <= '0';
        registers.CHIRPLET_FEEDBACK_rd_pulse <= '0';
        s_axi_arready_int <= '0';
        s_axi_rvalid_int  <= '0';
        rd_state          <= init;
      else
        case rd_state is
          when init =>
            registers.CONTROL_rd_pulse <= '0';
            registers.STATUS_rd_pulse <= '0';
            registers.CHIRP_GEN_NUM_SAMPS_OUT_rd_pulse <= '0';
            registers.DIN_TAU_rd_pulse <= '0';
            registers.DIN_T_STEP_rd_pulse <= '0';
            registers.DIN_ALPHA1_rd_pulse <= '0';
            registers.DIN_F_C_rd_pulse <= '0';
            registers.DIN_ALPHA2_rd_pulse <= '0';
            registers.DIN_PHI_rd_pulse <= '0';
            registers.DIN_BETA_rd_pulse <= '0';
            registers.XCORR_REF_SAMP_rd_pulse <= '0';
            registers.XCORR_DOUT_RE_MSBS_rd_pulse <= '0';
            registers.XCORR_DOUT_RE_LSBS_rd_pulse <= '0';
            registers.XCORR_DOUT_IM_MSBS_rd_pulse <= '0';
            registers.XCORR_DOUT_IM_LSBS_rd_pulse <= '0';
            registers.CHIRPLET_FEEDBACK_rd_pulse <= '0';
            s_axi_arready_int <= '1';
            s_axi_rvalid_int  <= '0';
            araddr            <= (others => '0');
            rd_state          <= get_addr;

          when get_addr =>
            registers.CONTROL_rd_pulse <= '0';
            registers.STATUS_rd_pulse <= '0';
            registers.CHIRP_GEN_NUM_SAMPS_OUT_rd_pulse <= '0';
            registers.DIN_TAU_rd_pulse <= '0';
            registers.DIN_T_STEP_rd_pulse <= '0';
            registers.DIN_ALPHA1_rd_pulse <= '0';
            registers.DIN_F_C_rd_pulse <= '0';
            registers.DIN_ALPHA2_rd_pulse <= '0';
            registers.DIN_PHI_rd_pulse <= '0';
            registers.DIN_BETA_rd_pulse <= '0';
            registers.XCORR_REF_SAMP_rd_pulse <= '0';
            registers.XCORR_DOUT_RE_MSBS_rd_pulse <= '0';
            registers.XCORR_DOUT_RE_LSBS_rd_pulse <= '0';
            registers.XCORR_DOUT_IM_MSBS_rd_pulse <= '0';
            registers.XCORR_DOUT_IM_LSBS_rd_pulse <= '0';
            registers.CHIRPLET_FEEDBACK_rd_pulse <= '0';
            if s_axi_arvalid = '1' and s_axi_arready_int = '1' then
              s_axi_arready_int <= '0';
              s_axi_rvalid_int  <= '0';
              araddr            <= s_axi_araddr;
              rd_state          <= rd_data;
            end if;

          when rd_data =>
            case araddr is
              when std_logic_vector(to_unsigned(CONTROL_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.CONTROL;
              when std_logic_vector(to_unsigned(STATUS_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.STATUS;
              when std_logic_vector(to_unsigned(CHIRP_GEN_NUM_SAMPS_OUT_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.CHIRP_GEN_NUM_SAMPS_OUT;
              when std_logic_vector(to_unsigned(DIN_TAU_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.DIN_TAU;
              when std_logic_vector(to_unsigned(DIN_T_STEP_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.DIN_T_STEP;
              when std_logic_vector(to_unsigned(DIN_ALPHA1_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.DIN_ALPHA1;
              when std_logic_vector(to_unsigned(DIN_F_C_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.DIN_F_C;
              when std_logic_vector(to_unsigned(DIN_ALPHA2_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.DIN_ALPHA2;
              when std_logic_vector(to_unsigned(DIN_PHI_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.DIN_PHI;
              when std_logic_vector(to_unsigned(DIN_BETA_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.DIN_BETA;
              when std_logic_vector(to_unsigned(XCORR_REF_SAMP_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.XCORR_REF_SAMP;
              when std_logic_vector(to_unsigned(XCORR_DOUT_RE_MSBS_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.XCORR_DOUT_RE_MSBS;
              when std_logic_vector(to_unsigned(XCORR_DOUT_RE_LSBS_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.XCORR_DOUT_RE_LSBS;
              when std_logic_vector(to_unsigned(XCORR_DOUT_IM_MSBS_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.XCORR_DOUT_IM_MSBS;
              when std_logic_vector(to_unsigned(XCORR_DOUT_IM_LSBS_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.XCORR_DOUT_IM_LSBS;
              when std_logic_vector(to_unsigned(CHIRPLET_FEEDBACK_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.CHIRPLET_FEEDBACK;
              when others =>
                null;
            end case;

            if s_axi_rvalid_int = '1' and s_axi_rready = '1' then
              case araddr is
                when std_logic_vector(to_unsigned(CONTROL_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.CONTROL_rd_pulse <= '1';
                when std_logic_vector(to_unsigned(STATUS_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.STATUS_rd_pulse <= '1';
                when std_logic_vector(to_unsigned(CHIRP_GEN_NUM_SAMPS_OUT_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.CHIRP_GEN_NUM_SAMPS_OUT_rd_pulse <= '1';
                when std_logic_vector(to_unsigned(DIN_TAU_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.DIN_TAU_rd_pulse <= '1';
                when std_logic_vector(to_unsigned(DIN_T_STEP_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.DIN_T_STEP_rd_pulse <= '1';
                when std_logic_vector(to_unsigned(DIN_ALPHA1_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.DIN_ALPHA1_rd_pulse <= '1';
                when std_logic_vector(to_unsigned(DIN_F_C_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.DIN_F_C_rd_pulse <= '1';
                when std_logic_vector(to_unsigned(DIN_ALPHA2_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.DIN_ALPHA2_rd_pulse <= '1';
                when std_logic_vector(to_unsigned(DIN_PHI_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.DIN_PHI_rd_pulse <= '1';
                when std_logic_vector(to_unsigned(DIN_BETA_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.DIN_BETA_rd_pulse <= '1';
                when std_logic_vector(to_unsigned(XCORR_REF_SAMP_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.XCORR_REF_SAMP_rd_pulse <= '1';
                when std_logic_vector(to_unsigned(XCORR_DOUT_RE_MSBS_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.XCORR_DOUT_RE_MSBS_rd_pulse <= '1';
                when std_logic_vector(to_unsigned(XCORR_DOUT_RE_LSBS_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.XCORR_DOUT_RE_LSBS_rd_pulse <= '1';
                when std_logic_vector(to_unsigned(XCORR_DOUT_IM_MSBS_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.XCORR_DOUT_IM_MSBS_rd_pulse <= '1';
                when std_logic_vector(to_unsigned(XCORR_DOUT_IM_LSBS_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.XCORR_DOUT_IM_LSBS_rd_pulse <= '1';
                when std_logic_vector(to_unsigned(CHIRPLET_FEEDBACK_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.CHIRPLET_FEEDBACK_rd_pulse <= '1';
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
