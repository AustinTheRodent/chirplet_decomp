library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.axil_reg_file_pkg.all;

entity chirplet_decomp_top is
  port
  (

    led_output                      : out std_logic_vector(1 downto 0);
    gpio0                           : out std_logic;
    gpio1                           : out std_logic;
    gpio2                           : out std_logic;

    s_axi_aclk                      : in  std_logic;
    a_axi_aresetn                   : in  std_logic;

    s_axi_awaddr                    : in  std_logic_vector(C_REG_FILE_ADDR_WIDTH-1 downto 0);
    s_axi_awvalid                   : in  std_logic;
    s_axi_awready                   : out std_logic;

    s_axi_wdata                     : in  std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    s_axi_wstrb                     : in  std_logic_vector(C_REG_FILE_DATA_WIDTH/8-1 downto 0);
    s_axi_wvalid                    : in  std_logic;
    s_axi_wready                    : out std_logic;

    s_axi_bresp                     : out std_logic_vector(1 downto 0);
    s_axi_bvalid                    : out std_logic;
    s_axi_bready                    : in  std_logic;

    s_axi_araddr                    : in  std_logic_vector(C_REG_FILE_ADDR_WIDTH-1 downto 0);
    s_axi_arvalid                   : in  std_logic;
    s_axi_arready                   : out std_logic;

    s_axi_rdata                     : out std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    s_axi_rresp                     : out std_logic_vector(1 downto 0);
    s_axi_rvalid                    : out std_logic;
    s_axi_rready                    : in  std_logic;

    s_axis_reference_aclk           : in  std_logic;
    s_axis_reference_tdata          : in  std_logic_vector(31 downto 0);
    s_axis_reference_tvalid         : in  std_logic;
    s_axis_reference_tready         : out std_logic;
    s_axis_reference_tlast          : in  std_logic;

    m_axis_estimate_chirplet_aclk   : in  std_logic;
    m_axis_estimate_chirplet_tdata  : out std_logic_vector(31 downto 0);
    m_axis_estimate_chirplet_tvalid : out std_logic;
    m_axis_estimate_chirplet_tready : in  std_logic;
    m_axis_estimate_chirplet_tlast  : out std_logic

  );
end entity;

