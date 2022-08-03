
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fixed_to_float is
  generic
  (
    G_INTEGER_BITS  : integer range 0 to 64 := 16;
    G_FRACT_BITS    : integer range 0 to 64 := 16;
    G_SIGNED_INPUT  : boolean := false;
    G_BUFFER_INPUT  : boolean := false;
    G_BUFFER_OUTPUT : boolean := false
  );
  port
  (
    clk             : in  std_logic;
    reset           : in  std_logic;
    enable          : in  std_logic;

    din             : in  std_logic_vector(G_INTEGER_BITS+G_FRACT_BITS-1 downto 0);
    din_valid       : in  std_logic;
    din_ready       : out std_logic;
    din_last        : in  std_logic;

    dout            : out std_logic_vector(31 downto 0); -- floating point
    dout_valid      : out std_logic;
    dout_ready      : in  std_logic;
    dout_last       : out std_logic
  );
end entity;

architecture rtl of fixed_to_float is

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

  constant C_EXP_BIAS           : integer := 127;
  constant C_EXP_LEN            : integer := 8; -- [bits]
  constant C_MANT_LEN           : integer := 24; -- [bits], with implied 1

  signal input_buff_din         : std_logic_vector(G_INTEGER_BITS+G_FRACT_BITS-1 downto 0);
  signal input_buff_din_valid   : std_logic;
  signal input_buff_din_ready   : std_logic;
  signal input_buff_din_last    : std_logic;
  signal input_buff_dout        : std_logic_vector(G_INTEGER_BITS+G_FRACT_BITS-1 downto 0);
  signal input_buff_dout_valid  : std_logic;
  signal input_buff_dout_ready  : std_logic;
  signal input_buff_dout_last   : std_logic;

  signal output_buff_din        : std_logic_vector(31 downto 0);
  signal output_buff_din_valid  : std_logic;
  signal output_buff_din_ready  : std_logic;
  signal output_buff_din_last   : std_logic;
  signal output_buff_dout       : std_logic_vector(31 downto 0);
  signal output_buff_dout_valid : std_logic;
  signal output_buff_dout_ready : std_logic;
  signal output_buff_dout_last  : std_logic;

  signal leading_zeros_count    : integer range 0 to 2**8-1;
  signal din_unsigned           : std_logic_vector(G_INTEGER_BITS+G_FRACT_BITS-1 downto 0);
  signal is_signed              : std_logic;
  signal lefthand_count_mask    : std_logic_vector(G_INTEGER_BITS+G_FRACT_BITS-1 downto 0);
  type lefthand_count_add_t is array(0 to G_INTEGER_BITS+G_FRACT_BITS-1) of unsigned(7 downto 0);
  signal lefthand_count_add     : lefthand_count_add_t;
  signal lefthand_count_final   : unsigned(7 downto 0);

  signal din_shifted            : std_logic_vector(G_INTEGER_BITS+G_FRACT_BITS-1 downto 0);
  signal mantissa               : std_logic_vector(C_MANT_LEN-1 downto 0);
  signal exponent_no_fract      : std_logic_vector(C_EXP_LEN-1 downto 0);
  signal exponent               : std_logic_vector(C_EXP_LEN-1 downto 0);
  signal output                 : std_logic_vector(31 downto 0);

begin

  input_buff_din        <= din;
  input_buff_din_valid  <= din_valid;
  din_ready             <= input_buff_din_ready;
  input_buff_din_last   <= din_last;

  g_input_buff : if G_BUFFER_INPUT = true generate
    u_input_buff : axis_buffer
      generic map
      (
        G_DWIDTH    => input_buff_din'length
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

  din_unsigned <=
    input_buff_dout                                     when G_SIGNED_INPUT = false else
    std_logic_vector(unsigned(not input_buff_dout) + 1) when input_buff_dout(input_buff_dout'left) = '1' else
    input_buff_dout;

  is_signed <=
    '0' when G_SIGNED_INPUT = false else
    '1' when input_buff_dout(input_buff_dout'left) = '1' else
    '0';

  lefthand_count_mask(lefthand_count_mask'left) <= not din_unsigned(din_unsigned'left);
  g_lefthand_count_mask : for i in G_INTEGER_BITS+G_FRACT_BITS-2 downto 0 generate
    lefthand_count_mask(i) <= '0' when lefthand_count_mask(i+1) = '0' else not din_unsigned(i);
  end generate;

  lefthand_count_add(0) <= x"01" when lefthand_count_mask(0) = '1' else x"00";
  g_lefthand_count_add : for i in 1 to G_INTEGER_BITS+G_FRACT_BITS-1 generate
    lefthand_count_add(i) <= lefthand_count_add(i-1) + 1 when lefthand_count_mask(i) = '1' else lefthand_count_add(i-1);
  end generate;
  lefthand_count_final <= lefthand_count_add(G_INTEGER_BITS+G_FRACT_BITS-1);

  din_shifted <= std_logic_vector(shift_left(unsigned(din_unsigned), to_integer(lefthand_count_final)));

  g_mant_is_shorter : if C_MANT_LEN <= (G_INTEGER_BITS+G_FRACT_BITS) generate
    mantissa <= din_shifted(din_shifted'length-1 downto din_shifted'length-C_MANT_LEN);
  end generate;

  g_mant_is_longer : if C_MANT_LEN > (G_INTEGER_BITS+G_FRACT_BITS) generate
    mantissa(C_MANT_LEN-1 downto C_MANT_LEN-din_shifted'length) <= din_shifted;
    mantissa(C_MANT_LEN-din_shifted'length-1 downto 0)          <= (others => '0');
  end generate;

  exponent_no_fract <=
    (others => '0') when unsigned(input_buff_dout) = 0 else
    std_logic_vector
    (
      to_unsigned
      (
        C_EXP_BIAS + (G_INTEGER_BITS+G_FRACT_BITS - to_integer(lefthand_count_final) - 1),
        exponent_no_fract'length
      )
    );

  exponent <= std_logic_vector(unsigned(exponent_no_fract) - to_unsigned(G_FRACT_BITS, exponent'length));

  output(31)            <= is_signed;
  output(30 downto 23)  <= exponent;
  output(22 downto 0)   <= mantissa(22 downto 0);

  output_buff_din       <= output;
  output_buff_din_valid <= input_buff_dout_valid;
  input_buff_dout_ready <= output_buff_din_ready;
  output_buff_din_last  <= input_buff_dout_last;

  g_output_buff : if G_BUFFER_OUTPUT = true generate
    u_output_buff : axis_buffer
      generic map
      (
        G_DWIDTH    => output_buff_din'length
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

  dout                    <= output_buff_dout;
  dout_valid              <= output_buff_dout_valid;
  output_buff_dout_ready  <= dout_ready;
  dout_last               <= output_buff_dout_last;

end rtl;
