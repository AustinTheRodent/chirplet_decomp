
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity float_to_fixed is
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

  function check_if_zero(input_int : integer) return integer is
  begin
    if input_int = 0 then
      return 1;
    else
      return input_int;
    end if;
  end function;

  constant C_EXP_BIAS               : integer := 127;
  constant C_EXP_LEN                : integer := 8; -- [bits]
  constant C_MANT_LEN               : integer := 23; -- [bits], without implied 1

  constant C_MIN_INT_SIGNED         : std_logic_vector(check_if_zero(G_INTEGER_BITS)-2 downto 0) := (others => '0');
  constant C_MAX_INT_SIGNED         : std_logic_vector(check_if_zero(G_INTEGER_BITS)-2 downto 0) := (others => '1');

  signal din_ready_int              : std_logic;
  signal dout_int                   : std_logic_vector(G_INTEGER_BITS+G_FRACT_BITS-1 downto 0);
  signal dout_valid_int             : std_logic;
  signal dout_last_int              : std_logic;

  signal input_buff_din             : std_logic_vector(31 downto 0);
  signal input_buff_din_valid       : std_logic;
  signal input_buff_din_ready       : std_logic;
  signal input_buff_din_last        : std_logic;
  signal input_buff_dout            : std_logic_vector(31 downto 0);
  signal input_buff_dout_valid      : std_logic;
  signal input_buff_dout_ready      : std_logic;
  signal input_buff_dout_last       : std_logic;

  signal output_buff_din            : std_logic_vector(G_INTEGER_BITS+G_FRACT_BITS-1 downto 0);
  signal output_buff_din_valid      : std_logic;
  signal output_buff_din_ready      : std_logic;
  signal output_buff_din_last       : std_logic;
  signal output_buff_dout           : std_logic_vector(G_INTEGER_BITS+G_FRACT_BITS-1 downto 0);
  signal output_buff_dout_valid     : std_logic;
  signal output_buff_dout_ready     : std_logic;
  signal output_buff_dout_last      : std_logic;

  signal exponent                   : std_logic_vector(C_EXP_LEN-1 downto 0);
  signal shift_amount               : integer range -C_EXP_BIAS-1 to C_EXP_BIAS+1;
  signal mantissa                   : std_logic_vector(C_MANT_LEN-1 downto 0);

  signal output_integer_long        : std_logic_vector(check_if_zero(G_INTEGER_BITS)+C_MANT_LEN-1 downto 0);
  signal output_integer_long_shift  : std_logic_vector(check_if_zero(G_INTEGER_BITS)+C_MANT_LEN-1 downto 0);
  signal output_integer_short       : std_logic_vector(check_if_zero(G_INTEGER_BITS)-1 downto 0);

  signal output_pre_shift_fract     : std_logic_vector(check_if_zero(G_FRACT_BITS)+C_MANT_LEN downto 0);
  signal output_fract               : std_logic_vector(check_if_zero(G_FRACT_BITS)+C_MANT_LEN downto 0);
  signal output_fract_short         : std_logic_vector(check_if_zero(G_FRACT_BITS)-1 downto 0);

  signal output_comb                : std_logic_vector((G_INTEGER_BITS)+(G_FRACT_BITS)-1 downto 0);
  signal output_sign                : std_logic_vector((G_INTEGER_BITS)+(G_FRACT_BITS)-1 downto 0);

