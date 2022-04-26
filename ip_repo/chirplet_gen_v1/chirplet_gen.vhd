library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity chirplet_gen is
  port
  (
    clk             : in std_logic;
    reset           : in std_logic;
    enable          : in std_logic;

    din_tau         : in  std_logic_vector(31 downto 0); -- floating point
    din_t_step      : in  std_logic_vector(31 downto 0); -- floating point
    din_alpha1      : in  std_logic_vector(31 downto 0); -- floating point
    din_f_c         : in  std_logic_vector(31 downto 0); -- floating point
    din_alpha2      : in  std_logic_vector(31 downto 0); -- floating point
    din_phi         : in  std_logic_vector(31 downto 0); -- floating point
    din_beta        : in  std_logic_vector(31 downto 0); -- floating point
    din_valid       : in  std_logic;
    din_ready       : out std_logic;
    din_last        : in  std_logic;

    dout            : out std_logic_vector(31 downto 0);
    dout_valid      : out std_logic;
    dout_ready      : in  std_logic;
    dout_last       : out std_logic
  );
end entity;

architecture rtl of chirplet_gen is

  component axis_buffer is
    generic
    (
      G_DWIDTH    : integer := 8
    );
    port
    (
      clk         : in  std_logic;
      reset       : in  std_logic;
      enable      : in  std_logic;

      din         : in  std_logic_vector(G_DWIDTH-1 downto 0);
      din_valid   : in  std_logic;
      din_ready   : out std_logic;
      din_last    : in  std_logic;

      dout        : out std_logic_vector(G_DWIDTH-1 downto 0);
      dout_valid  : out std_logic;
      dout_ready  : in  std_logic;
      dout_last   : out std_logic
    );
  end component;

  component exponential_lut is -- todo: have this lut extend to exp(64) to keep powers of two
    generic
    (
      G_BUFFER_INPUT  : boolean := false;
      G_BUFFER_OUTPUT : boolean := false
    );
    port
    (
      clk             : in std_logic;
      reset           : in std_logic;
      enable          : in std_logic;

      din             : in  std_logic_vector(15 downto 0);
      din_valid       : in  std_logic;
      din_ready       : out std_logic;
      din_last        : in  std_logic;

      dout            : out std_logic_vector(31 downto 0);
      dout_valid      : out std_logic;
      dout_ready      : in  std_logic;
      dout_last       : out std_logic
    );
  end component;

  component sine_lut is
    generic
    (
      G_BUFFER_INPUT  : boolean := false;
      G_BUFFER_OUTPUT : boolean := false
    );
    port
    (
      clk             : in std_logic;
      reset           : in std_logic;
      enable          : in std_logic;

      din             : in  std_logic_vector(15 downto 0);
      din_valid       : in  std_logic;
      din_ready       : out std_logic;
      din_last        : in  std_logic;

      dout            : out std_logic_vector(31 downto 0);
      dout_valid      : out std_logic;
      dout_ready      : in  std_logic;
      dout_last       : out std_logic
    );
  end component;

  component floating_point_mult is
    generic
    (
      G_BUFFER_INPUT  : boolean := false;
      G_BUFFER_OUTPUT : boolean := false
    );
    port
    (
      clk             : in  std_logic;
      reset           : in  std_logic;
      enable          : in  std_logic;

      din1            : in  std_logic_vector(31 downto 0);
      din2            : in  std_logic_vector(31 downto 0);
      din_valid       : in  std_logic;
      din_ready       : out std_logic;
      din_last        : in  std_logic;

      dout            : out std_logic_vector(31 downto 0);
      dout_valid      : out std_logic;
      dout_ready      : in  std_logic;
      dout_last       : out std_logic
    );
  end component;

  component floating_point_add is
    generic
    (
      G_BUFFER_INPUT  : boolean := false;
      G_BUFFER_OUTPUT : boolean := false
    );
    port
    (
      clk             : in  std_logic;
      reset           : in  std_logic;
      enable          : in  std_logic;

      din1            : in  std_logic_vector(31 downto 0);
      din2            : in  std_logic_vector(31 downto 0);
      din_valid       : in  std_logic;
      din_ready       : out std_logic;
      din_last        : in  std_logic;

      dout            : out std_logic_vector(31 downto 0);
      dout_valid      : out std_logic;
      dout_ready      : in  std_logic;
      dout_last       : out std_logic
    );
  end component;

  component float_to_fixed is
    generic
    (
      G_INTEGER_BITS  : integer range 0 to 64 := 16;
      G_FRACT_BITS    : integer range 0 to 64 := 16;
      G_SIGNED_OUTPUT : boolean := false;
      G_BUFFER_INPUT  : boolean := false;
      G_BUFFER_OUTPUT : boolean := false
    );
    port
    (
      clk             : in std_logic;
      reset           : in std_logic;
      enable          : in std_logic;

      din             : in  std_logic_vector(31 downto 0); -- always uses 32 bit floating point
      din_valid       : in  std_logic;
      din_ready       : out std_logic;
      din_last        : in  std_logic;

      dout            : out std_logic_vector(G_INTEGER_BITS+G_FRACT_BITS-1 downto 0);
      dout_valid      : out std_logic;
      dout_ready      : in  std_logic;
      dout_last       : out std_logic
    );
  end component;
