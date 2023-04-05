library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity floating_point_add is
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
end entity;

architecture rtl of floating_point_add is

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

  function encode_bit_pairs
  (
    input_vector : in std_logic_vector(1 downto 0)
  ) return std_logic_vector is
  begin
    case input_vector is
      when "00" =>
        return "10";
      when "01" =>
        return "01";
      when others =>
        return "00";
    end case;
  end function;

  function assemble
  (
    input_vector_left   : in std_logic_vector;
    input_vector_right  : in std_logic_vector
  ) return std_logic_vector is
    variable v_left_bits  : std_logic_vector(1 downto 0);
    variable v_zeros      : std_logic_vector(input_vector_left'range);
  begin
    v_left_bits := input_vector_left(input_vector_left'left) & input_vector_right(input_vector_right'left);
    v_zeros     := (others => '0');
    case v_left_bits is
      when "11" =>
        return '1' & v_zeros;
      when "01" =>
        return '0' & input_vector_left;
      when "00" =>
        return '0' & input_vector_left;
      when others =>
        return "01" & input_vector_right(input_vector_right'left-1 downto 0);
    end case;
  end function;

  function get_leading_zeros32
  (
    input_vector : in std_logic_vector(31 downto 0)
  ) return unsigned is

    type two_bit_pairs_t    is array (15 downto 0) of std_logic_vector(1 downto 0);
    type three_bit_array_t  is array ( 7 downto 0) of std_logic_vector(2 downto 0);
    type four_bit_array_t   is array ( 3 downto 0) of std_logic_vector(3 downto 0);
    type five_bit_array_t   is array ( 1 downto 0) of std_logic_vector(4 downto 0);

    variable v_two_bit_pairs    : two_bit_pairs_t;
    variable v_three_bit_array  : three_bit_array_t;
    variable v_four_bit_array   : four_bit_array_t;
    variable v_five_bit_array   : five_bit_array_t;
    variable v_output           : std_logic_vector(5 downto 0);
    variable v_return_value     : std_logic_vector(7 downto 0);

  begin

    for i in 15 downto 0 loop
      v_two_bit_pairs(i) := encode_bit_pairs(input_vector((i+1)*2-1 downto (i+1)*2-2));
    end loop;

    for i in 7 downto 0 loop
      v_three_bit_array(i) := assemble(v_two_bit_pairs((i+1)*2-1), v_two_bit_pairs((i+1)*2-2));
    end loop;

    for i in 3 downto 0 loop
      v_four_bit_array(i) := assemble(v_three_bit_array((i+1)*2-1), v_three_bit_array((i+1)*2-2));
    end loop;

    for i in 1 downto 0 loop
      v_five_bit_array(i) := assemble(v_four_bit_array((i+1)*2-1), v_four_bit_array((i+1)*2-2));
    end loop;

    v_output := assemble(v_five_bit_array(1), v_five_bit_array(0));
    v_return_value := "00" & v_output;
    return unsigned(v_return_value);

  end function;

  constant C_EXP_LEN          : integer := 8; -- [bits]
  constant C_MANT_LEN         : integer := 23; -- [bits], without implied 1

  signal din_buff_din         : std_logic_vector(63 downto 0);
  signal din_buff_din_valid   : std_logic;
  signal din_buff_din_ready   : std_logic;
  signal din_buff_din_last    : std_logic;
  signal din_buff_dout        : std_logic_vector(63 downto 0);
  signal din_buff_dout1       : std_logic_vector(31 downto 0);
  signal din_buff_dout2       : std_logic_vector(31 downto 0);
  signal din_buff_dout_valid  : std_logic;
  signal din_buff_dout_ready  : std_logic;
  signal din_buff_dout_last   : std_logic;

  signal dout_buff_din        : std_logic_vector(31 downto 0);
  signal dout_buff_din_valid  : std_logic;
  signal dout_buff_din_ready  : std_logic;
  signal dout_buff_din_last   : std_logic;
  signal dout_buff_dout       : std_logic_vector(31 downto 0);
  signal dout_buff_dout_valid : std_logic;
  signal dout_buff_dout_ready : std_logic;
  signal dout_buff_dout_last  : std_logic;

  signal din_ready_int        : std_logic;
  signal dout_int             : std_logic_vector(31 downto 0);
  signal dout_valid_int       : std_logic;
  signal dout_last_int        : std_logic;

  signal din1_sign            : std_logic;
  signal din1_exponent        : std_logic_vector(C_EXP_LEN-1 downto 0);
  signal din1_exponent_norm   : std_logic_vector(C_EXP_LEN-1 downto 0);
  signal din1_exp_norm_buff   : std_logic_vector(C_EXP_LEN-1 downto 0);
  signal din1_mantissa        : std_logic_vector(C_MANT_LEN downto 0);
  signal din1_mantissa_norm   : std_logic_vector(C_MANT_LEN downto 0);
  signal din2_sign            : std_logic;
  signal din2_exponent        : std_logic_vector(C_EXP_LEN-1 downto 0);
  signal din2_exponent_norm   : std_logic_vector(C_EXP_LEN-1 downto 0);
  signal din2_mantissa        : std_logic_vector(C_MANT_LEN downto 0);
  signal din2_mantissa_norm   : std_logic_vector(C_MANT_LEN downto 0);

  signal d1_exp_islarger      : std_logic;
  signal d2_exp_islarger      : std_logic;

  signal exponent_diff        : unsigned(C_EXP_LEN-1 downto 0);

  signal mantissa_added       : std_logic_vector(C_MANT_LEN+1 downto 0);
  signal mantissa_added_buff  : std_logic_vector(C_MANT_LEN+1 downto 0);

  signal lefthand_count_mask  : std_logic_vector(C_MANT_LEN+1 downto 0);
  type lefthand_count_add_t is array(0 to C_MANT_LEN+1) of unsigned(7 downto 0);
  signal lefthand_count_add   : lefthand_count_add_t;
  signal lefthand_count_final : unsigned(7 downto 0);

  signal sign                 : std_logic;
  signal sign_buff            : std_logic;

  signal exponent_norm        : std_logic_vector(C_EXP_LEN+1 downto 0);
  signal exponent_short       : std_logic_vector(C_EXP_LEN-1 downto 0);

  signal mantissa_norm        : std_logic_vector(C_MANT_LEN+1 downto 0);
  signal mantissa_round       : std_logic_vector(C_MANT_LEN+1 downto 0);
  signal mantissa_short       : std_logic_vector(C_MANT_LEN downto 0);

  signal buff_din             : std_logic_vector((1 + C_EXP_LEN + C_MANT_LEN+2)-1 downto 0);
  signal buff_din_valid       : std_logic;
  signal buff_din_ready       : std_logic;
  signal buff_din_last        : std_logic;
  signal buff_dout            : std_logic_vector((1 + C_EXP_LEN + C_MANT_LEN+2)-1 downto 0);
  signal buff_dout_valid      : std_logic;
  signal buff_dout_ready      : std_logic;
  signal buff_dout_last       : std_logic;

begin

  din_ready     <= din_ready_int;
  dout          <= dout_int;
  dout_valid    <= dout_valid_int;
  dout_last     <= dout_last_int;

  din_buff_din        <= din1 & din2;
  din_buff_din_valid  <= din_valid;
  din_ready_int       <= din_buff_din_ready;
  din_buff_din_last   <= din_last;

  gen_buffer_input : if G_BUFFER_INPUT = true generate

    u_input_buffer : axis_buffer
      generic map
      (
        G_DWIDTH    => 64
      )
      port map
      (
        clk         => clk,
        reset       => reset,
        enable      => enable,

        din         => din_buff_din,
        din_valid   => din_buff_din_valid,
        din_ready   => din_buff_din_ready,
        din_last    => din_buff_din_last,

        dout        => din_buff_dout,
        dout_valid  => din_buff_dout_valid,
        dout_ready  => din_buff_dout_ready,
        dout_last   => din_buff_dout_last
      );

  end generate;

  gen_no_buffer_input : if G_BUFFER_INPUT = false generate

    din_buff_dout       <= din_buff_din;
    din_buff_dout_valid <= din_buff_din_valid;
    din_buff_din_ready  <= din_buff_dout_ready;
    din_buff_dout_last  <= din_buff_din_last;

  end generate;

  din_buff_dout1 <= din_buff_dout(63 downto 32);
  din_buff_dout2 <= din_buff_dout(31 downto 0);

  din1_sign     <= din_buff_dout1(din_buff_dout1'left);
  din1_exponent <= din_buff_dout1(din_buff_dout1'left-1 downto din_buff_dout1'left-C_EXP_LEN);
  din1_mantissa <= '1' & din_buff_dout1(C_MANT_LEN-1 downto 0);

  din2_sign     <= din_buff_dout2(din_buff_dout2'left);
  din2_exponent <= din_buff_dout2(din_buff_dout2'left-1 downto din_buff_dout2'left-C_EXP_LEN);
  din2_mantissa <= '1' & din_buff_dout2(C_MANT_LEN-1 downto 0);

  d1_exp_islarger <=
    '1' when unsigned(din1_exponent) > unsigned(din2_exponent) else
    '0';

  d2_exp_islarger <= not d1_exp_islarger;

  exponent_diff <=
    unsigned(din1_exponent) - unsigned(din2_exponent) when d1_exp_islarger = '1' else
    unsigned(din2_exponent) - unsigned(din1_exponent);

  din1_mantissa_norm <=
    (others => '0') when unsigned(din_buff_dout1(din_buff_dout1'left-1 downto 0)) = 0 else
    std_logic_vector(shift_right(unsigned(din1_mantissa), to_integer(exponent_diff))) when d2_exp_islarger = '1' else
    din1_mantissa;

  din2_mantissa_norm <=
    (others => '0') when unsigned(din_buff_dout2(din_buff_dout2'left-1 downto 0)) = 0 else
    std_logic_vector(shift_right(unsigned(din2_mantissa), to_integer(exponent_diff))) when d1_exp_islarger = '1' else
    din2_mantissa;

  din1_exponent_norm <=
    std_logic_vector(unsigned(din1_exponent) + exponent_diff) when d2_exp_islarger = '1' else
    din1_exponent;

  din2_exponent_norm <=
    std_logic_vector(unsigned(din2_exponent) + exponent_diff) when d1_exp_islarger = '1' else
    din2_exponent;

  mantissa_added <=
    --(others => '0') when 
    std_logic_vector(unsigned('0' & din1_mantissa_norm) + unsigned('0' & din2_mantissa_norm)) when din1_sign = din2_sign else
    std_logic_vector(unsigned('0' & din1_mantissa_norm) - unsigned('0' & din2_mantissa_norm)) when
      din1_sign /= din2_sign and unsigned(din1_mantissa_norm) >= unsigned(din2_mantissa_norm) else
    std_logic_vector(unsigned('0' & din2_mantissa_norm) - unsigned('0' & din1_mantissa_norm));

  sign <=
    '0' when din1_sign = '0' and din2_sign = '0' else
    '0' when din1_sign = '0' and din2_sign = '1' and din1_mantissa_norm >= din2_mantissa_norm else
    '0' when din1_sign = '1' and din2_sign = '0' and din2_mantissa_norm >= din1_mantissa_norm else
    '1';

  buff_din            <= sign & din1_exponent_norm & mantissa_added;
  buff_din_valid      <= din_buff_dout_valid;
  din_buff_dout_ready <= buff_din_ready;
  buff_din_last       <= din_buff_dout_last;

  u_buffer : axis_buffer
    generic map
    (
      G_DWIDTH    => (1 + C_EXP_LEN + C_MANT_LEN+2)
    )
    port map
    (
      clk         => clk,
      reset       => reset,
      enable      => enable,

      din         => buff_din,
      din_valid   => buff_din_valid,
      din_ready   => buff_din_ready,
      din_last    => buff_din_last,

      dout        => buff_dout,
      dout_valid  => buff_dout_valid,
      dout_ready  => buff_dout_ready,
      dout_last   => buff_dout_last
    );

  sign_buff           <= buff_dout(buff_dout'left);
  din1_exp_norm_buff  <= buff_dout(buff_dout'left-1 downto buff_dout'left-C_EXP_LEN);
  mantissa_added_buff <= buff_dout(mantissa_added_buff'range);

  dout_buff_din_valid <= buff_dout_valid;
  buff_dout_ready     <= dout_buff_din_ready;
  dout_buff_din_last  <= buff_dout_last;

  --lefthand_count_mask(lefthand_count_mask'left) <= not mantissa_added_buff(mantissa_added_buff'left);
  --g_lefthand_count_mask : for i in C_MANT_LEN downto 0 generate
  --  lefthand_count_mask(i) <= '0' when lefthand_count_mask(i+1) = '0' else not mantissa_added_buff(i);
  --end generate;
  --
  --lefthand_count_add(0) <= x"01" when lefthand_count_mask(0) = '1' else x"00";
  --g_lefthand_count_add : for i in 1 to C_MANT_LEN+1 generate
  --  lefthand_count_add(i) <= lefthand_count_add(i-1) + 1 when lefthand_count_mask(i) = '1' else lefthand_count_add(i-1);
  --end generate;
  --lefthand_count_final <= lefthand_count_add(C_MANT_LEN+1);

  --lefthand_count_final <=
  --  x"00" when mantissa_added_buff(mantissa_added_buff'left) = '1' else
  --  x"01";

  lefthand_count_final <= get_leading_zeros32( "0000000" & mantissa_added_buff) - x"07";

  mantissa_norm <=
    std_logic_vector(shift_right(unsigned(mantissa_added_buff), 1)) when lefthand_count_final = 0 else
    std_logic_vector(shift_left(unsigned(mantissa_added_buff), to_integer(lefthand_count_final - 1)));

  mantissa_round <= mantissa_norm;
    --std_logic_vector(unsigned(mantissa_norm) + 1) when lefthand_count_final = 0 and mantissa_added_buff(0) = '1' else
    --mantissa_norm;
    -- todo: this causes an error when rounding causes an overflow... fuck

  exponent_norm <=
    (others => '0') when unsigned(mantissa_norm) = 0 else
    std_logic_vector(unsigned("00" & din1_exp_norm_buff) + 1) when lefthand_count_final = 0 else
    std_logic_vector(unsigned("00" & din1_exp_norm_buff) - (lefthand_count_final - 1));

  exponent_short <=
    (others => '0') when exponent_norm(exponent_norm'left) = '1' else
    (others => '1') when exponent_norm(exponent_norm'left-1) = '1' else
    exponent_norm(exponent_short'range);

  mantissa_short <=
    (others => '0') when exponent_norm(exponent_norm'left) = '1' else
    (others => '0') when exponent_norm(exponent_norm'left-1) = '1' else
    mantissa_round(mantissa_short'range);

  dout_buff_din <= sign_buff & exponent_short & mantissa_short(C_MANT_LEN-1 downto 0);

  gen_buffer_output : if G_BUFFER_OUTPUT = true generate

    u_output_buffer : axis_buffer
      generic map
      (
        G_DWIDTH    => 32
      )
      port map
      (
        clk         => clk,
        reset       => reset,
        enable      => enable,

        din         => dout_buff_din,
        din_valid   => dout_buff_din_valid,
        din_ready   => dout_buff_din_ready,
        din_last    => dout_buff_din_last,

        dout        => dout_buff_dout,
        dout_valid  => dout_buff_dout_valid,
        dout_ready  => dout_buff_dout_ready,
        dout_last   => dout_buff_dout_last
      );

  end generate;

  gen_no_buffer_output : if G_BUFFER_OUTPUT = false generate

    dout_buff_dout        <= dout_buff_din;
    dout_buff_dout_valid  <= dout_buff_din_valid;
    dout_buff_din_ready   <= dout_buff_dout_ready;
    dout_buff_dout_last   <= dout_buff_din_last;

  end generate;

  dout_int              <= dout_buff_dout;
  dout_valid_int        <= dout_buff_dout_valid;
  dout_buff_dout_ready  <= dout_ready;
  dout_last_int         <= dout_buff_dout_last;

end rtl;