begin

  din_ready     <= din_ready_int;
  din_ready_int <= input_buff_din_ready;

  input_buff_din        <= din;
  input_buff_din_valid  <= din_valid;
  input_buff_din_last   <= din_last;

  g_input_buff : if G_BUFFER_INPUT = true generate
    u_input_buff : axis_buffer
      generic map
      (
        G_DWIDTH    => 32
      )
      port map
      (
        clk         => clk,
        reset       => reset,
        enable      => enable,

        din         => input_buff_din,
        din_valid   => input_buff_din_valid,
        din_ready   => input_buff_din_ready,
        din_last    => input_buff_din_last,

        dout        => input_buff_dout,
        dout_valid  => input_buff_dout_valid,
        dout_ready  => input_buff_dout_ready,
        dout_last   => input_buff_dout_last
      );
  end generate;

  g_no_input_buff : if G_BUFFER_INPUT = false generate
    input_buff_dout       <= input_buff_din;
    input_buff_dout_valid <= input_buff_din_valid;
    input_buff_din_ready  <= input_buff_dout_ready;
    input_buff_dout_last  <= input_buff_din_last;
  end generate;

  exponent      <= input_buff_dout(input_buff_dout'left-1 downto input_buff_dout'left-C_EXP_LEN);
  shift_amount  <= to_integer(unsigned(exponent)) - C_EXP_BIAS;
  mantissa      <= input_buff_dout(mantissa'range);

  output_integer_long(check_if_zero(G_INTEGER_BITS)+C_MANT_LEN-1 downto C_MANT_LEN+1) <= (others => '0');
  output_integer_long(C_MANT_LEN) <= '1';
  output_integer_long(C_MANT_LEN-1 downto 0) <= mantissa;

  output_integer_long_shift <=
    std_logic_vector(shift_left(unsigned(output_integer_long), shift_amount)) when shift_amount >= 0 else
    (others => '0');

  output_integer_short <=
    (others => '1') when shift_amount > check_if_zero(G_INTEGER_BITS)-1 and G_SIGNED_OUTPUT = false else
    '0' & C_MAX_INT_SIGNED when shift_amount > check_if_zero(G_INTEGER_BITS)-2 and input_buff_dout(31) = '0' and G_SIGNED_OUTPUT = true else
    '1' & C_MIN_INT_SIGNED when shift_amount > check_if_zero(G_INTEGER_BITS)-2 and input_buff_dout(31) = '1' and G_SIGNED_OUTPUT = true else
    output_integer_long_shift(check_if_zero(G_INTEGER_BITS)+C_MANT_LEN-1 downto C_MANT_LEN);

  output_pre_shift_fract(check_if_zero(G_FRACT_BITS)+C_MANT_LEN) <= '1';
  output_pre_shift_fract(check_if_zero(G_FRACT_BITS)+C_MANT_LEN-1 downto check_if_zero(G_FRACT_BITS)) <= mantissa;
  output_pre_shift_fract(check_if_zero(G_FRACT_BITS)-1 downto 0) <= (others => '0');

  output_fract <=
    (others => '1') when shift_amount > check_if_zero(G_INTEGER_BITS)-1 and G_SIGNED_OUTPUT = false else
    (others => '1') when shift_amount > check_if_zero(G_INTEGER_BITS)-2 and input_buff_dout(31) = '0' and G_SIGNED_OUTPUT = true else
    (others => '0') when shift_amount > check_if_zero(G_INTEGER_BITS)-2 and input_buff_dout(31) = '1' and G_SIGNED_OUTPUT = true else
    std_logic_vector(shift_left(unsigned(output_pre_shift_fract), shift_amount)) when shift_amount >= 0 else
    std_logic_vector(shift_right(unsigned(output_pre_shift_fract), -shift_amount));

  output_fract_short <= output_fract(check_if_zero(G_FRACT_BITS)+C_MANT_LEN-1 downto C_MANT_LEN);  

  output_comb <=
    output_integer_short when G_FRACT_BITS = 0 else
    output_fract_short when G_INTEGER_BITS = 0 else
    output_integer_short & output_fract_short;

  gen_signed_output : if G_SIGNED_OUTPUT = true generate
    output_sign <=
      output_comb when input_buff_dout(input_buff_dout'left) = '0' else
      std_logic_vector(unsigned(not output_comb) + 1);
  end generate;

  gen_unsigned_output : if G_SIGNED_OUTPUT = false generate
    output_sign <= output_comb;
  end generate;

  output_buff_din <= output_sign;

  output_buff_din_valid <= input_buff_dout_valid;
  input_buff_dout_ready <= output_buff_din_ready;
  output_buff_din_last  <= input_buff_dout_last;

  g_output_buff : if G_BUFFER_OUTPUT = true generate
    u_output_buff : axis_buffer
      generic map
      (
        G_DWIDTH    => G_INTEGER_BITS+G_FRACT_BITS
      )
      port map
      (
        clk         => clk,
        reset       => reset,
        enable      => enable,

        din         => output_buff_din,
        din_valid   => output_buff_din_valid,
        din_ready   => output_buff_din_ready,
        din_last    => output_buff_din_last,

        dout        => output_buff_dout,
        dout_valid  => output_buff_dout_valid,
        dout_ready  => output_buff_dout_ready,
        dout_last   => output_buff_dout_last
      );
  end generate;

  g_no_output_buff : if G_BUFFER_OUTPUT = false generate
    output_buff_dout        <= output_buff_din;
    output_buff_dout_valid  <= output_buff_din_valid;
    output_buff_din_ready   <= output_buff_dout_ready;
    output_buff_dout_last   <= output_buff_din_last;
  end generate;

  dout_int        <= output_buff_dout;
  dout_valid_int  <= output_buff_dout_valid;
  dout_last_int   <= output_buff_dout_last;

  dout        <= dout_int;
  dout_valid  <= dout_valid_int;
  dout_last   <= dout_last_int;

end rtl;
