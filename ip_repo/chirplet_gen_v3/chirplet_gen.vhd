library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity chirplet_gen is
  port
  (
    clk             : in std_logic;
    reset           : in std_logic;
    enable          : in std_logic;

    num_samps_out   : in  std_logic_vector(15 downto 0);

    din_tau         : in  std_logic_vector(31 downto 0); -- floating point
    din_t_step      : in  std_logic_vector(31 downto 0); -- floating point
    din_alpha1      : in  std_logic_vector(31 downto 0); -- floating point
    din_f_c         : in  std_logic_vector(31 downto 0); -- floating point
    din_alpha2      : in  std_logic_vector(31 downto 0); -- floating point
    din_phi         : in  std_logic_vector(31 downto 0); -- floating point
    din_beta        : in  std_logic_vector(31 downto 0); -- floating point
    din_valid       : in  std_logic;
    din_ready       : out std_logic;

    dout            : out std_logic_vector(31 downto 0);
    dout_valid      : out std_logic;
    dout_ready      : in  std_logic;
    dout_last       : out std_logic
  );
end entity;

architecture rtl of chirplet_gen is

------------------------------------------------------------------------------

  constant C_SIN_LUT_ADDRWIDTH                  : integer range 4 to 18 := 14;
  constant C_EXP_LUT_ADDRWIDTH                  : integer range 4 to 16 := 13;
  constant C_LUT_ONE                            : unsigned((C_SIN_LUT_ADDRWIDTH+1) downto 0) := to_unsigned(2**((C_SIN_LUT_ADDRWIDTH+1)), (C_SIN_LUT_ADDRWIDTH+2));--  "10" & x"0000";

------------------------------------------------------------------------------

  type state_t is (init, fetch_params, generate_chirp, reset_device);
  signal state : state_t;
  signal sample_counter                         : std_logic_vector(15 downto 0);
  signal state_machine_reset                    : std_logic;
  signal internal_reset                         : std_logic;

------------------------------------------------------------------------------

  signal din_tau_store                          : std_logic_vector(31 downto 0);
  signal din_t_step_store                       : std_logic_vector(31 downto 0);
  signal din_alpha1_store                       : std_logic_vector(31 downto 0);
  signal din_f_c_store                          : std_logic_vector(31 downto 0);
  signal din_alpha2_store                       : std_logic_vector(31 downto 0);
  signal din_phi_store                          : std_logic_vector(31 downto 0);
  signal din_beta_store                         : std_logic_vector(31 downto 0);
  signal num_samps_out_store                    : std_logic_vector(15 downto 0);

------------------------------------------------------------------------------

  signal din_valid_latch                        : std_logic;
  signal din_ready_int                          : std_logic;
  signal dout_valid_int                         : std_logic;

