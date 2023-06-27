library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity chirplet_sig_gen_parallel_samps is
  generic
  (
    G_NUM_PARALLEL_GENERATORS : integer range 2 to 32 := 2;
    G_FILL_LSBS_FIRST         : boolean               := true
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

    dout                      : out std_logic_vector((32*G_NUM_PARALLEL_GENERATORS)-1 downto 0);
    dout_valid                : out std_logic;
    dout_ready                : in  std_logic;
    dout_last                 : out std_logic
  );
end entity;

architecture rtl of chirplet_sig_gen_parallel_samps is

  constant C_WAIT_FOR_SETTINGS_LIM  : integer := 2;

  alias G_N : integer range 2 to 32 is G_NUM_PARALLEL_GENERATORS;

  signal din_ready_int              : std_logic;
  signal dout_valid_int             : std_logic_vector(G_N-1 downto 0);
  signal dout_last_int              : std_logic_vector(G_N-1 downto 0);

  signal g_n_slv                    : std_logic_vector(31 downto 0);
  signal time_step_times_n          : std_logic_vector(31 downto 0);

  type state_t is (init, get_params, wait_for_settings, pulse_valid, wait_for_last, reset_chirplet_gen);
  signal state                      : state_t;

  type float_array_t is array(0 to G_N-1) of std_logic_vector(31 downto 0);
  signal g_i_conv                   : float_array_t;
  signal mult_tau                   : float_array_t;
  signal negative_mult_tau          : float_array_t;
  signal added_tau                  : float_array_t;
  signal single_chirp_dout          : float_array_t;

  signal single_chirp_reset         : std_logic;
  signal single_chirp_reset_full    : std_logic;
  --signal single_chirp_dout          : std_logic_vector(31 downto 0);
  signal single_chirp_din_valid     : std_logic;
  signal din_t_step_mult            : std_logic_vector(31 downto 0);
  signal din_tau_store              : std_logic_vector(31 downto 0);
  signal din_t_step_store           : std_logic_vector(31 downto 0);
  signal din_alpha1_store           : std_logic_vector(31 downto 0);
  signal din_f_c_store              : std_logic_vector(31 downto 0);
  signal din_alpha2_store           : std_logic_vector(31 downto 0);
  signal din_phi_store              : std_logic_vector(31 downto 0);
  signal din_beta_store             : std_logic_vector(31 downto 0);
  signal num_samps_out_store        : std_logic_vector(15 downto 0);

begin

  din_ready     <= din_ready_int;
  dout_valid    <= dout_valid_int(0);
  dout_last     <= dout_last_int(0);

  din_ready_int <= '1' when state = get_params else '0';

  p_state_machine : process(clk)
    variable v_wait_counter : integer range 0 to 2**8-1;
  begin
    if rising_edge(clk) then
      if reset = '1' or enable = '0' then
        single_chirp_reset      <= '1';
        single_chirp_din_valid  <= '0';
        din_tau_store           <= (others => '0');
        din_t_step_store        <= (others => '0');
        din_alpha1_store        <= (others => '0');
        din_f_c_store           <= (others => '0');
        din_alpha2_store        <= (others => '0');
        din_phi_store           <= (others => '0');
        din_beta_store          <= (others => '0');
        num_samps_out_store     <= (others => '0');
        state                   <= init;
        v_wait_counter          := 0;
      else
        case state is
          when init =>
            single_chirp_reset  <= '0';
            single_chirp_din_valid  <= '0';
            din_tau_store           <= (others => '0');
            din_t_step_store        <= (others => '0');
            din_alpha1_store        <= (others => '0');
            din_f_c_store           <= (others => '0');
            din_alpha2_store        <= (others => '0');
            din_phi_store           <= (others => '0');
            din_beta_store          <= (others => '0');
            num_samps_out_store     <= (others => '0');
            state                   <= get_params;
            v_wait_counter          := 0;

          when get_params =>
            if din_valid = '1' and din_ready_int = '1' then
              din_tau_store       <= din_tau;
              din_t_step_store    <= din_t_step;
              din_alpha1_store    <= din_alpha1;
              din_f_c_store       <= din_f_c;
              din_alpha2_store    <= din_alpha2;
              din_phi_store       <= din_phi;
              din_beta_store      <= din_beta;
              num_samps_out_store <= num_samps_out;
              state               <= wait_for_settings;
            end if;

          when wait_for_settings =>
            if v_wait_counter = C_WAIT_FOR_SETTINGS_LIM-1 then
              single_chirp_din_valid  <= '1';
              state                   <= pulse_valid;
              v_wait_counter          := 0;
            else
              v_wait_counter          := v_wait_counter + 1;
            end if;
            
          when pulse_valid =>
            single_chirp_din_valid    <= '0';
            state                     <= wait_for_last;

          when wait_for_last =>
            if dout_valid_int(0) = '1' and dout_last_int(0) = '1' then
              single_chirp_reset  <= '1';
              state               <= reset_chirplet_gen;
            end if;

          when reset_chirplet_gen =>
            single_chirp_reset  <= '0';
            state               <= get_params;

          when others =>
            state <= init;
        end case;
      end if;
    end if;
  end process;

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
      din2            => din_t_step_store,
      din_valid       => '1',
      din_ready       => open,
      din_last        => '0',

      dout            => din_t_step_mult,
      dout_valid      => open,
      dout_ready      => '1',
      dout_last       => open
    );

  single_chirp_reset_full <= reset or single_chirp_reset;

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
        din2            => din_t_step_store,
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
        din2            => din_tau_store,
        din_valid       => '1',
        din_ready       => open,
        din_last        => '0',

        dout            => added_tau(i),
        dout_valid      => open,
        dout_ready      => '1',
        dout_last       => open
      );

    u_chirplet_gen_single : entity work.chirplet_gen
      port map
      (
        clk             => clk,
        reset           => single_chirp_reset_full,
        enable          => enable,

        num_samps_out   => num_samps_out_store,

        din_tau         => added_tau(i),
        din_t_step      => din_t_step_mult,
        din_alpha1      => din_alpha1_store,
        din_f_c         => din_f_c_store,
        din_alpha2      => din_alpha2_store,
        din_phi         => din_phi_store,
        din_beta        => din_beta_store,
        din_valid       => single_chirp_din_valid,
        din_ready       => open,

        dout            => single_chirp_dout(i),
        dout_valid      => dout_valid_int(i),
        dout_ready      => dout_ready,
        dout_last       => dout_last_int(i)
      );

    dout((i+1)*32-1 downto i*32) <=
      single_chirp_dout(i) when G_FILL_LSBS_FIRST = true else
      single_chirp_dout(G_N-1 - i);

  end generate;

end rtl;