------------------------------------------------------------------------------

  signal din_valid_latch : std_logic;
  signal din_ready_int : std_logic;

------------------------------------------------------------------------------

  signal first_samp           : std_logic;
  signal time_sec             : std_logic_vector(31 downto 0);
  signal time_next            : std_logic_vector(31 downto 0);
  signal time_next_din_valid  : std_logic;
  signal time_next_din_ready  : std_logic;
  signal time_next_dout_valid : std_logic;
  signal time_next_dout_ready : std_logic;

  signal counter_din1       : std_logic_vector(31 downto 0);
  signal counter_din2       : std_logic_vector(31 downto 0);
  signal counter_dout       : std_logic_vector(31 downto 0);

  signal counter_din_valid  : std_logic;
  signal counter_din_ready  : std_logic;
  signal counter_dout_valid  : std_logic;
  signal counter_dout_ready  : std_logic;

  signal t_minus_tau_din_valid  : std_logic;
  signal t_minus_tau_din_ready  : std_logic;
  signal t_minus_tau_dout_valid : std_logic;
  signal t_minus_tau_dout_ready : std_logic;

  signal t_minus_tau_sqr_din_valid  : std_logic;
  signal t_minus_tau_sqr_din_ready  : std_logic;
  signal t_minus_tau_sqr_dout_valid : std_logic;
  signal t_minus_tau_sqr_dout_ready : std_logic;

  signal t_minus_tau_sqr_alpha_din_valid  : std_logic;
  signal t_minus_tau_sqr_alpha_din_ready  : std_logic;
  signal t_minus_tau_sqr_alpha_dout_valid : std_logic;
  signal t_minus_tau_sqr_alpha_dout_ready : std_logic;

  signal rescale_gaussian_din_valid  : std_logic;
  signal rescale_gaussian_din_ready  : std_logic;
  signal rescale_gaussian_dout_valid : std_logic;
  signal rescale_gaussian_dout_ready : std_logic;

  signal gaussian_index_din_valid  : std_logic;
  signal gaussian_index_din_ready  : std_logic;
  signal gaussian_index_dout_valid : std_logic;
  signal gaussian_index_dout_ready : std_logic;

  signal exp_lut_din_valid  : std_logic;
  signal exp_lut_din_ready  : std_logic;
  signal exp_lut_dout_valid : std_logic;
  signal exp_lut_dout_ready : std_logic;

  signal negative_tau             : std_logic_vector(31 downto 0);
  signal negative_tau_din         : std_logic_vector(31 downto 0);
  signal t_minus_tau              : std_logic_vector(31 downto 0);
  signal t_minus_tau_sqr          : std_logic_vector(31 downto 0);
  signal t_minus_tau_sqr_alpha    : std_logic_vector(31 downto 0);
  signal t_minus_tau_sqr_rescale  : std_logic_vector(31 downto 0);
  signal gaussian_index_dout  : std_logic_vector(16 downto 0);
  signal gaussian_index_dout_int  : std_logic_vector(15 downto 0);
  signal gaussian_index_round : std_logic_vector(15 downto 0);
  signal exp_lut_dout : std_logic_vector(31 downto 0);

