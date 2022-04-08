
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--todo: add generics to buffer input/output

entity float_to_fixed is
  generic
  (
    G_INTEGER_BITS  : integer range 1 to 64 := 16;
    G_FRACT_BITS    : integer range 1 to 64 := 16;
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
end entity;

architecture rtl of float_to_fixed is

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

  constant C_EXP_BIAS         : integer := 127;
  constant C_EXP_LEN          : integer := 8; -- [bits]
  constant C_MANT_LEN         : integer := 23; -- [bits], without implied 1

  signal exponent     : std_logic_vector(C_EXP_LEN-1 downto 0);
  signal shift_amount : integer range -C_EXP_BIAS-1 to C_EXP_BIAS;
  signal mantissa     : std_logic_vector(C_MANT_LEN-1 downto 0);

  signal output_pre_shift_int   : std_logic_vector(G_INTEGER_BITS-1 downto 0);
  signal output_pre_shift_fract : std_logic_vector(G_FRACT_BITS-1 downto 0);
  signal output_pre_shift       : std_logic_vector(G_INTEGER_BITS+G_FRACT_BITS-1 downto 0);
  signal output_post_shift      : std_logic_vector(G_INTEGER_BITS+G_FRACT_BITS-1 downto 0);

begin

  exponent <= din(din'left-1 downto din'left-C_EXP_LEN);
  shift_amount  <= to_integer(unsigned(exponent)) - C_EXP_BIAS;
  mantissa <= din(mantissa'range);

  output_pre_shift_int(0) <= '1';
  output_pre_shift_int(output_pre_shift_int'left downto 1) <=
    (others => '0');

  g_mantissa_larger : if C_MANT_LEN >= G_FRACT_BITS generate
    output_pre_shift_fract <= mantissa(C_MANT_LEN-1 downto C_MANT_LEN-G_FRACT_BITS);
  end generate;

  g_mantissa_smaller : if C_MANT_LEN < G_FRACT_BITS generate
    output_pre_shift_fract(G_FRACT_BITS-1 downto G_FRACT_BITS-C_MANT_LEN) <= mantissa;
    output_pre_shift_fract(G_FRACT_BITS-C_MANT_LEN-1 downto 0) <= (others => '0');
  end generate;

  output_pre_shift <= output_pre_shift_int & output_pre_shift_fract;

  output_post_shift <=
    std_logic_vector(shift_left(unsigned(output_pre_shift), shift_amount)) when shift_amount >= 0 else
    std_logic_vector(shift_right(unsigned(output_pre_shift), shift_amount));

  -- todo: add twos complement, add input/output buffer options

  dout <= output_post_shift;

end rtl;