------------------------------------------------------------------------------

  signal first_samp                             : std_logic;
  signal time_next                              : std_logic_vector(31 downto 0);
  signal time_next_din_valid                    : std_logic;
  signal time_next_din_ready                    : std_logic;
  signal time_next_dout_valid                   : std_logic;
  signal time_next_dout_ready                   : std_logic;

  signal counter_din1                           : std_logic_vector(31 downto 0);
  signal counter_din2                           : std_logic_vector(31 downto 0);
  signal counter_dout                           : std_logic_vector(31 downto 0);

  signal counter_din_valid                      : std_logic;
  signal counter_din_ready                      : std_logic;
  signal counter_dout_valid                     : std_logic;
  signal counter_dout_ready                     : std_logic;

  signal t_minus_tau_din_valid                  : std_logic;
  signal t_minus_tau_din_ready                  : std_logic;
  signal t_minus_tau_dout_valid                 : std_logic;
  signal t_minus_tau_dout_ready                 : std_logic;

  signal t_minus_tau_sqr_din_valid              : std_logic;
  signal t_minus_tau_sqr_din_ready              : std_logic;
  signal t_minus_tau_sqr_dout_valid             : std_logic;
  signal t_minus_tau_sqr_dout_ready             : std_logic;

  signal t_minus_tau_sqr_alpha_din_valid        : std_logic;
  signal t_minus_tau_sqr_alpha_din_ready        : std_logic;
  signal t_minus_tau_sqr_alpha_dout_valid       : std_logic;
  signal t_minus_tau_sqr_alpha_dout_ready       : std_logic;

  signal rescale_gaussian_din_valid             : std_logic;
  signal rescale_gaussian_din_ready             : std_logic;
  signal rescale_gaussian_dout_valid            : std_logic;
  signal rescale_gaussian_dout_ready            : std_logic;

  signal gaussian_index_din_valid               : std_logic;
  signal gaussian_index_din_ready               : std_logic;
  signal gaussian_index_dout_valid              : std_logic;
  signal gaussian_index_dout_ready              : std_logic;

  signal exp_lut_din_valid                      : std_logic;
  signal exp_lut_din_ready                      : std_logic;
  signal exp_lut_dout_valid                     : std_logic;
  signal exp_lut_dout_ready                     : std_logic;

  signal negative_tau                           : std_logic_vector(31 downto 0);
  signal t_minus_tau                            : std_logic_vector(31 downto 0);
  signal t_minus_tau_sqr                        : std_logic_vector(31 downto 0);
  signal t_minus_tau_sqr_alpha                  : std_logic_vector(31 downto 0);
  signal t_minus_tau_sqr_rescale                : std_logic_vector(31 downto 0);
  signal gaussian_index_dout                    : std_logic_vector(16 downto 0);
  signal gaussian_index_dout_int                : std_logic_vector((C_EXP_LUT_ADDRWIDTH-1) downto 0);
  signal gaussian_index_round                   : std_logic_vector((C_EXP_LUT_ADDRWIDTH-1) downto 0);
  signal exp_lut_dout                           : std_logic_vector(31 downto 0);

------------------------------------------------------------------------------

  signal t_m_tau_times_fc                       : std_logic_vector(31 downto 0);
  signal t_m_tau_times_fc_din_valid             : std_logic;
  signal t_m_tau_times_fc_din_ready             : std_logic;
  signal t_m_tau_times_fc_dout_valid            : std_logic;
  signal t_m_tau_times_fc_dout_ready            : std_logic;

  signal t_m_tau_times_fc_fixed                 : std_logic_vector(25+(C_SIN_LUT_ADDRWIDTH+1)-1 downto 0);
  signal t_m_tau_times_fc_fixed_twos            : std_logic_vector(25+(C_SIN_LUT_ADDRWIDTH+1)-1 downto 0);
  signal t_m_tau_times_fc_fixed_neg_adj         : std_logic_vector((C_SIN_LUT_ADDRWIDTH+1) downto 0);
  signal t_m_tau_times_fc_fixed_dout_valid      : std_logic;
  signal t_m_tau_times_fc_fixed_dout_ready      : std_logic;

  signal fc_sine_lut_din                        : std_logic_vector(C_SIN_LUT_ADDRWIDTH downto 0);
  signal fc_sine_lut_din_round                  : std_logic_vector((C_SIN_LUT_ADDRWIDTH-1) downto 0);

------------------------------------------------------------------------------

  signal t_m_tau_sqrd_times_fc                  : std_logic_vector(31 downto 0);
  signal t_m_tau_sqrd_times_fc_din_valid        : std_logic;
  signal t_m_tau_sqrd_times_fc_din_ready        : std_logic;
  signal t_m_tau_sqrd_times_fc_dout_valid       : std_logic;
  signal t_m_tau_sqrd_times_fc_dout_ready       : std_logic;

  signal t_m_tau_sqrd_times_fc_fixed            : std_logic_vector(25+(C_SIN_LUT_ADDRWIDTH+1)-1 downto 0);
  signal t_m_tau_sqrd_times_fc_fixed_dout_valid : std_logic;
  signal t_m_tau_sqrd_times_fc_fixed_dout_ready : std_logic;

  signal alpha2_sine_lut_din                    : std_logic_vector(C_SIN_LUT_ADDRWIDTH downto 0);
  signal alpha2_sine_lut_din_round              : std_logic_vector((C_SIN_LUT_ADDRWIDTH-1) downto 0);

