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

  component exponential_lut is
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

  component floating_point_add is
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

  signal first_samp           : std_logic;
  signal time_sec             : std_logic_vector(31 downto 0);
  signal time_next            : std_logic_vector(31 downto 0);
  signal time_next_din_valid  : std_logic;
  signal time_next_din_ready  : std_logic;
  signal time_next_dout_valid : std_logic;
  signal time_next_dout_ready : std_logic;


  signal t_minus_tau_din_valid  : std_logic;
  signal t_minus_tau_din_ready  : std_logic;
  signal t_minus_tau_dout_valid : std_logic;
  signal t_minus_tau_dout_ready : std_logic;

  signal negative_tau         : std_logic_vector(31 downto 0);
  signal t_minus_tau          : std_logic_vector(31 downto 0);

begin

  p_time_zero : process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' or enable = '0' then
        first_samp <= '0';
      else
        if time_next_din_valid = '1' and time_next_din_ready = '1' then
          first_samp <= '1';
        end if;
      end if;
    end if;
  end process;

  negative_tau(31)          <= din_tau(31) xor '1';
  negative_tau(30 downto 0) <= din_tau(30 downto 0);

  time_next_din_valid   <= '1';

  time_sec <=
    '1' & din_t_step(30 downto 0) when first_samp = '0' else
    time_next;

  u_time_next : floating_point_add
    port map
    (
      clk         => clk,
      reset       => reset,
      enable      => enable,

      din1        => time_sec,
      din2        => din_t_step,
      din_valid   => time_next_din_valid,
      din_ready   => time_next_din_ready,
      din_last    => '0',

      dout        => time_next,
      dout_valid  => time_next_dout_valid,
      dout_ready  => time_next_dout_ready,
      dout_last   => open
    );

  time_next_dout_ready  <= t_minus_tau_din_ready;

  u_t_minus_tau : floating_point_add
    port map
    (
      clk         => clk,
      reset       => reset,
      enable      => enable,
  
      din1        => negative_tau;
      din2        => time_next
      din_valid   => t_minus_tau_din_valid,
      din_ready   => t_minus_tau_din_ready,
      din_last    => '0',
  
      dout        => t_minus_tau,
      dout_valid  => t_minus_tau_dout_valid,
      dout_ready  => t_minus_tau_dout_ready,
      dout_last   => open
    );

  t_minus_tau_dout_ready <= '1';
  -- todo: (t - tau)^2

end rtl;
