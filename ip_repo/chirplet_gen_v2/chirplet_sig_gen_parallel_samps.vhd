library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity chirplet_sig_gen_parallel_samps is
  generic
  (
    G_NUM_PARALLEL_GENERATORS : integer range 2 to 32
  );
  port
  (
    clk                       : in std_logic;
    reset                     : in std_logic;
    enable                    : in std_logic;

    num_samps_out             : in  std_logic_vector(15 downto 0);

    din_tau                   : in  std_logic_vector(31 downto 0); -- floating point
    din_t_step                : in  std_logic_vector(31 downto 0); -- floating point
    din_alpha1                : in  std_logic_vector(31 downto 0); -- floating point
    din_f_c                   : in  std_logic_vector(31 downto 0); -- floating point
    din_alpha2                : in  std_logic_vector(31 downto 0); -- floating point
    din_phi                   : in  std_logic_vector(31 downto 0); -- floating point
    din_beta                  : in  std_logic_vector(31 downto 0); -- floating point
    din_valid                 : in  std_logic;
    din_ready                 : out std_logic;
    din_last                  : in  std_logic;

    dout                      : out std_logic_vector((32*G_NUM_PARALLEL_GENERATORS)-1 downto 0);
    dout_valid                : out std_logic;
    dout_ready                : in  std_logic;
    dout_last                 : out std_logic
  );
end entity;

architecture rtl of chirplet_sig_gen_parallel_samps is

  alias G_N : integer range 2 to 32 is G_NUM_PARALLEL_GENERATORS;

  signal g_n_slv            : std_logic_vector(31 downto 0);
  signal time_step_times_n  : std_logic_vector(31 downto 0);

  type float_array_t is array(0 to G_N-1) of std_logic_vector(31 downto 0);
  signal g_i_conv           : float_array_t;
  signal mult_tau           : float_array_t;
  signal negative_mult_tau  : float_array_t;

begin


  u_convert_g_n : entity work.fixed_to_float
    generic map
    (
      G_INTEGER_BITS  => 5,
      G_FRACT_BITS    => 0,
      G_SIGNED_INPUT  => false,
      G_BUFFER_INPUT  => false,
      G_BUFFER_OUTPUT => false
    )
    port map
    (
      clk             => clk,
      reset           => reset,
      enable          => enable,

      din             => std_logic_vector(to_unsigned(G_N, 5)),
      din_valid       => '1',
      din_ready       => open,
      din_last        => '1',

      dout            => g_n_slv,
      dout_valid      => open,
      dout_ready      => '1',
      dout_last       => open
    );

  u_time_step_times_n : entity work.floating_point_mult
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

      din1            => g_n_slv,
      din2            => din_t_step,
      din_valid       => '1',
      din_ready       => open,
      din_last        => '0',

      dout            => open,
      dout_valid      => open,
      dout_ready      => '1',
      dout_last       => open
    );

  g_mult_tau : for i in 0 to G_N-1 generate
    u_conv_i : entity work.fixed_to_float
      generic map
      (
        G_INTEGER_BITS  => 5,
        G_FRACT_BITS    => 0,
        G_SIGNED_INPUT  => false,
        G_BUFFER_INPUT  => false,
        G_BUFFER_OUTPUT => false
      )
      port map
      (
        clk             => clk,
        reset           => reset,
        enable          => enable,

        din             => std_logic_vector(to_unsigned(i, 5)),
        din_valid       => '1',
        din_ready       => open,
        din_last        => '1',

        dout            => g_i_conv(i),
        dout_valid      => open,
        dout_ready      => '1',
        dout_last       => open
      );

    u_mult_tau : entity work.floating_point_mult
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

        din1            => g_i_conv(i),
        din2            => din_t_step,
        din_valid       => '1',
        din_ready       => open,
        din_last        => '0',

        dout            => mult_tau(i),
        dout_valid      => open,
        dout_ready      => '1',
        dout_last       => open
      );

    negative_mult_tau(i) <= (not mult_tau(i)(31)) & (mult_tau(i)(30 downto 0));

    u_add_n_tau : entity work.floating_point_add
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

        din1            => negative_mult_tau(i),
        din2            => din_tau,
        din_valid       => '1',
        din_ready       => open,
        din_last        => '0',

        dout            => open,
        dout_valid      => open,
        dout_ready      => '1',
        dout_last       => open
      );

  end generate;

end rtl;
