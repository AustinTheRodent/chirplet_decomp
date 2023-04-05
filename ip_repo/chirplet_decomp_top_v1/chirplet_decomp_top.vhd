library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.axil_reg_file_pkg.all;

entity chirplet_decomp_top is
  port
  (
    s_axi_aclk    : in  std_logic;
    a_axi_aresetn : in  std_logic;

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
    s_axi_rready  : in  std_logic
  );
end entity;

architecture rtl of chirplet_decomp_top is

  constant C_SAMPLE_DWIDTH            : integer := 32; -- [bits], real + imaginary component
  constant C_NUM_PARALLEL_GENERATORS  : integer := 8;
  constant C_CHIRP2_XCORR_RATIO       : integer := 8;

  signal reset                        : std_logic;
  signal enable                       : std_logic;
  signal registers                    : reg_t;
  signal status_reg                   : std_logic_vector(31 downto 0);

  signal chirp_gen_num_samps_out      : std_logic_vector(15 downto 0);
  signal chirp_gen_din_ready          : std_logic;
  signal chirp_gen_dout               : std_logic_vector(C_SAMPLE_DWIDTH*C_NUM_PARALLEL_GENERATORS-1 downto 0);
  signal chirp_gen_dout_valid         : std_logic;
  signal chirp_gen_dout_ready         : std_logic;
  signal chirp_gen_dout_last          : std_logic;

  signal chrp2xcorr_din               : std_logic_vector(chirp_gen_dout'range);
  signal chrp2xcorr_din_valid         : std_logic;
  signal chrp2xcorr_din_ready         : std_logic;
  signal chrp2xcorr_din_last          : std_logic;
  signal chrp2xcorr_dout              : std_logic_vector(C_SAMPLE_DWIDTH*C_NUM_PARALLEL_GENERATORS*C_CHIRP2_XCORR_RATIO-1 downto 0);
  signal chrp2xcorr_dout_valid        : std_logic;
  signal chrp2xcorr_dout_ready        : std_logic;
  signal chrp2xcorr_dout_last         : std_logic;

  signal ps2xcorr_dout                : std_logic_vector((C_SAMPLE_DWIDTH)*64-1 downto 0);
  signal ps2xcorr_dout_valid          : std_logic;

  signal xcorr_din_real               : std_logic_vector((C_SAMPLE_DWIDTH/2)*64-1 downto 0);
  signal xcorr_din_imag               : std_logic_vector((C_SAMPLE_DWIDTH/2)*64-1 downto 0);
  signal xcorr_din_valid              : std_logic;
  signal xcorr_din_ready              : std_logic;
  signal xcorr_din_last               : std_logic;
  signal xcorr_dout                   : std_logic_vector(0 to 95);
  signal xcorr_dout_dt                : std_logic_vector(95 downto 0);
  signal xcorr_dout_valid             : std_logic;
  signal xcorr_dout_ready             : std_logic;
  signal xcorr_dout_last              : std_logic;

  signal xcorr_ref_din_real           : std_logic_vector((C_SAMPLE_DWIDTH/2)*64-1 downto 0);
  signal xcorr_ref_din_imag           : std_logic_vector((C_SAMPLE_DWIDTH/2)*64-1 downto 0);
  signal xcorr_ref_din_valid          : std_logic;

  signal xcorr_buff_dout              : std_logic_vector(xcorr_dout_dt'range);
  signal xcorr_buff_dout_valid        : std_logic;

  signal xcorr_dout_re_msbs           : std_logic_vector(31 downto 0);
  signal xcorr_dout_re_lsbs           : std_logic_vector(31 downto 0);
  signal xcorr_dout_im_msbs           : std_logic_vector(31 downto 0);
  signal xcorr_dout_im_lsbs           : std_logic_vector(31 downto 0);

  signal sym_decomp_din               : std_logic_vector(chirp_gen_dout'range);
  signal sym_decomp_din_valid         : std_logic;
  signal sym_decomp_din_ready         : std_logic;
  signal sym_decomp_din_last          : std_logic;
  signal sym_decomp_dout              : std_logic_vector(31 downto 0);
  signal sym_decomp_dout_valid        : std_logic;
  signal sym_decomp_dout_ready        : std_logic;
  signal sym_decomp_dout_last         : std_logic;


begin

  reset   <=  not a_axi_aresetn;

  enable  <= registers.CONTROL(0);

  status_reg(31 downto 1) <= (others => '0');

  u_registers : entity work.axil_reg_file
    port map
    (
      s_axi_aclk    => s_axi_aclk,
      a_axi_aresetn => a_axi_aresetn,

      s_STATUS              => status_reg,
      s_XCORR_DOUT_RE_MSBS  => xcorr_dout_re_msbs,
      s_XCORR_DOUT_RE_LSBS  => xcorr_dout_re_lsbs,
      s_XCORR_DOUT_IM_MSBS  => xcorr_dout_im_msbs,
      s_XCORR_DOUT_IM_LSBS  => xcorr_dout_im_lsbs,
      s_CHIRPLET_FEEDBACK   => (others => '0'),

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

  chirp_gen_num_samps_out <= registers.CHIRP_GEN_NUM_SAMPS_OUT(15 downto 0);
  status_reg(0)           <= chirp_gen_din_ready;
  status_reg(1)           <= xcorr_buff_dout_valid;

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

      din_tau                   => registers.DIN_TAU,
      din_t_step                => registers.DIN_T_STEP,
      din_alpha1                => registers.DIN_ALPHA1,
      din_f_c                   => registers.DIN_F_C,
      din_alpha2                => registers.DIN_ALPHA2,
      din_phi                   => registers.DIN_PHI,
      din_beta                  => registers.DIN_BETA,
      din_valid                 => registers.DIN_BETA_wr_pulse,
      din_ready                 => chirp_gen_din_ready,

      dout                      => chirp_gen_dout,
      dout_valid                => chirp_gen_dout_valid,
      dout_ready                => chirp_gen_dout_ready,
      dout_last                 => chirp_gen_dout_last
    );

  chrp2xcorr_din        <= chirp_gen_dout;

  chrp2xcorr_din_valid <=
    chirp_gen_dout_valid when registers.CONTROL(1) = '0' else
    '0';

  chirp_gen_dout_ready <=
    chrp2xcorr_din_ready when registers.CONTROL(1) = '0' else
    sym_decomp_din_ready;

  chrp2xcorr_din_last <=
    chirp_gen_dout_last when registers.CONTROL(1) = '0' else
    '0';


  sym_decomp_din <= chirp_gen_dout;

  sym_decomp_din_valid <=
    chirp_gen_dout_valid when registers.CONTROL(1) = '1' else
    '0';

  sym_decomp_din_last <=
    chirp_gen_dout_last when registers.CONTROL(1) = '1' else
    '0';

  u_symbol_decomp : entity work.symbol_decomp
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

      din                   => sym_decomp_din,
      din_valid             => sym_decomp_din_valid,
      din_ready             => sym_decomp_din_ready,
      din_last              => sym_decomp_din_last,

      dout                  => sym_decomp_dout,
      dout_valid            => sym_decomp_dout_valid,
      dout_ready            => sym_decomp_dout_ready,
      dout_last             => sym_decomp_dout_last
    );

  sym_decomp_dout_ready <=
    '0' when registers.CONTROL(1) = '0' else
    registers.CHIRPLET_FEEDBACK_rd_pulse;


  u_chirp_gen_to_xcorr : entity work.symbol_expander
    generic map
    (
      G_DIN_WIDTH           => chirp_gen_dout'length,
      G_DOUT_OVER_DIN_WIDTH => C_CHIRP2_XCORR_RATIO,
      G_FILL_LSBS_FIRST     => true
    )
    port map
    (
      clk                   => s_axi_aclk,
      reset                 => reset,
      enable                => enable,

      din                   => chrp2xcorr_din,
      din_valid             => chrp2xcorr_din_valid,
      din_ready             => chrp2xcorr_din_ready,
      din_last              => chrp2xcorr_din_last,

      dout                  => chrp2xcorr_dout,
      dout_valid            => chrp2xcorr_dout_valid,
      dout_ready            => chrp2xcorr_dout_ready,
      dout_last             => chrp2xcorr_dout_last
    );

  chrp2xcorr_dout_ready <= '1';

  u_ps_to_xcorr : entity work.symbol_expander
    generic map
    (
      G_DIN_WIDTH           => 32,
      G_DOUT_OVER_DIN_WIDTH => 64,
      G_FILL_LSBS_FIRST     => true
    )
    port map
    (
      clk                   => s_axi_aclk,
      reset                 => reset,
      enable                => enable,

      din                   => registers.XCORR_REF_SAMP,
      din_valid             => registers.XCORR_REF_SAMP_wr_pulse,
      din_ready             => open,
      din_last              => '0',

      dout                  => ps2xcorr_dout,
      dout_valid            => ps2xcorr_dout_valid,
      dout_ready            => '1',
      dout_last             => open
    );

  g_xcorr_input : for i in 0 to 63 generate
    g_flip_bits : for j in 0 to 15 generate
      xcorr_din_real(i*16 + j) <= chrp2xcorr_dout(i*32 + j);
      xcorr_din_imag(i*16 + j) <= chrp2xcorr_dout(i*32+16 + j);
    end generate;
  end generate;

  g_xcorr_ref_input : for i in 0 to 63 generate
    g_flip_ref_bits : for j in 0 to 15 generate
      xcorr_ref_din_real(i*16 + j) <= ps2xcorr_dout(i*32 + j);
      xcorr_ref_din_imag(i*16 + j) <= ps2xcorr_dout(i*32+16 + j);
    end generate;
  end generate;

  xcorr_din_valid     <= chrp2xcorr_dout_valid;
  xcorr_ref_din_valid <= ps2xcorr_dout_valid;

  u_xcorr : entity work.xcorr
    port map
    (
      clk             => s_axi_aclk,

      inputchirp      => xcorr_din_real,
      inputchirpimag  => xcorr_din_imag,
      chirpvalid      => xcorr_din_valid,

      inputsignal     => xcorr_ref_din_real,
      inputsignalimag => xcorr_ref_din_imag,
      signalvalid     => xcorr_ref_din_valid,

      output          => xcorr_dout,
      outvalid        => xcorr_dout_valid
    );

  g_fix_xcorr_dout : for i in 0 to 95 generate
    xcorr_dout_dt(i) <= xcorr_dout(i);
  end generate;

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

      din         => xcorr_dout_dt,
      din_valid   => xcorr_dout_valid,
      din_ready   => open,
      din_last    => '0',

      dout        => xcorr_buff_dout,
      dout_valid  => xcorr_buff_dout_valid,
      dout_ready  => registers.XCORR_DOUT_IM_LSBS_rd_pulse,
      dout_last   => open
    );

end rtl;