architecture rtl of chirplet_decomp_top is

  constant C_SAMPLE_DWIDTH            : integer := 32; -- [bits], real + imaginary component
  constant C_NUM_PARALLEL_GENERATORS  : integer := 8;
  constant C_CHIRP2_XCORR_RATIO       : integer := 8;

  signal reset                        : std_logic;
  signal enable                       : std_logic;
  signal registers                    : reg_t;

  signal chirp_gen_num_samps_out      : std_logic_vector(15 downto 0);
  signal chirp_gen_din_ready          : std_logic;
  signal chirp_gen_dout               : std_logic_vector(C_SAMPLE_DWIDTH*C_NUM_PARALLEL_GENERATORS-1 downto 0);
  signal chirp_gen_dout_valid         : std_logic;
  signal chirp_gen_dout_ready         : std_logic;
  signal chirp_gen_dout_last          : std_logic;

  --signal chrp2xcorr_din               : std_logic_vector(chirp_gen_dout'range);
  --signal chrp2xcorr_din_valid         : std_logic;
  --signal chrp2xcorr_din_ready         : std_logic;
  --signal chrp2xcorr_din_last          : std_logic;
  --signal chrp2xcorr_dout              : std_logic_vector(C_SAMPLE_DWIDTH*C_NUM_PARALLEL_GENERATORS*C_CHIRP2_XCORR_RATIO-1 downto 0);
  --signal chrp2xcorr_dout_valid        : std_logic;
  --signal chrp2xcorr_dout_ready        : std_logic;
  --signal chrp2xcorr_dout_last         : std_logic;

  signal ps2xcorr_dout                : std_logic_vector((C_SAMPLE_DWIDTH)*C_NUM_PARALLEL_GENERATORS-1 downto 0);
  signal ps2xcorr_dout_valid          : std_logic;

  signal xcorr_din_real               : std_logic_vector((C_SAMPLE_DWIDTH/2)*C_NUM_PARALLEL_GENERATORS-1 downto 0);
  signal xcorr_din_imag               : std_logic_vector((C_SAMPLE_DWIDTH/2)*C_NUM_PARALLEL_GENERATORS-1 downto 0);
  signal xcorr_din_valid              : std_logic;
  signal xcorr_din_ready              : std_logic;
  signal xcorr_din_last               : std_logic;
  signal xcorr_dout                   : std_logic_vector(95 downto 0);
  --signal xcorr_dout_dt                : std_logic_vector(95 downto 0);
  signal xcorr_dout_valid             : std_logic;
  signal xcorr_dout_ready             : std_logic;
  signal xcorr_dout_last              : std_logic;

  signal xcorr_ref_din_real           : std_logic_vector((C_SAMPLE_DWIDTH/2)*C_NUM_PARALLEL_GENERATORS-1 downto 0);
  signal xcorr_ref_din_imag           : std_logic_vector((C_SAMPLE_DWIDTH/2)*C_NUM_PARALLEL_GENERATORS-1 downto 0);
  signal xcorr_ref_din_valid          : std_logic;

  signal xcorr_buff_dout              : std_logic_vector(xcorr_dout'range);
  signal xcorr_buff_dout_valid        : std_logic;
  signal xcorr_buff_dout_ready        : std_logic;

  signal xcorr_dout_re_msbs           : std_logic_vector(31 downto 0);
  signal xcorr_dout_re_lsbs           : std_logic_vector(31 downto 0);
  signal xcorr_dout_im_msbs           : std_logic_vector(31 downto 0);
  signal xcorr_dout_im_lsbs           : std_logic_vector(31 downto 0);

  signal est_to_ps_din               : std_logic_vector(chirp_gen_dout'range);
  signal est_to_ps_din_valid         : std_logic;
  signal est_to_ps_din_ready         : std_logic;
  signal est_to_ps_din_last          : std_logic;
  signal est_to_ps_dout              : std_logic_vector(31 downto 0);
  signal est_to_ps_dout_valid        : std_logic;
  signal est_to_ps_dout_ready        : std_logic;
  signal est_to_ps_dout_last         : std_logic;

  signal m_axis_estimate_chirplet_tdata_int  :std_logic_vector(31 downto 0);
  signal m_axis_estimate_chirplet_tvalid_int : std_logic;
  signal m_axis_estimate_chirplet_tlast_int  : std_logic;

begin

  m_axis_estimate_chirplet_tdata  <= est_to_ps_dout;
  m_axis_estimate_chirplet_tvalid <= est_to_ps_dout_valid;
  est_to_ps_dout_ready           <= m_axis_estimate_chirplet_tready;
  m_axis_estimate_chirplet_tlast  <= est_to_ps_dout_last;

  --m_axis_estimate_chirplet_tdata  <= m_axis_estimate_chirplet_tdata_int;
  --m_axis_estimate_chirplet_tvalid <= m_axis_estimate_chirplet_tvalid_int;
  --m_axis_estimate_chirplet_tlast  <= m_axis_estimate_chirplet_tlast_int;
  --
  --p_dout_stream_test : process(m_axis_estimate_chirplet_aclk)
  --begin
  --  if rising_edge(m_axis_estimate_chirplet_aclk) then
  --    if reset = '1' or enable = '0' then
  --      m_axis_estimate_chirplet_tdata_int  <= (others => '0');
  --    else
  --      if m_axis_estimate_chirplet_tvalid_int = '1' and m_axis_estimate_chirplet_tready = '1' then
  --        if unsigned(m_axis_estimate_chirplet_tdata_int) = 511 then
  --          m_axis_estimate_chirplet_tdata_int <= (others => '0');
  --        else
  --          m_axis_estimate_chirplet_tdata_int <= std_logic_vector(unsigned(m_axis_estimate_chirplet_tdata_int) + 1);
  --        end if;
  --      end if;
  --    end if;
  --  end if;
  --end process;
  --
  --m_axis_estimate_chirplet_tvalid_int <= (not reset) and enable;
  --
  --m_axis_estimate_chirplet_tlast_int <=
  --  m_axis_estimate_chirplet_tvalid_int when unsigned(m_axis_estimate_chirplet_tdata_int) = 511 else
  --  '0';

  led_output  <= registers.LED_CONTROL_REG(1 downto 0);
  gpio0       <= registers.GPIO_REG(0);
  gpio1       <= registers.GPIO_REG(1);
  gpio2       <= registers.GPIO_REG(2);

  reset   <=  not a_axi_aresetn;
  enable  <= registers.CONTROL.ENABLE(0);

  u_registers : entity work.axil_reg_file
    port map
    (
      s_axi_aclk    => s_axi_aclk,
      a_axi_aresetn => a_axi_aresetn,

      s_STATUS_CHIRP_GEN_READY(0)               => chirp_gen_din_ready,
      s_STATUS_CHIRP_GEN_READY_v                => '1',

      s_STATUS_XCORR_DOUT_VALID(0)              => xcorr_buff_dout_valid,
      s_STATUS_XCORR_DOUT_VALID_v               => '1',

      s_XCORR_DOUT_RE_MSBS_XCORR_DOUT_RE_MSBS   => xcorr_dout_re_msbs,
      s_XCORR_DOUT_RE_MSBS_XCORR_DOUT_RE_MSBS_v => '1',

      s_XCORR_DOUT_RE_LSBS_XCORR_DOUT_RE_LSBS   => xcorr_dout_re_lsbs,
      s_XCORR_DOUT_RE_LSBS_XCORR_DOUT_RE_LSBS_v => '1',

      s_XCORR_DOUT_IM_MSBS_XCORR_DOUT_IM_MSBS   => xcorr_dout_im_msbs,
      s_XCORR_DOUT_IM_MSBS_XCORR_DOUT_IM_MSBS_v => '1',

      s_XCORR_DOUT_IM_LSBS_XCORR_DOUT_IM_LSBS   => xcorr_dout_im_lsbs,
      s_XCORR_DOUT_IM_LSBS_XCORR_DOUT_IM_LSBS_v => '1',

      s_XCORR_DOUT_RE32_XCORR_DOUT_RE32         => xcorr_buff_dout(xcorr_buff_dout'length-1 downto xcorr_buff_dout'length-32),
      s_XCORR_DOUT_RE32_XCORR_DOUT_RE32_v       => '1',

      s_XCORR_DOUT_IM32_XCORR_DOUT_IM32         => xcorr_buff_dout(xcorr_buff_dout'length/2-1 downto xcorr_buff_dout'length/2-32),
      s_XCORR_DOUT_IM32_XCORR_DOUT_IM32_v       => '1',

      s_CHIRPLET_FEEDBACK_CHIRPLET_FEEDBACK     => (others => '0'),
      s_CHIRPLET_FEEDBACK_CHIRPLET_FEEDBACK_v   => '1',

      s_axi_awaddr  => s_axi_awaddr,
      s_axi_awvalid => s_axi_awvalid,
      s_axi_awready => s_axi_awready,

      s_axi_wdata   => s_axi_wdata,
      s_axi_wstrb   => s_axi_wstrb,
      s_axi_wvalid  => s_axi_wvalid,
      s_axi_wready  => s_axi_wready,

      s_axi_bresp   => s_axi_bresp,
      s_axi_bvalid  => s_axi_bvalid,
      s_axi_bready  => s_axi_bready,

      s_axi_araddr  => s_axi_araddr,
      s_axi_arvalid => s_axi_arvalid,
      s_axi_arready => s_axi_arready,

      s_axi_rdata   => s_axi_rdata,
      s_axi_rresp   => s_axi_rresp,
      s_axi_rvalid  => s_axi_rvalid,
      s_axi_rready  => s_axi_rready,

      registers_out => registers
    );

  xcorr_dout_re_msbs      <= x"0000" & xcorr_buff_dout(95 downto 80);
  xcorr_dout_re_lsbs      <= xcorr_buff_dout(79 downto 48);
  xcorr_dout_im_msbs      <= x"0000" & xcorr_buff_dout(47 downto 32);
  xcorr_dout_im_lsbs      <= xcorr_buff_dout(31 downto 0);

  chirp_gen_num_samps_out <= registers.CHIRP_GEN_NUM_SAMPS_OUT_REG(15 downto 0);

  u_chirp_gen : entity work.chirplet_sig_gen_parallel_samps
    generic map
    (
      G_NUM_PARALLEL_GENERATORS => C_NUM_PARALLEL_GENERATORS,
      G_FILL_LSBS_FIRST         => true
    )
    port map
    (
      clk                       => s_axi_aclk,
      reset                     => reset,
      enable                    => enable,

      num_samps_out             => chirp_gen_num_samps_out,

      din_tau                   => registers.DIN_TAU_REG,
      din_t_step                => registers.DIN_T_STEP_REG,
      din_alpha1                => registers.DIN_ALPHA1_REG,
      din_f_c                   => registers.DIN_F_C_REG,
      din_alpha2                => registers.DIN_ALPHA2_REG,
      din_phi                   => registers.DIN_PHI_REG,
      din_beta                  => registers.DIN_BETA_REG,
      din_valid                 => registers.DIN_BETA_REG_wr_pulse,
      din_ready                 => chirp_gen_din_ready,

      dout                      => chirp_gen_dout,
      dout_valid                => chirp_gen_dout_valid,
      dout_ready                => chirp_gen_dout_ready,
      dout_last                 => chirp_gen_dout_last
    );

  est_to_ps_din <= chirp_gen_dout;

  est_to_ps_din_valid <=
    chirp_gen_dout_valid when registers.CONTROL.FEEDBACK_MODE = "1" else
    '0';

  est_to_ps_din_last <=
    chirp_gen_dout_last when registers.CONTROL.FEEDBACK_MODE = "1" else
    '0';

  u_chirp2ps : entity work.symbol_decomp
    generic map
    (
      G_DIN_WIDTH           => chirp_gen_dout'length,
      G_DIN_OVER_DOUT_WIDTH => C_NUM_PARALLEL_GENERATORS,
      G_READ_LSBS_FIRST     => true
    )
    port map
    (
      clk                   => s_axi_aclk,
      reset                 => reset,
      enable                => enable,

      din                   => est_to_ps_din,
      din_valid             => est_to_ps_din_valid,
      din_ready             => est_to_ps_din_ready,
      din_last              => est_to_ps_din_last,

      dout                  => est_to_ps_dout,
      dout_valid            => est_to_ps_dout_valid,
      dout_ready            => est_to_ps_dout_ready,
      dout_last             => est_to_ps_dout_last
    );

  u_ps_to_xcorr : entity work.symbol_expander
    generic map
    (
      G_DIN_WIDTH           => 32,
      G_DOUT_OVER_DIN_WIDTH => C_NUM_PARALLEL_GENERATORS,
      G_FILL_LSBS_FIRST     => true
    )
    port map
    (
      clk                   => s_axis_reference_aclk,
      reset                 => reset,
      enable                => enable,

      din                   => s_axis_reference_tdata,
      din_valid             => s_axis_reference_tvalid,
      din_ready             => s_axis_reference_tready,
      din_last              => s_axis_reference_tlast,

      dout                  => ps2xcorr_dout,
      dout_valid            => ps2xcorr_dout_valid,
      dout_ready            => '1',
      dout_last             => open
    );

  g_xcorr_input : for i in C_NUM_PARALLEL_GENERATORS-1 downto 0 generate
    --g_real_bits : for i C_SAMPLE_DWIDTH/2-1 downto 0 generate
    xcorr_din_real((C_SAMPLE_DWIDTH/2)*(i+1)-1 downto (C_SAMPLE_DWIDTH/2)*i) <= chirp_gen_dout((C_SAMPLE_DWIDTH/2)*(i*2+1)-1 downto (C_SAMPLE_DWIDTH/2)*i*2);
    xcorr_din_imag((C_SAMPLE_DWIDTH/2)*(i+1)-1 downto (C_SAMPLE_DWIDTH/2)*i) <= chirp_gen_dout((C_SAMPLE_DWIDTH/2)*(i*2+2)-1 downto (C_SAMPLE_DWIDTH/2)*(i*2+1));
    --end generate;
  end generate;

  g_xcorr_ref_input : for i in C_NUM_PARALLEL_GENERATORS-1 downto 0 generate
    xcorr_ref_din_real((C_SAMPLE_DWIDTH/2)*(i+1)-1 downto (C_SAMPLE_DWIDTH/2)*i) <= ps2xcorr_dout((C_SAMPLE_DWIDTH/2)*(i*2+1)-1 downto (C_SAMPLE_DWIDTH/2)*i*2);
    xcorr_ref_din_imag((C_SAMPLE_DWIDTH/2)*(i+1)-1 downto (C_SAMPLE_DWIDTH/2)*i) <= ps2xcorr_dout((C_SAMPLE_DWIDTH/2)*(i*2+2)-1 downto (C_SAMPLE_DWIDTH/2)*(i*2+1));
  end generate;

  xcorr_din_valid <=
    chirp_gen_dout_valid when registers.CONTROL.FEEDBACK_MODE = "0" else
    '0';

  chirp_gen_dout_ready <=
    '1' when registers.CONTROL.FEEDBACK_MODE = "0" else
    est_to_ps_din_ready;

  xcorr_ref_din_valid <= ps2xcorr_dout_valid;

  u_xcorr : entity work.xcorr
    generic map
    (
      G_DWIDTH                => 16,  -- single rail, I or Q
      G_SAMPS_PER_CLK         => 8,   -- samples processed per clock cycle
      G_MULTISAMPS_PROCESSED  => 64,  -- number of clock cycles used to fully accept data
      G_LOG2_SAMPS            => 9,
      G_BRAM_ADDRWIDTH        => 6
    )
    port map
    (
      clk                     => s_axi_aclk,
      reset                   => reset,
      enable                  => enable,

      ref_real                => xcorr_ref_din_real,
      ref_imag                => xcorr_ref_din_imag,
      ref_valid               => xcorr_ref_din_valid,

      est_chirp_re            => xcorr_din_real,
      est_chirp_im            => xcorr_din_imag,
      est_chirp_valid         => xcorr_din_valid,

      output                  => xcorr_dout,
      outvalid                => xcorr_dout_valid

    );

  --xcorr_dout_dt <= xcorr_dout;

  --g_fix_xcorr_dout : for i in 0 to 95 generate
  --  xcorr_dout_dt(i) <= xcorr_dout(i);
  --end generate;

  u_xcorr_buff : entity work.axis_buffer
    generic map
    (
      G_DWIDTH    => xcorr_dout'length
    )
    port map
    (
      clk         => s_axi_aclk,
      reset       => reset,
      enable      => enable,

      din         => xcorr_dout,
      din_valid   => xcorr_dout_valid,
      din_ready   => open,
      din_last    => '0',

      dout        => xcorr_buff_dout,
      dout_valid  => xcorr_buff_dout_valid,
      dout_ready  => xcorr_buff_dout_ready,
      dout_last   => open
    );

  xcorr_buff_dout_ready <= registers.XCORR_DOUT_IM_LSBS_REG_rd_pulse or registers.XCORR_DOUT_IM32_REG_rd_pulse;

end rtl;