------------------------------------------------------------------------------

  signal phi_fixed                              : std_logic_vector(25+(C_SIN_LUT_ADDRWIDTH+1)-1 downto 0);
  signal phi_fixed_twos                         : std_logic_vector(25+(C_SIN_LUT_ADDRWIDTH+1)-1 downto 0);
  signal phi_fixed_dout_valid                   : std_logic;
  signal phi_fixed_dout_ready                   : std_logic;

  signal phi_sine_lut_din                       : std_logic_vector(C_SIN_LUT_ADDRWIDTH downto 0);
  signal phi_sine_lut_din_round                 : std_logic_vector((C_SIN_LUT_ADDRWIDTH-1) downto 0);

------------------------------------------------------------------------------

  signal phasor_fixed_added                     : std_logic_vector((C_SIN_LUT_ADDRWIDTH-1) downto 0);
  signal phasor_fixed_added_cos                 : std_logic_vector((C_SIN_LUT_ADDRWIDTH-1) downto 0);
  signal phasor_fixed_added_valid               : std_logic;
  signal phasor_fixed_added_ready               : std_logic;
  signal phasor_dout_real                       : std_logic_vector(31 downto 0);
  signal phasor_dout_imag                       : std_logic_vector(31 downto 0);
  signal phasor_dout_valid                      : std_logic;
  signal phasor_dout_ready                      : std_logic;

------------------------------------------------------------------------------

  signal beta_times_gauss_din_valid             : std_logic;
  signal beta_times_gauss_din_ready             : std_logic;
  signal beta_times_gauss                       : std_logic_vector(31 downto 0);
  signal beta_times_gauss_dout_valid            : std_logic;
  signal beta_times_gauss_dout_ready            : std_logic;

------------------------------------------------------------------------------

  signal complex_mult_din_valid                 : std_logic;
  signal complex_mult_din_ready                 : std_logic;
  signal complex_mult_real                      : std_logic_vector(31 downto 0);
  signal complex_mult_imag                      : std_logic_vector(31 downto 0);
  signal complex_mult_dout_valid                : std_logic;
  signal complex_mult_dout_ready                : std_logic;

------------------------------------------------------------------------------

  signal final_fixed_dout_real                  : std_logic_vector(16 downto 0);
  signal final_fixed_dout_imag                  : std_logic_vector(16 downto 0);
  signal final_fixed_dout_valid                 : std_logic;
  signal final_fixed_dout_ready                 : std_logic;

