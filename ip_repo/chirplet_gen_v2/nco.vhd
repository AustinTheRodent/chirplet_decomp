library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity nco is
  port
  (
    clk             : in std_logic;
    reset           : in std_logic;
    enable          : in std_logic;

    t_minus_tau_0   : in  std_logic_vector(31 downto 0); -- floating point
    din_t_step      : in  std_logic_vector(31 downto 0); -- floating point, sample period
    din_f_out       : in  std_logic_vector(31 downto 0); -- floating point
    din_valid       : in  std_logic;
    din_ready       : out std_logic;
    din_last        : in  std_logic;

    dout            : out std_logic_vector(31 downto 0);
    dout_valid      : out std_logic;
    dout_ready      : in  std_logic;
    dout_last       : out std_logic
  );
end entity;

architecture rtl of nco is

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

  component floating_point_mult is
    port
    (
      clk         : in  std_logic;
      reset       : in  std_logic;
      enable      : in  std_logic;

      din1        : in  std_logic_vector(31 downto 0);
      din2        : in  std_logic_vector(31 downto 0);
      din_valid   : in  std_logic;
      din_ready   : out std_logic;
      din_last    : in  std_logic;

      dout        : out std_logic_vector(31 downto 0);
      dout_valid  : out std_logic;
      dout_ready  : in  std_logic;
      dout_last   : out std_logic
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

  constant C_ONE : unsigned(32 downto 0) := '1' & x"00000000";

  signal t_minus_tau_fixed : std_logic_vector(32 downto 0);
  signal t_minus_tau_fixed_decimal : std_logic_vector(32 downto 0);
  signal initial_phase : std_logic_vector(32 downto 0);
  signal initial_phase_decimal : std_logic_vector(31 downto 0);

  signal f_c_times_t_samp : std_logic_vector(31 downto 0);
  signal f_c_times_t_samp_fixed : std_logic_vector(32 downto 0);
  signal f_c_times_t_samp_decimal_fixed : std_logic_vector(31 downto 0);
  signal f_c_times_t_samp_valid : std_logic;
  signal f_c_times_t_samp_ready : std_logic;
  signal f_c_times_t_samp_fixed_valid : std_logic;

  signal first_samp : std_logic;
  signal lut_phase : std_logic_vector(31 downto 0);
  signal sine_lut_din       : std_logic_vector(15 downto 0);
  signal sine_lut_din_valid : std_logic;
  signal sine_lut_din_ready : std_logic;

begin

  u_t_minus_tau_fixed : float_to_fixed
    generic map
    (
      G_INTEGER_BITS  => 1,
      G_FRACT_BITS    => 32,
      G_SIGNED_OUTPUT => false,
      G_BUFFER_INPUT  => false,
      G_BUFFER_OUTPUT => false
    )
    port map
    (
      clk             => clk,
      reset           => reset,
      enable          => enable,

      din             => t_minus_tau_0,
      din_valid       => '1',
      din_ready       => open,
      din_last        => '0',

      dout            => t_minus_tau_fixed,
      dout_valid      => open,
      dout_ready      => '1',
      dout_last       => open
    );

  t_minus_tau_fixed_decimal(32) <= '0';
  t_minus_tau_fixed_decimal(31 downto 0) <= t_minus_tau_fixed(31 downto 0);

  initial_phase <=
    std_logic_vector(unsigned(C_ONE) + unsigned(t_minus_tau_fixed_decimal)) when t_minus_tau_0(31) = '1' else
    std_logic_vector(unsigned(C_ONE) - unsigned(t_minus_tau_fixed_decimal));

  initial_phase_decimal <= initial_phase(31 downto 0);

  u_f_c_times_t_samp : floating_point_mult
    port map
    (
      clk         => clk,
      reset       => reset,
      enable      => enable,

      din1        => din_t_step,
      din2        => din_f_out,
      din_valid   => din_valid,
      din_ready   => open,
      din_last    => '0',

      dout        => f_c_times_t_samp,
      dout_valid  => f_c_times_t_samp_valid,
      dout_ready  => f_c_times_t_samp_ready,
      dout_last   => open
    );

  u_f_c_times_t_samp_fixed : float_to_fixed
    generic map
    (
      G_INTEGER_BITS  => 1,
      G_FRACT_BITS    => 32,
      G_SIGNED_OUTPUT => false,
      G_BUFFER_INPUT  => false,
      G_BUFFER_OUTPUT => false
    )
    port map
    (
      clk             => clk,
      reset           => reset,
      enable          => enable,

      din             => t_minus_tau_0,
      din_valid       => f_c_times_t_samp_valid,
      din_ready       => f_c_times_t_samp_ready,
      din_last        => '0',

      dout            => f_c_times_t_samp_fixed,
      dout_valid      => f_c_times_t_samp_fixed_valid,
      dout_ready      => '1',
      dout_last       => open
    );

  sine_lut_din_valid <= f_c_times_t_samp_fixed_valid;

  f_c_times_t_samp_decimal_fixed <= f_c_times_t_samp_fixed(31 downto 0);

  p_first_samp : process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' or enable = '0' then
        first_samp <= '0';
      else
        if sine_lut_din_valid = '1' and sine_lut_din_ready = '1' then
          first_samp <= '1';
        end if;
      end if;
    end if;
  end process;

  p_phase_counter : process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' or enable = '0' then
        lut_phase <= (others => '0');
      else
        if sine_lut_din_valid = '1' and sine_lut_din_ready = '1' then
          if first_samp = '0' then
            if din_f_out(31) = '0' then
              lut_phase <= std_logic_vector(unsigned(initial_phase_decimal) + unsigned(f_c_times_t_samp_decimal_fixed));
            else
              lut_phase <= std_logic_vector(unsigned(initial_phase_decimal) - unsigned(f_c_times_t_samp_decimal_fixed));
            end if;
          else
            if din_f_out(31) = '0' then
              lut_phase <= std_logic_vector(unsigned(lut_phase) + unsigned(f_c_times_t_samp_decimal_fixed));
            else
              lut_phase <= std_logic_vector(unsigned(lut_phase) - unsigned(f_c_times_t_samp_decimal_fixed));
            end if;          end if;
        end if;
      end if;
    end if;
  end process;

  sine_lut_din <=
    initial_phase_decimal(31 downto 16) when first_samp = '0' else
    lut_phase(31 downto 16);

  u_sine_lut : sine_lut
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
  
      din             => sine_lut_din,
      din_valid       => sine_lut_din_valid,
      din_ready       => sine_lut_din_ready,
      din_last        => '0',
  
      dout            => open,
      dout_valid      => open,
      dout_ready      => '1',
      dout_last       => open
    );

end rtl;

