------------------------------------------------------------------------------

  signal t_m_tau_times_fc             : std_logic_vector(31 downto 0);
  signal t_m_tau_times_fc_din_valid   : std_logic;
  signal t_m_tau_times_fc_din_ready   : std_logic;
  signal t_m_tau_times_fc_dout_valid  : std_logic;
  signal t_m_tau_times_fc_dout_ready  : std_logic;

  signal t_m_tau_times_fc_fixed : std_logic_vector(25+17-1 downto 0);
  signal t_m_tau_times_fc_fixed_twos : std_logic_vector(25+17-1 downto 0);
  signal t_m_tau_times_fc_fixed_dout_valid : std_logic;
  signal t_m_tau_times_fc_fixed_dout_ready : std_logic;

  signal fc_sine_lut_din : std_logic_vector(16 downto 0);
  signal fc_sine_lut_din_round : std_logic_vector(15 downto 0);
  signal fc_cos_lut_din : std_logic_vector(15 downto 0);
  signal fc_sine_lut_dout : std_logic_vector(31 downto 0);
  signal fc_cos_lut_dout : std_logic_vector(31 downto 0);
  signal fc_sine_lut_dout_valid : std_logic;
  signal fc_sine_lut_dout_ready : std_logic;

------------------------------------------------------------------------------

  signal t_m_tau_sqrd_times_fc             : std_logic_vector(31 downto 0);
  signal t_m_tau_sqrd_times_fc_din_valid   : std_logic;
  signal t_m_tau_sqrd_times_fc_din_ready   : std_logic;
  signal t_m_tau_sqrd_times_fc_dout_valid  : std_logic;
  signal t_m_tau_sqrd_times_fc_dout_ready  : std_logic;

  signal t_m_tau_sqrd_times_fc_fixed : std_logic_vector(25+17-1 downto 0);
  signal t_m_tau_sqrd_times_fc_fixed_twos : std_logic_vector(25+17-1 downto 0);
  signal t_m_tau_sqrd_times_fc_fixed_dout_valid : std_logic;
  signal t_m_tau_sqrd_times_fc_fixed_dout_ready : std_logic;

  signal alpha2_sine_lut_din : std_logic_vector(16 downto 0);
  signal alpha2_sine_lut_din_round : std_logic_vector(15 downto 0);
  signal alpha2_cos_lut_din : std_logic_vector(15 downto 0);
  signal alpha2_sine_lut_dout : std_logic_vector(31 downto 0);
  signal alpha2_cos_lut_dout : std_logic_vector(31 downto 0);
  signal alpha2_sine_lut_dout_valid : std_logic;
  signal alpha2_sine_lut_dout_ready : std_logic;

------------------------------------------------------------------------------

  signal phi_fixed                : std_logic_vector(25+17-1 downto 0);
  signal phi_fixed_twos           : std_logic_vector(25+17-1 downto 0);
  signal phi_fixed_dout_valid     : std_logic;
  signal phi_fixed_dout_ready     : std_logic;

  signal phi_sine_lut_din         : std_logic_vector(16 downto 0);
  signal phi_sine_lut_din_round   : std_logic_vector(15 downto 0);
  signal phi_cos_lut_din          : std_logic_vector(15 downto 0);
  signal phi_sine_lut_dout        : std_logic_vector(31 downto 0);
  signal phi_cos_lut_dout         : std_logic_vector(31 downto 0);
  signal phi_sine_lut_dout_valid  : std_logic;
  signal phi_sine_lut_dout_ready  : std_logic;

------------------------------------------------------------------------------