begin

  p_state_machine : process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' or enable = '0' then
        din_tau_store       <= (others => '0');
        din_t_step_store    <= (others => '0');
        din_alpha1_store    <= (others => '0');
        din_f_c_store       <= (others => '0');
        din_alpha2_store    <= (others => '0');
        din_phi_store       <= (others => '0');
        din_beta_store      <= (others => '0');
        sample_counter      <= (others => '0');
        state_machine_reset <= '0';
        state               <= init;
      else
        case state is
          when init =>
            din_tau_store       <= (others => '0');
            din_t_step_store    <= (others => '0');
            din_alpha1_store    <= (others => '0');
            din_f_c_store       <= (others => '0');
            din_alpha2_store    <= (others => '0');
            din_phi_store       <= (others => '0');
            din_beta_store      <= (others => '0');
            sample_counter      <= (others => '0');
            num_samps_out_store <= (others => '0');
            state_machine_reset <= '0';
            state               <= fetch_params;
          when fetch_params =>
            if din_valid = '1' and din_ready_int = '1' then
              din_tau_store       <= din_tau;
              din_t_step_store    <= din_t_step;
              din_alpha1_store    <= din_alpha1;
              din_f_c_store       <= din_f_c;
              din_alpha2_store    <= din_alpha2;
              din_phi_store       <= din_phi;
              din_beta_store      <= din_beta;
              num_samps_out_store <= num_samps_out;
              state               <= generate_chirp;
            end if;
          when generate_chirp =>
            if dout_valid_int = '1' and dout_ready = '1' then
              if unsigned(sample_counter) = unsigned(num_samps_out_store)-1 then
                sample_counter      <= (others => '0');
                state_machine_reset <= '1';
                state               <= reset_device;
              else
                sample_counter  <= std_logic_vector(unsigned(sample_counter) + 1);
              end if;
            end if;
          when reset_device =>
            state_machine_reset <= '0';
            state               <= init;
          when others =>
            state <= init;
        end case;
      end if;
    end if;
  end process;

  dout_last <= '1' when unsigned(sample_counter) = unsigned(num_samps_out_store)-1 and dout_valid_int = '1' and dout_ready = '1' else '0'; 

  internal_reset  <= reset or state_machine_reset;
  din_valid_latch <= '1' when state = generate_chirp else '0';

  din_ready       <= din_ready_int;
  din_ready_int   <= '1' when state = fetch_params else '0';

  p_time_zero : process(clk)
  begin
    if rising_edge(clk) then
      if internal_reset = '1' or enable = '0' then
        first_samp <= '0';
      else
        if counter_din_valid = '1' and counter_din_ready = '1' then
          first_samp <= '1';
        end if;
      end if;
    end if;
  end process;

  negative_tau(31)          <= din_tau_store(31) xor '1';
  negative_tau(30 downto 0) <= din_tau_store(30 downto 0);


  counter_din1 <= x"3f800000";
  counter_din2 <=
    x"Bf800000" when first_samp = '0' else
    counter_dout;

  counter_din_valid <= din_valid_latch;

  u_counter : entity work.floating_point_add
    generic map
    (
      G_BUFFER_INPUT  => false,
      G_BUFFER_OUTPUT => false
    )
    port map
    (
      clk             => clk,
      reset           => internal_reset,
      enable          => enable,

      din1            => counter_din1,
      din2            => counter_din2,
      din_valid       => counter_din_valid,
      din_ready       => counter_din_ready,
      din_last        => '0',

      dout            => counter_dout,
      dout_valid      => counter_dout_valid,
      dout_ready      => counter_dout_ready,
      dout_last       => open
    );

  time_next_din_valid <= counter_dout_valid;
  counter_dout_ready <= time_next_din_ready;

  u_time_next : entity work.floating_point_mult
    generic map
    (
      G_BUFFER_INPUT  => false,
      G_BUFFER_OUTPUT => true
    )
    port map
    (
      clk             => clk,
      reset           => internal_reset,
      enable          => enable,

      din1            => counter_dout,
      din2            => din_t_step_store,
      din_valid       => time_next_din_valid,
      din_ready       => time_next_din_ready,
      din_last        => '0',

      dout            => time_next,
      dout_valid      => time_next_dout_valid,
      dout_ready      => time_next_dout_ready,
      dout_last       => open
    );

  t_minus_tau_din_valid <= time_next_dout_valid;
  time_next_dout_ready  <= t_minus_tau_din_ready;

  u_t_minus_tau : entity work.floating_point_add
    generic map
    (
      G_BUFFER_INPUT  => false,
      G_BUFFER_OUTPUT => true
    )
    port map
    (
      clk             => clk,
      reset           => internal_reset,
      enable          => enable,
  
      din1            => negative_tau,
      din2            => time_next,
      din_valid       => t_minus_tau_din_valid,
      din_ready       => t_minus_tau_din_ready,
      din_last        => '0',
  
      dout            => t_minus_tau,
      dout_valid      => t_minus_tau_dout_valid,
      dout_ready      => t_minus_tau_dout_ready,
      dout_last       => open
    );

  t_minus_tau_sqr_din_valid <= t_minus_tau_dout_valid and t_minus_tau_dout_ready;
  t_minus_tau_dout_ready    <= t_minus_tau_sqr_din_ready and t_m_tau_times_fc_din_ready;

  u_t_minus_tau_sqr : entity work.floating_point_mult
    generic map
    (
      G_BUFFER_INPUT  => false,
      G_BUFFER_OUTPUT => false
    )
    port map
    (
      clk             => clk,
      reset           => internal_reset,
      enable          => enable,

      din1            => t_minus_tau,
      din2            => t_minus_tau,
      din_valid       => t_minus_tau_sqr_din_valid,
      din_ready       => t_minus_tau_sqr_din_ready,
      din_last        => '0',

      dout            => t_minus_tau_sqr,
      dout_valid      => t_minus_tau_sqr_dout_valid,
      dout_ready      => t_minus_tau_sqr_dout_ready,
      dout_last       => open
    );

  t_minus_tau_sqr_alpha_din_valid <= t_minus_tau_sqr_dout_valid and t_m_tau_sqrd_times_fc_din_ready;
  t_minus_tau_sqr_dout_ready      <= t_minus_tau_sqr_alpha_din_ready and t_m_tau_sqrd_times_fc_din_ready;

  u_t_minus_tau_sqr_alpha : entity work.floating_point_mult
    generic map
    (
      G_BUFFER_INPUT  => false,
      G_BUFFER_OUTPUT => false
    )
    port map
    (
      clk             => clk,
      reset           => internal_reset,
      enable          => enable,

      din1            => t_minus_tau_sqr,
      din2            => din_alpha1_store,
      din_valid       => t_minus_tau_sqr_alpha_din_valid,
      din_ready       => t_minus_tau_sqr_alpha_din_ready,
      din_last        => '0',

      dout            => t_minus_tau_sqr_alpha,
      dout_valid      => t_minus_tau_sqr_alpha_dout_valid,
      dout_ready      => t_minus_tau_sqr_alpha_dout_ready,
      dout_last       => open
    );

  rescale_gaussian_din_valid        <= t_minus_tau_sqr_alpha_dout_valid;
  t_minus_tau_sqr_alpha_dout_ready  <= rescale_gaussian_din_ready;

  u_rescale_gaussian : entity work.floating_point_mult
    generic map
    (
      G_BUFFER_INPUT  => false,
      G_BUFFER_OUTPUT => false
    )
    port map
    (
      clk             => clk,
      reset           => internal_reset,
      enable          => enable,

      din1            => t_minus_tau_sqr_alpha,
      din2            => x"45000000", -- 1024 = 2^16/32
      din_valid       => rescale_gaussian_din_valid,
      din_ready       => rescale_gaussian_din_ready,
      din_last        => '0',

      dout            => t_minus_tau_sqr_rescale,
      dout_valid      => rescale_gaussian_dout_valid,
      dout_ready      => rescale_gaussian_dout_ready,
      dout_last       => open
    );

  gaussian_index_din_valid <= rescale_gaussian_dout_valid;
  rescale_gaussian_dout_ready <= gaussian_index_din_ready;

  u_gaussian_lut_index : entity work.float_to_fixed
    generic map
    (
      G_INTEGER_BITS  => 16,
      G_FRACT_BITS    => 1,
      G_SIGNED_OUTPUT => false,
      G_BUFFER_INPUT  => false,
      G_BUFFER_OUTPUT => false
    )
    port map
    (
      clk             => clk,
      reset           => internal_reset,
      enable          => enable,

      din             => t_minus_tau_sqr_rescale,
      din_valid       => gaussian_index_din_valid,
      din_ready       => gaussian_index_din_ready,
      din_last        => '0',

      dout            => gaussian_index_dout,
      dout_valid      => gaussian_index_dout_valid,
      dout_ready      => gaussian_index_dout_ready,
      dout_last       => open
    );

  --gaussian_index_dout_int <= gaussian_index_dout(C_EXP_LUT_ADDRWIDTH downto 1);
  gaussian_index_dout_int <= gaussian_index_dout(16 downto 16-C_EXP_LUT_ADDRWIDTH + 1);

  gaussian_index_round <=
    gaussian_index_dout_int when gaussian_index_dout(0) = '0' else
    std_logic_vector(unsigned(gaussian_index_dout_int) + 1) when gaussian_index_dout_int /= x"FFFF" else
    gaussian_index_dout_int;

  exp_lut_din_valid <= gaussian_index_dout_valid;
  gaussian_index_dout_ready <= exp_lut_din_ready;

  u_exponential_lut : entity work.exponential_lut
    generic map
    (
      G_BUFFER_INPUT  => false,
      G_BUFFER_OUTPUT => false,
      G_ADDR_WIDTH    => C_EXP_LUT_ADDRWIDTH
    )
    port map
    (
      clk             => clk,
      reset           => internal_reset,
      enable          => enable,

      din             => gaussian_index_round,
      din_valid       => exp_lut_din_valid,
      din_ready       => exp_lut_din_ready,
      din_last        => '0',

      dout            => exp_lut_dout,
      dout_valid      => exp_lut_dout_valid,
      dout_ready      => exp_lut_dout_ready,
      dout_last       => open
    );

