library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

use std.textio.all;
use ieee.std_logic_textio.all;
use std.env.finish;

library work;
use work.axi_lite_driver_pkg.all;

entity tb_axil_reg_file is
  --generic
  --(
  --  G_VLD_COEFF         : real                  := 0.5;
  --  G_RDY_COEFF         : real                  := 0.5;
  --  G_RAND_SEED         : integer               := 0;
  --  G_SAMPS_TO_CAPTURE  : integer               := 0;
  --  G_INPUT_FNAME       : string                := "";
  --  G_OUTPUT_FNAME      : string                := ""
  --);
end entity;

architecture behavioral of tb_axil_reg_file is

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

  procedure log_axi_stream
  (
    file_name         : in  string;
    num_samps         : in  integer;
    is_signed         : in  integer;
    signal clk        : in  std_logic;
    signal din        : in  std_logic_vector;
    signal din_valid  : in  std_logic;
    signal din_ready  : in  std_logic;
    signal din_last   : in  std_logic
  ) is
    file file_ptr       : text;
    variable v_oline    : line;
    variable v_counter  : integer;
  begin
    file_open(file_ptr, file_name, write_mode);
    v_counter := 0;

    while 1 = 1 loop
      wait until rising_edge(clk);
      if din_valid = '1' and din_ready = '1' then
        if is_signed = 1 then
          write(v_oline, to_integer(signed(din)));
        else
          write(v_oline, to_integer(unsigned(din)));
        end if;
        writeline(file_ptr, v_oline);
        if num_samps = 0 then
          if din_last = '1' then
            exit;
          end if;
        elsif v_counter = num_samps-1 then
          exit;
        end if;
        v_counter := v_counter + 1;
      end if;
    end loop;

    file_close(file_ptr);

  end procedure;

  procedure log_bin_axi_stream
  (
    file_name         : in  string;
    num_samps         : in  integer;
    bytes_per_samp    : in  integer;
    signal clk        : in  std_logic;
    signal din        : in  std_logic_vector;
    signal din_valid  : in  std_logic;
    signal din_ready  : in  std_logic;
    signal din_last   : in  std_logic
  ) is
    variable v_counter      : integer;
    variable v_char_buffer  : character;
    type char_file_t is file of character;
    file file_ptr           : char_file_t;

  begin
    file_open(file_ptr, file_name, write_mode);
    v_counter := 0;

    while 1 = 1 loop
      wait until rising_edge(clk);
      if din_valid = '1' and din_ready = '1' then
        for i in 0 to bytes_per_samp-1 loop
          v_char_buffer := character'val(to_integer(unsigned(din(i*8+7 downto i*8))));
          write(file_ptr, v_char_buffer);
        end loop;
        if num_samps = 0 then
          if din_last = '1' then
            exit;
          end if;
        elsif v_counter = num_samps-1 then
          exit;
        end if;
        v_counter := v_counter + 1;
      end if;
    end loop;

    file_close(file_ptr);

  end procedure;

  procedure generate_axi_stream
  (
    file_name               : in  string;
    signal clk              : in  std_logic;
    signal dout             : out integer;
    signal dout_valid_main  : out std_logic;
    signal dout_valid       : in  std_logic;
    signal dout_ready       : in  std_logic;
    signal dout_last        : out std_logic
  ) is
    file file_ptr         : text;
    variable v_iline      : line;
    variable v_flen       : integer;
    variable v_dout       : integer;
    variable v_line_count : integer;
  begin
    v_flen          := get_flen(file_name);
    file_open(file_ptr, file_name, read_mode);
    dout_valid_main <= '0';
    dout_last       <= '0';
    v_line_count    := 1;
    readline(file_ptr, v_iline);
    read(v_iline, v_dout);
    dout <= v_dout;
    wait until rising_edge(clk);
    dout_valid_main <= '1';

    while v_line_count <= v_flen loop
      wait until rising_edge(clk);
      if dout_valid = '1' and dout_ready = '1' then
        if v_line_count < v_flen then
          readline(file_ptr, v_iline);
          read(v_iline, v_dout);
        end if;
        dout <= v_dout;
        if v_line_count = v_flen-1 then
          dout_last <= '1';
        end if;
        v_line_count := v_line_count + 1;
      end if;
    end loop;

    file_close(file_ptr);
    dout_valid_main <= '0';
    dout_last       <= '0';
    wait until rising_edge(clk);
    dout_valid_main <= '0';
    dout_last       <= '0';

  end procedure;

  procedure generate_bin_axi_stream
  (
    file_name               : in  string;
    bytes_per_samp          : in  integer;
    file_len                : in  integer;
    signal clk              : in  std_logic;
    signal dout             : out std_logic_vector;
    signal dout_valid_main  : out std_logic;
    signal dout_valid       : in  std_logic;
    signal dout_ready       : in  std_logic;
    signal dout_last        : out std_logic
  ) is
    variable v_flen         : integer;
    variable v_line_count   : integer;

    variable v_char_buffer  : character;
    type char_file_t is file of character;
    file file_ptr           : char_file_t;
  begin

    file_open(file_ptr, file_name, read_mode);
    v_flen          := file_len;
    dout_valid_main <= '0';
    dout_last       <= '0';
    v_line_count    := 1;

    for i in 0 to bytes_per_samp-1 loop
      read(file_ptr, v_char_buffer);
      dout(i*8+8-1 downto i*8) <= std_logic_vector(to_unsigned(character'pos(v_char_buffer), 8));
    end loop;

    wait until rising_edge(clk);
    dout_valid_main <= '1';

    while v_line_count <= v_flen loop
      wait until rising_edge(clk);
      if dout_valid = '1' and dout_ready = '1' then
        if v_line_count < v_flen then
          for i in 0 to bytes_per_samp-1 loop
            read(file_ptr, v_char_buffer);
            dout(i*8+8-1 downto i*8) <= std_logic_vector(to_unsigned(character'pos(v_char_buffer), 8));
          end loop;
        end if;
        if v_line_count = v_flen-1 then
          dout_last <= '1';
        end if;
        v_line_count := v_line_count + 1;
      end if;
    end loop;

    file_close(file_ptr);
    dout_valid_main <= '0';
    dout_last       <= '0';
    wait until rising_edge(clk);
    dout_valid_main <= '0';
    dout_last       <= '0';

  end procedure;

  constant C_CLK_PERIOD   : time    := 20 ns; -- 50MHz
  signal clk              : std_logic;

  signal axi_lite_bus : axi_lite_bus_t;

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
    init_axi_driver(axi_lite_bus);
    reset_axi_driver(axi_lite_bus, clk);  




    wait;
  end process;

end behavioral;