begin

  p_din_valid_latch : process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' or enable = '0' then
        din_valid_latch <= '0';
      else
        if din_valid = '1' and din_ready_int = '1' then
          din_valid_latch <= '1';
        end if;
      end if;
    end if;
  end process;

  din_ready <= din_ready_int;
  din_ready_int <= '1' when din_valid_latch = '0' and counter_din_ready = '1' else '0';

  p_time_zero : process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' or enable = '0' then
        first_samp <= '0';
      else
        if counter_din_valid = '1' and counter_din_ready = '1' then
          first_samp <= '1';
        end if;
      end if;
    end if;
  end process;

  negative_tau(31)          <= din_tau(31) xor '1';
  negative_tau(30 downto 0) <= din_tau(30 downto 0);


  counter_din1 <= x"3f800000";
  counter_din2 <=
    x"Bf800000" when first_samp = '0' else
    counter_dout;

  counter_din_valid <= din_valid_latch;

  u_counter : floating_point_add
    generic map
    (
      G_BUFFER_INPUT  => false,
      G_BUFFER_OUTPUT => false
    )
    port map
    (
      clk             => clk,
      reset           => reset,
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

  u_time_next : floating_point_mult
    generic map
    (
      G_BUFFER_INPUT  => false,
      G_BUFFER_OUTPUT => false
    )
    port map
    (
      clk             => clk,
      reset           => reset,
      enable          => enable,

      din1            => counter_dout,
      din2            => din_t_step,
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

  u_t_minus_tau : floating_point_add
    generic map
    (
      G_BUFFER_INPUT  => false,
      G_BUFFER_OUTPUT => false
    )
    port map
    (
      clk             => clk,
      reset           => reset,
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

  t_minus_tau_sqr_din_valid <= t_minus_tau_dout_valid;
  t_minus_tau_dout_ready    <= t_minus_tau_sqr_din_ready;

  u_t_minus_tau_sqr : floating_point_mult
    generic map
    (
      G_BUFFER_INPUT  => false,
      G_BUFFER_OUTPUT => false
    )
    port map
    (
      clk             => clk,
      reset           => reset,
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

  t_minus_tau_sqr_alpha_din_valid <= t_minus_tau_sqr_dout_valid;
  t_minus_tau_sqr_dout_ready <= t_minus_tau_sqr_alpha_din_ready;

  u_t_minus_tau_sqr_alpha : floating_point_mult
    generic map
    (
      G_BUFFER_INPUT  => false,
      G_BUFFER_OUTPUT => false
    )
    port map
    (
      clk             => clk,
      reset           => reset,
      enable          => enable,

      din1            => t_minus_tau_sqr,
      din2            => din_alpha1,
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

  u_rescale_gaussian : floating_point_mult
    generic map
    (
      G_BUFFER_INPUT  => false,
      G_BUFFER_OUTPUT => false
    )
    port map
    (
      clk             => clk,
      reset           => reset,
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

  u_gaussian_lut_index : float_to_fixed
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
      reset           => reset,
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

  gaussian_index_dout_int <= gaussian_index_dout(16 downto 1);

  gaussian_index_round <=
    gaussian_index_dout_int when gaussian_index_dout(0) = '0' else
    std_logic_vector(unsigned(gaussian_index_dout_int) + 1) when gaussian_index_dout_int /= x"FFFF" else
    gaussian_index_dout_int;

  exp_lut_din_valid <= gaussian_index_dout_valid;
  gaussian_index_dout_ready <= exp_lut_din_ready;


  u_exponential_lut : exponential_lut
    generic map
    (
      G_BUFFER_INPUT  => false,
      G_BUFFER_OUTPUT => false
    )
    port map
    (
      clk             => clk,
      reset           => reset,
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

  exp_lut_dout_ready <= '1';


--------------------------------------------------------------------------------------------------------------------------------------------------------

  t_m_tau_times_fc_din_valid <= t_minus_tau_dout_valid;

  u_t_m_tau_times_fc : floating_point_mult
    generic map
    (
      G_BUFFER_INPUT  => false,
      G_BUFFER_OUTPUT => false
    )
    port map
    (
      clk             => clk,
      reset           => reset,
      enable          => enable,

      din1            => din_f_c,
      din2            => t_minus_tau,
      din_valid       => t_m_tau_times_fc_din_valid,
      din_ready       => t_m_tau_times_fc_din_ready,
      din_last        => '0',

      dout            => t_m_tau_times_fc,
      dout_valid      => t_m_tau_times_fc_dout_valid,
      dout_ready      => t_m_tau_times_fc_dout_ready,
      dout_last       => open
    );

  u_convert_t_m_tau_times_fc : float_to_fixed
    generic map
    (
      G_INTEGER_BITS  => 25,
      G_FRACT_BITS    => 17,
      G_SIGNED_OUTPUT => true,
      G_BUFFER_INPUT  => false,
      G_BUFFER_OUTPUT => false
    )
    port map
    (
      clk             => clk,
      reset           => reset,
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

  t_m_tau_times_fc_fixed_twos <= std_logic_vector(unsigned(not t_m_tau_times_fc_fixed) + 1);

  fc_sine_lut_din <=
    t_m_tau_times_fc_fixed(16 downto 0) when t_m_tau_times_fc_fixed(t_m_tau_times_fc_fixed'left) = '0' else
    t_m_tau_times_fc_fixed_twos(16 downto 0);

  fc_sine_lut_din_round <=
    fc_sine_lut_din(16 downto 1) when fc_sine_lut_din(0) = '0' else
    std_logic_vector(unsigned(fc_sine_lut_din(16 downto 1)) + 1);

  u_fc_sine_lut : sine_lut
    generic map
    (
      G_BUFFER_INPUT  => false,
      G_BUFFER_OUTPUT => false
    )
    port map
    (
      clk             => clk,
      reset           => reset,
      enable          => enable,

      din             => fc_sine_lut_din_round,
      din_valid       => t_m_tau_times_fc_fixed_dout_valid,
      din_ready       => t_m_tau_times_fc_fixed_dout_ready,
      din_last        => '0',

      dout            => fc_sine_lut_dout,
      dout_valid      => fc_sine_lut_dout_valid,
      dout_ready      => fc_sine_lut_dout_ready,
      dout_last       => open
    );

  fc_cos_lut_din <= std_logic_vector(unsigned(fc_sine_lut_din_round) + to_unsigned(49152, 16));

  u_fc_cos_lut : sine_lut
    generic map
    (
      G_BUFFER_INPUT  => false,
      G_BUFFER_OUTPUT => false
    )
    port map
    (
      clk             => clk,
      reset           => reset,
      enable          => enable,

      din             => fc_cos_lut_din,
      din_valid       => t_m_tau_times_fc_fixed_dout_valid,
      din_ready       => open,
      din_last        => '0',

      dout            => fc_cos_lut_dout,
      dout_valid      => open,
      dout_ready      => fc_sine_lut_dout_ready,
      dout_last       => open
    );

  fc_sine_lut_dout_ready <= '1';

--------------------------------------------------------------------------------------------------------------------------------------------------------

  t_m_tau_sqrd_times_fc_din_valid <= t_minus_tau_sqr_dout_valid;

  u_t_m_tau_sqrd_times_alpha2 : floating_point_mult
    generic map
    (
      G_BUFFER_INPUT  => false,
      G_BUFFER_OUTPUT => false
    )
    port map
    (
      clk             => clk,
      reset           => reset,
      enable          => enable,

      din1            => din_alpha2,
      din2            => t_minus_tau_sqr,
      din_valid       => t_m_tau_sqrd_times_fc_din_valid,
      din_ready       => t_m_tau_sqrd_times_fc_din_ready,
      din_last        => '0',

      dout            => t_m_tau_sqrd_times_fc,
      dout_valid      => t_m_tau_sqrd_times_fc_dout_valid,
      dout_ready      => t_m_tau_sqrd_times_fc_dout_ready,
      dout_last       => open
    );

  u_convert_t_m_tau_sqrd_times_fc : float_to_fixed
    generic map
    (
      G_INTEGER_BITS  => 25,
      G_FRACT_BITS    => 17,
      G_SIGNED_OUTPUT => true,
      G_BUFFER_INPUT  => false,
      G_BUFFER_OUTPUT => false
    )
    port map
    (
      clk             => clk,
      reset           => reset,
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

  t_m_tau_sqrd_times_fc_fixed_twos <= std_logic_vector(unsigned(not t_m_tau_sqrd_times_fc_fixed) + 1);

  alpha2_sine_lut_din <=
    t_m_tau_sqrd_times_fc_fixed(16 downto 0) when t_m_tau_sqrd_times_fc_fixed(t_m_tau_sqrd_times_fc_fixed'left) = '0' else
    t_m_tau_sqrd_times_fc_fixed_twos(16 downto 0);

  alpha2_sine_lut_din_round <=
    alpha2_sine_lut_din(16 downto 1) when alpha2_sine_lut_din(0) = '0' else
    std_logic_vector(unsigned(alpha2_sine_lut_din(16 downto 1)) + 1);

  u_alpha2_sine_lut : sine_lut
    generic map
    (
      G_BUFFER_INPUT  => false,
      G_BUFFER_OUTPUT => false
    )
    port map
    (
      clk             => clk,
      reset           => reset,
      enable          => enable,

      din             => alpha2_sine_lut_din_round,
      din_valid       => t_m_tau_sqrd_times_fc_fixed_dout_valid,
      din_ready       => t_m_tau_sqrd_times_fc_fixed_dout_ready,
      din_last        => '0',

      dout            => alpha2_sine_lut_dout,
      dout_valid      => alpha2_sine_lut_dout_valid,
      dout_ready      => alpha2_sine_lut_dout_ready,
      dout_last       => open
    );

  alpha2_cos_lut_din <= std_logic_vector(unsigned(alpha2_sine_lut_din_round) + to_unsigned(49152, 16));

  u_alpha2_cos_lut : sine_lut
    generic map
    (
      G_BUFFER_INPUT  => false,
      G_BUFFER_OUTPUT => false
    )
    port map
    (
      clk             => clk,
      reset           => reset,
      enable          => enable,

      din             => alpha2_cos_lut_din,
      din_valid       => t_m_tau_sqrd_times_fc_fixed_dout_valid,
      din_ready       => open,
      din_last        => '0',

      dout            => alpha2_cos_lut_dout,
      dout_valid      => open,
      dout_ready      => alpha2_sine_lut_dout_ready,
      dout_last       => open
    );

  alpha2_sine_lut_dout_ready <= '1';

--------------------------------------------------------------------------------------------------------------------------------------------------------

  u_convert_phi : float_to_fixed
    generic map
    (
      G_INTEGER_BITS  => 25,
      G_FRACT_BITS    => 17,
      G_SIGNED_OUTPUT => true,
      G_BUFFER_INPUT  => false,
      G_BUFFER_OUTPUT => false
    )
    port map
    (
      clk             => clk,
      reset           => reset,
      enable          => enable,

      din             => din_phi,
      din_valid       => '1',
      din_ready       => open,
      din_last        => '0',

      dout            => phi_fixed,
      dout_valid      => phi_fixed_dout_valid,
      dout_ready      => phi_fixed_dout_ready,
      dout_last       => open
    );

  phi_fixed_twos <= std_logic_vector(unsigned(not phi_fixed) + 1);

  phi_sine_lut_din <=
    phi_fixed(16 downto 0) when phi_fixed(phi_fixed'left) = '0' else
    phi_fixed_twos(16 downto 0);

  phi_sine_lut_din_round <=
    phi_sine_lut_din(16 downto 1) when phi_sine_lut_din(0) = '0' else
    std_logic_vector(unsigned(phi_sine_lut_din(16 downto 1)) + 1);

  u_phi_sine_lut : sine_lut
    generic map
    (
      G_BUFFER_INPUT  => false,
      G_BUFFER_OUTPUT => false
    )
    port map
    (
      clk             => clk,
      reset           => reset,
      enable          => enable,

      din             => phi_sine_lut_din_round,
      din_valid       => phi_fixed_dout_valid,
      din_ready       => phi_fixed_dout_ready,
      din_last        => '0',

      dout            => phi_sine_lut_dout,
      dout_valid      => phi_sine_lut_dout_valid,
      dout_ready      => phi_sine_lut_dout_ready,
      dout_last       => open
    );

  phi_cos_lut_din <= std_logic_vector(unsigned(phi_sine_lut_din_round) + to_unsigned(49152, 16));

  u_phi_cos_lut : sine_lut
    generic map
    (
      G_BUFFER_INPUT  => false,
      G_BUFFER_OUTPUT => false
    )
    port map
    (
      clk             => clk,
      reset           => reset,
      enable          => enable,

      din             => phi_cos_lut_din,
      din_valid       => phi_fixed_dout_valid,
      din_ready       => open,
      din_last        => '0',

      dout            => phi_cos_lut_dout,
      dout_valid      => open,
      dout_ready      => phi_sine_lut_dout_ready,
      dout_last       => open
    );

  phi_sine_lut_dout_ready <= '1';

--------------------------------------------------------------------------------------------------------------------------------------------------------


end rtl;