--------------------------------------------------------------------------------------------------------------------------------------------------------

  t_m_tau_times_fc_din_valid <= t_minus_tau_dout_valid and t_minus_tau_dout_ready;

  u_t_m_tau_times_fc : entity work.floating_point_mult
    generic map
    (
      G_BUFFER_INPUT  => false,
      G_BUFFER_OUTPUT => false
    )
    port map
    (
      clk             => clk,
      reset           => internal_reset,
      enable          => enable,

      din1            => din_f_c_store,
      din2            => t_minus_tau,
      din_valid       => t_m_tau_times_fc_din_valid,
      din_ready       => t_m_tau_times_fc_din_ready,
      din_last        => '0',

      dout            => t_m_tau_times_fc,
      dout_valid      => t_m_tau_times_fc_dout_valid,
      dout_ready      => t_m_tau_times_fc_dout_ready,
      dout_last       => open
    );

  u_convert_t_m_tau_times_fc : entity work.float_to_fixed
    generic map
    (
      G_INTEGER_BITS  => 25,
      G_FRACT_BITS    => (C_SIN_LUT_ADDRWIDTH+1),
      G_SIGNED_OUTPUT => true,
      G_BUFFER_INPUT  => true,
      G_BUFFER_OUTPUT => false
    )
    port map
    (
      clk             => clk,
      reset           => internal_reset,
      enable          => enable,

      din             => t_m_tau_times_fc,
      din_valid       => t_m_tau_times_fc_dout_valid,
      din_ready       => t_m_tau_times_fc_dout_ready,
      din_last        => '0',

      dout            => t_m_tau_times_fc_fixed,
      dout_valid      => t_m_tau_times_fc_fixed_dout_valid,
      dout_ready      => t_m_tau_times_fc_fixed_dout_ready,
      dout_last       => open
    );

  t_m_tau_times_fc_fixed_dout_ready <=
    phasor_fixed_added_valid and phasor_fixed_added_ready;

  t_m_tau_times_fc_fixed_twos     <= std_logic_vector(unsigned(not t_m_tau_times_fc_fixed) + 1);
  t_m_tau_times_fc_fixed_neg_adj  <= std_logic_vector(C_LUT_ONE - unsigned('0' & t_m_tau_times_fc_fixed_twos(C_SIN_LUT_ADDRWIDTH downto 0)));

  fc_sine_lut_din <=
    t_m_tau_times_fc_fixed(C_SIN_LUT_ADDRWIDTH downto 0) when t_m_tau_times_fc_fixed(t_m_tau_times_fc_fixed'left) = '0' else
    t_m_tau_times_fc_fixed_neg_adj(C_SIN_LUT_ADDRWIDTH downto 0);

  fc_sine_lut_din_round <=
    fc_sine_lut_din(C_SIN_LUT_ADDRWIDTH downto 1) when fc_sine_lut_din(0) = '0' else
    std_logic_vector(unsigned(fc_sine_lut_din(C_SIN_LUT_ADDRWIDTH downto 1)) + 1);

--------------------------------------------------------------------------------------------------------------------------------------------------------

  t_m_tau_sqrd_times_fc_din_valid <= t_minus_tau_sqr_dout_valid and t_minus_tau_sqr_alpha_din_ready;

  u_t_m_tau_sqrd_times_alpha2 : entity work.floating_point_mult
    generic map
    (
      G_BUFFER_INPUT  => false,
      G_BUFFER_OUTPUT => false
    )
    port map
    (
      clk             => clk,
      reset           => internal_reset,
      enable          => enable,

      din1            => din_alpha2_store,
      din2            => t_minus_tau_sqr,
      din_valid       => t_m_tau_sqrd_times_fc_din_valid,
      din_ready       => t_m_tau_sqrd_times_fc_din_ready,
      din_last        => '0',

      dout            => t_m_tau_sqrd_times_fc,
      dout_valid      => t_m_tau_sqrd_times_fc_dout_valid,
      dout_ready      => t_m_tau_sqrd_times_fc_dout_ready,
      dout_last       => open
    );

  u_convert_t_m_tau_sqrd_times_fc : entity work.float_to_fixed
    generic map
    (
      G_INTEGER_BITS  => 25,
      G_FRACT_BITS    => (C_SIN_LUT_ADDRWIDTH+1),
      G_SIGNED_OUTPUT => true,
      G_BUFFER_INPUT  => false,
      G_BUFFER_OUTPUT => false
    )
    port map
    (
      clk             => clk,
      reset           => internal_reset,
      enable          => enable,

      din             => t_m_tau_sqrd_times_fc,
      din_valid       => t_m_tau_sqrd_times_fc_dout_valid,
      din_ready       => t_m_tau_sqrd_times_fc_dout_ready,
      din_last        => '0',

      dout            => t_m_tau_sqrd_times_fc_fixed,
      dout_valid      => t_m_tau_sqrd_times_fc_fixed_dout_valid,
      dout_ready      => t_m_tau_sqrd_times_fc_fixed_dout_ready,
      dout_last       => open
    );

  t_m_tau_sqrd_times_fc_fixed_dout_ready <=
    phasor_fixed_added_valid and phasor_fixed_added_ready;

  alpha2_sine_lut_din <= t_m_tau_sqrd_times_fc_fixed(C_SIN_LUT_ADDRWIDTH downto 0);
  alpha2_sine_lut_din_round <=
    alpha2_sine_lut_din(C_SIN_LUT_ADDRWIDTH downto 1) when alpha2_sine_lut_din(0) = '0' else
    std_logic_vector(unsigned(alpha2_sine_lut_din(C_SIN_LUT_ADDRWIDTH downto 1)) + 1);

--------------------------------------------------------------------------------------------------------------------------------------------------------

  u_convert_phi : entity work.float_to_fixed
    generic map
    (
      G_INTEGER_BITS  => 25,
      G_FRACT_BITS    => (C_SIN_LUT_ADDRWIDTH+1),
      G_SIGNED_OUTPUT => true,
      G_BUFFER_INPUT  => false,
      G_BUFFER_OUTPUT => false
    )
    port map
    (
      clk             => clk,
      reset           => internal_reset,
      enable          => enable,

      din             => din_phi_store,
      din_valid       => '1',
      din_ready       => open,
      din_last        => '0',

      dout            => phi_fixed,
      dout_valid      => phi_fixed_dout_valid,
      dout_ready      => phi_fixed_dout_ready,
      dout_last       => open
    );

  phi_fixed_dout_ready <= '1';

  phi_fixed_twos <= std_logic_vector(unsigned(not phi_fixed) + 1);

  phi_sine_lut_din <=
    phi_fixed(C_SIN_LUT_ADDRWIDTH downto 0) when phi_fixed(phi_fixed'left) = '0' else
    phi_fixed_twos(C_SIN_LUT_ADDRWIDTH downto 0);

  phi_sine_lut_din_round <=
    phi_sine_lut_din(C_SIN_LUT_ADDRWIDTH downto 1) when phi_sine_lut_din(0) = '0' else
    std_logic_vector(unsigned(phi_sine_lut_din(C_SIN_LUT_ADDRWIDTH downto 1)) + 1);

----------------------------------------------------------------------------------------------------------------------------------------------------------

  phasor_fixed_added <=
    std_logic_vector
    (
      unsigned(fc_sine_lut_din_round) +
      unsigned(alpha2_sine_lut_din_round) +
      unsigned(phi_sine_lut_din_round)
    );

  phasor_fixed_added_valid <=
    phi_fixed_dout_valid and t_m_tau_times_fc_fixed_dout_valid and t_m_tau_sqrd_times_fc_fixed_dout_valid;

  u_phasor_sine_lut : entity work.sine_lut
    generic map
    (
      G_BUFFER_INPUT  => true,
      G_BUFFER_OUTPUT => true,
      G_ADDR_WIDTH    => C_SIN_LUT_ADDRWIDTH
    )
    port map
    (
      clk             => clk,
      reset           => internal_reset,
      enable          => enable,

      din             => phasor_fixed_added,
      din_valid       => phasor_fixed_added_valid,
      din_ready       => phasor_fixed_added_ready,
      din_last        => '0',

      dout            => phasor_dout_imag,
      dout_valid      => phasor_dout_valid,
      dout_ready      => phasor_dout_ready,
      dout_last       => open
    );

  phasor_fixed_added_cos <= std_logic_vector(unsigned(phasor_fixed_added) + to_unsigned(2**(C_SIN_LUT_ADDRWIDTH-2), C_SIN_LUT_ADDRWIDTH));

  u_phasor_cos_lut : entity work.sine_lut
    generic map
    (
      G_BUFFER_INPUT  => true,
      G_BUFFER_OUTPUT => true,
      G_ADDR_WIDTH    => C_SIN_LUT_ADDRWIDTH
    )
    port map
    (
      clk             => clk,
      reset           => internal_reset,
      enable          => enable,

      din             => phasor_fixed_added_cos,
      din_valid       => phasor_fixed_added_valid,
      din_ready       => open,
      din_last        => '0',

      dout            => phasor_dout_real,
      dout_valid      => open,
      dout_ready      => phasor_dout_ready,
      dout_last       => open
    );

----------------------------------------------------------------------------------------------------------------------------------------------------------

  beta_times_gauss_din_valid  <= exp_lut_dout_valid;
  exp_lut_dout_ready          <= beta_times_gauss_din_ready;

  u_beta_times_gauss : entity work.floating_point_mult
    generic map
    (
      G_BUFFER_INPUT  => false,
      G_BUFFER_OUTPUT => false
    )
    port map
    (
      clk             => clk,
      reset           => internal_reset,
      enable          => enable,

      din1            => exp_lut_dout,
      din2            => din_beta_store,
      din_valid       => beta_times_gauss_din_valid,
      din_ready       => beta_times_gauss_din_ready,
      din_last        => '0',

      dout            => beta_times_gauss,
      dout_valid      => beta_times_gauss_dout_valid,
      dout_ready      => beta_times_gauss_dout_ready,
      dout_last       => open
    );

----------------------------------------------------------------------------------------------------------------------------------------------------------

  complex_mult_din_valid      <= beta_times_gauss_dout_valid and phasor_dout_valid;
  phasor_dout_ready           <= beta_times_gauss_dout_valid and phasor_dout_valid and complex_mult_din_ready;
  beta_times_gauss_dout_ready <= beta_times_gauss_dout_valid and phasor_dout_valid and complex_mult_din_ready;

  u_complex_mult : entity work.complex_mult_fp
    port map
    (
      clk             => clk,
      reset           => internal_reset,
      enable          => enable,

      din1_real       => beta_times_gauss,
      din1_imag       => (others => '0'),
      din2_real       => phasor_dout_real,
      din2_imag       => phasor_dout_imag,
      din_valid       => complex_mult_din_valid,
      din_ready       => complex_mult_din_ready,
      din_last        => '0',

      dout_real       => complex_mult_real,
      dout_imag       => complex_mult_imag,
      dout_valid      => complex_mult_dout_valid,
      dout_ready      => complex_mult_dout_ready,
      dout_last       => open
    );

  u_final_real_fixed : entity work.float_to_fixed
    generic map
    (
      G_INTEGER_BITS  => 1,
      G_FRACT_BITS    => 16,
      G_SIGNED_OUTPUT => true,
      G_BUFFER_INPUT  => true,
      G_BUFFER_OUTPUT => true
    )
    port map
    (
      clk             => clk,
      reset           => internal_reset,
      enable          => enable,

      din             => complex_mult_real,
      din_valid       => complex_mult_dout_valid,
      din_ready       => complex_mult_dout_ready,
      din_last        => '0',

      dout            => final_fixed_dout_real,
      dout_valid      => final_fixed_dout_valid,
      dout_ready      => final_fixed_dout_ready,
      dout_last       => open
    );

  u_final_imag_fixed : entity work.float_to_fixed
    generic map
    (
      G_INTEGER_BITS  => 1,
      G_FRACT_BITS    => 16,
      G_SIGNED_OUTPUT => true,
      G_BUFFER_INPUT  => true,
      G_BUFFER_OUTPUT => true
    )
    port map
    (
      clk             => clk,
      reset           => internal_reset,
      enable          => enable,

      din             => complex_mult_imag,
      din_valid       => complex_mult_dout_valid,
      din_ready       => open,
      din_last        => '0',

      dout            => final_fixed_dout_imag,
      dout_valid      => open,
      dout_ready      => final_fixed_dout_ready,
      dout_last       => open
    );

  dout                    <= final_fixed_dout_real(16 downto 1) & final_fixed_dout_imag(16 downto 1);
  dout_valid_int          <= '1' when final_fixed_dout_valid = '1' and state = generate_chirp else '0';
  final_fixed_dout_ready  <= dout_ready;
  dout_valid              <= dout_valid_int;

end rtl;
