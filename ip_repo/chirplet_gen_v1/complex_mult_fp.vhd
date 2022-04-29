library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity complex_mult_fp is
  port
  (
    clk             : in std_logic;
    reset           : in std_logic;
    enable          : in std_logic;

    din1_real       : in  std_logic_vector(31 downto 0);
    din1_imag       : in  std_logic_vector(31 downto 0);
    din2_real       : in  std_logic_vector(31 downto 0);
    din2_imag       : in  std_logic_vector(31 downto 0);
    din_valid       : in  std_logic;
    din_ready       : out std_logic;
    din_last        : in  std_logic;

    dout_real       : out std_logic_vector(31 downto 0);
    dout_imag       : out std_logic_vector(31 downto 0);
    dout_valid      : out std_logic;
    dout_ready      : in  std_logic;
    dout_last       : out std_logic
  );
end entity;

architecture rtl of complex_mult_fp is

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

  signal i1i2_dout        : std_logic_vector(31 downto 0);
  signal i1i2_dout_valid  : std_logic;
  signal i1i2_dout_ready  : std_logic;
  signal i1i2_dout_last   : std_logic;

  signal minus_din1_imag  : std_logic_vector(31 downto 0);
  signal mq1q2_dout       : std_logic_vector(31 downto 0);
  signal i1q2_dout        : std_logic_vector(31 downto 0);
  signal i2q1_dout        : std_logic_vector(31 downto 0);

  signal dout_real_valid  : std_logic;
  signal dout_real_ready  : std_logic;
  signal dout_real_last   : std_logic;

begin

  u_i1_i2 : floating_point_mult
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

      din1            => din1_real,
      din2            => din2_real,
      din_valid       => din_valid,
      din_ready       => din_ready,
      din_last        => din_last,

      dout            => i1i2_dout,
      dout_valid      => i1i2_dout_valid,
      dout_ready      => i1i2_dout_ready,
      dout_last       => i1i2_dout_last
    );

  minus_din1_imag(31) <= not din1_imag(31);
  minus_din1_imag(30 downto 0) <= din1_imag(30 downto 0);

  u_mq1_q2 : floating_point_mult
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

      din1            => minus_din1_imag,
      din2            => din2_imag,
      din_valid       => din_valid,
      din_ready       => open,
      din_last        => '0',

      dout            => mq1q2_dout,
      dout_valid      => open,
      dout_ready      => i1i2_dout_ready,
      dout_last       => open
    );

  u_i1_q2 : floating_point_mult
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

      din1            => din1_real,
      din2            => din2_imag,
      din_valid       => din_valid,
      din_ready       => open,
      din_last        => '0',

      dout            => i1q2_dout,
      dout_valid      => open,
      dout_ready      => i1i2_dout_ready,
      dout_last       => open
    );

  u_i2_q1 : floating_point_mult
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

      din1            => din2_real,
      din2            => din1_imag,
      din_valid       => din_valid,
      din_ready       => open,
      din_last        => '0',

      dout            => i2q1_dout,
      dout_valid      => open,
      dout_ready      => i1i2_dout_ready,
      dout_last       => open
    );

  u_dout_real : floating_point_add
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

      din1            => i1i2_dout,
      din2            => mq1q2_dout,
      din_valid       => i1i2_dout_valid,
      din_ready       => i1i2_dout_ready,
      din_last        => i1i2_dout_last,

      dout            => dout_real,
      dout_valid      => dout_real_valid,
      dout_ready      => dout_real_ready,
      dout_last       => dout_real_last
    );

  u_dout_imag : floating_point_add
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

      din1            => i1q2_dout,
      din2            => i2q1_dout,
      din_valid       => i1i2_dout_valid,
      din_ready       => open,
      din_last        => '0',

      dout            => dout_imag,
      dout_valid      => open,
      dout_ready      => dout_real_ready,
      dout_last       => open
    );

  dout_valid      <= dout_real_valid;
  dout_real_ready <= dout_ready;
  dout_last       <= dout_real_last;

end rtl;
