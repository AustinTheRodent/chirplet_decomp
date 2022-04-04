library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

use std.textio.all;
use ieee.std_logic_textio.all;
use std.env.finish;

entity tb_chirplet_sig_gen is
  generic
  (
    G_VLD_COEFF         : real                  := 0.5;
    G_RDY_COEFF         : real                  := 0.5;
    G_RAND_SEED         : integer               := 0
--    G_RAND_SEED         : integer               := 0;
--    G_INPUT_FNAME       : string                := "";
--    G_OUTPUT_FNAME      : string                := "";
--    G_NUM_SAMPS         : integer               := 0
  );
end entity;

architecture behavioral of tb_chirplet_sig_gen is

  function get_flen(fname : string) return integer is
    variable v_line_count : integer;
    variable v_line       : line;
    file     fptr         : text;
  begin
    v_line_count := 0;
    file_open(fptr, fname, read_mode);
      while not endfile(fptr) loop
        readline(fptr, v_line);
        v_line_count := v_line_count + 1;
      end loop;
    file_close(fptr);
    return v_line_count;
  end function;

  function get_integer(input : real) return integer is
  begin
    if input > 0.0 then
      return integer(input-0.5);
    else
      return integer(input+0.5);
    end if;
  end function;

  component axis_lut is
    generic
    (
      G_AWIDTH    : integer range 1 to 24 := 16;
      G_DWIDTH    : integer range 1 to 64 := 16
    );
    port
    (
      clk         : in std_logic;
      reset       : in std_logic;
      enable      : in std_logic;

      prog_data   : in  std_logic_vector(G_DWIDTH-1 downto 0);
      prog_addr   : in  std_logic_vector(G_AWIDTH-1 downto 0);
      prog_en     : in  std_logic;
      prog_done   : in  std_logic;

      din         : in  std_logic_vector(G_AWIDTH-1 downto 0);
      din_valid   : in  std_logic;
      din_ready   : out std_logic;
      din_last    : in  std_logic;
      dout        : out std_logic_vector(G_DWIDTH-1 downto 0);
      dout_valid  : out std_logic;
      dout_ready  : in  std_logic;
      dout_last   : out std_logic
    );
  end component;

  constant C_CLK_PERIOD   : time    := 20 ns; -- 50MHz
  constant C_DWIDTH       : integer := 16;
  constant C_AWIDTH       : integer := 8;

  signal clk              : std_logic;
  signal dut_reset        : std_logic;
  signal dut_enable       : std_logic;

  signal input_counter    : unsigned(31 downto 0);
  signal output_counter   : unsigned(31 downto 0);

  signal dut_prog_data    : std_logic_vector(C_DWIDTH-1 downto 0);
  signal dut_prog_addr    : std_logic_vector(C_AWIDTH-1 downto 0);
  signal dut_prog_en      : std_logic;
  signal dut_prog_done    : std_logic;

  signal dut_din          : std_logic_vector(C_AWIDTH-1 downto 0);
  signal dut_din_valid    : std_logic;
  signal dut_din_ready    : std_logic;
  signal dut_din_last     : std_logic;
  signal dut_dout         : std_logic_vector(C_DWIDTH-1 downto 0);
  signal dut_dout_valid   : std_logic;
  signal dut_dout_ready   : std_logic;
  signal dut_dout_last    : std_logic;

  signal din_valid_main   : std_logic;
  signal din_valid_rand   : std_logic;
  signal dout_ready_rand  : std_logic;

  --signal a_tap_wr         : std_logic;
  --signal a_tap_val        : std_logic_vector(31 downto 0);
  --signal b_tap_wr         : std_logic;
  --signal b_tap_val        : std_logic_vector(31 downto 0);
  --
  --file taps_fptr          : text;
  --file input_fptr         : text;
  --file output_fptr        : text;
  --
  --type file_capture_t is (open_file, capture, done);
  --signal file_capture : file_capture_t := open_file;

begin

  p_clk : process
  begin
    wait for C_CLK_PERIOD/2;
    clk <= '0';
    wait for C_CLK_PERIOD/2;
    clk <= '1';
  end process;

  p_main : process
  begin
    -- reset signals to defaults:
    dut_reset       <= '1';
    dut_enable      <= '0';
    din_valid_main  <= '0';

    dut_prog_data   <= (others => '0');
    dut_prog_addr   <= (others => '0');
    dut_prog_en     <= '0';
    dut_prog_done   <= '0';

    wait for C_CLK_PERIOD*100;
    wait until rising_edge(clk);
    dut_reset   <= '0';
    dut_enable  <= '1';

    wait until rising_edge(clk);

    for i in 0 to 2**C_AWIDTH-1 loop
      dut_prog_en <= '1';
      dut_prog_addr <= std_logic_vector(to_unsigned(i, dut_prog_addr'length));
      dut_prog_data <= std_logic_vector(to_unsigned(i+1, dut_prog_data'length));
      wait until rising_edge(clk);
    end loop;
    dut_prog_en     <= '0';
    din_valid_main  <= '1';
    wait until rising_edge(clk);

    wait;

  end process;

  --p_capture_output : process(clk)
  --
  --  variable v_char_buffer  : character;
  --  type char_file_t is file of character;
  --  file char_file          : char_file_t;
  --
  --  variable v_line         : line;
  --  variable v_countdown    : integer;
  --begin
  --  if rising_edge(clk) then
  --    case file_capture is
  --      when open_file =>
  --        v_countdown := 0;
  --        file_open(char_file, G_OUTPUT_FNAME(G_OUTPUT_FNAME'left to G_OUTPUT_FNAME'right-3) & "bin", write_mode);
  --        file_capture <= capture;
  --
  --      when capture =>
  --        if dut_dout_valid = '1' and dut_dout_ready = '1' then
  --          for i in 0 to 3 loop
  --            v_char_buffer := character'val(to_integer(unsigned(dut_dout(i*8+7 downto i*8))));
  --            write(char_file, v_char_buffer);
  --          end loop;
  --          if dut_dout_last = '1' then
  --            file_close(char_file);
  --            file_capture <= done;
  --          end if;
  --        end if;
  --
  --      when done =>
  --        v_countdown := v_countdown + 1;
  --        if v_countdown = 200 then
  --          report "simulation finished";
  --          finish;
  --        end if;
  --        file_capture <= done;
  --
  --      when others =>
  --    end case;
  --  end if;
  --end process;

  p_rand_valid : process (clk)
    variable seed1  : positive := 100; -- seed values for random generator
    variable seed2  : integer := G_RAND_SEED;
    variable rand   : real;   -- random real-number value in range 0 to 1.0
  begin
    if rising_edge(clk) then
      uniform(seed1, seed2, rand);   -- generate random number
      if rand < G_VLD_COEFF then
        din_valid_rand <= '1';
      else
        din_valid_rand <= '0';
      end if;
    end if;
  end process;

  p_rand_ready : process (clk)
    variable seed1  : positive := 69420; -- seed values for random generator
    variable seed2  : integer := G_RAND_SEED;
    variable rand   : real;   -- random real-number value in range 0 to 1.0
  begin
    if rising_edge(clk) then
      uniform(seed1, seed2, rand);   -- generate random number
      if rand < G_RDY_COEFF then
        dout_ready_rand <= '1';
      else
        dout_ready_rand <= '0';
      end if;
    end if;
  end process;

  p_input_output_counter : process(clk)
  begin
    if rising_edge(clk) then
      if dut_reset = '1' or dut_enable = '0' then
        input_counter   <= (others => '0');
        output_counter  <= (others => '0');
      else
        if dut_din_valid = '1' and dut_din_ready = '1' then
          input_counter <= input_counter + 1;
        end if;
  
        if dut_dout_valid = '1' and dut_dout_ready = '1' then
          output_counter <= output_counter + 1;
        end if;
      end if;
    end if;
  end process;

  dut_din_valid   <= din_valid_main and din_valid_rand;
  dut_dout_ready  <= dout_ready_rand;

  p_din_counter : process(clk)
  begin
    if rising_edge(clk) then
      if dut_reset = '1' or dut_enable = '0' then
        dut_din <= (others => '0');
      else
        if dut_din_valid = '1' and dut_din_ready = '1' then
          dut_din <= std_logic_vector(unsigned(dut_din) + 1);
        end if;
      end if;
    end if;
  end process;

  u_dut : axis_lut
    generic map
    (
      G_AWIDTH    => C_AWIDTH,
      G_DWIDTH    => C_DWIDTH
    )
    port map
    (
      clk         => clk,
      reset       => dut_reset,
      enable      => dut_enable,

      prog_data   => dut_prog_data,
      prog_addr   => dut_prog_addr,
      prog_en     => dut_prog_en,
      prog_done   => dut_prog_done,

      din         => dut_din,
      din_valid   => dut_din_valid,
      din_ready   => dut_din_ready,
      din_last    => '0',

      dout        => dut_dout,
      dout_valid  => dut_dout_valid,
      dout_ready  => dut_dout_ready,
      dout_last   => open
    );

end behavioral;
