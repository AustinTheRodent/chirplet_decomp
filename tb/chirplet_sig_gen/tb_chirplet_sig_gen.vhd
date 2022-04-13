library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

use std.textio.all;
use ieee.std_logic_textio.all;
use std.env.finish;

-- todo:
  --binary read/write file io
  --eval exponential LUT

entity tb_chirplet_sig_gen is
  generic
  (
    G_VLD_COEFF         : real                  := 0.5;
    G_RDY_COEFF         : real                  := 0.5;
    G_RAND_SEED         : integer               := 0;
    G_INPUT_FNAME       : string                := "";
    G_OUTPUT_FNAME      : string                := ""
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
    file_open(file_ptr, file_name, read_mode);
    v_flen          := get_flen(file_name);
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

  constant C_CLK_PERIOD   : time    := 20 ns; -- 50MHz
  constant C_DWIDTH       : integer := 32;
  constant C_AWIDTH       : integer := 16;

  signal clk              : std_logic;
  signal dut_reset        : std_logic;
  signal dut_enable       : std_logic;

  signal input_counter    : unsigned(31 downto 0);
  signal output_counter   : unsigned(31 downto 0);

  --signal dut_prog_data    : std_logic_vector(C_DWIDTH-1 downto 0);
  --signal dut_prog_addr    : std_logic_vector(C_AWIDTH-1 downto 0);
  --signal dut_prog_en      : std_logic;
  --signal dut_prog_done    : std_logic;

  signal dut_din          : std_logic_vector(C_AWIDTH-1 downto 0);
  signal dut_din_integer  : integer := 0;
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
    dut_din_integer <= 0;
    dut_din_last    <= '0';
    din_valid_main  <= '0';

    --dut_prog_data   <= (others => '0');
    --dut_prog_addr   <= (others => '0');
    --dut_prog_en     <= '0';
    --dut_prog_done   <= '0';

    wait for C_CLK_PERIOD*100;
    wait until rising_edge(clk);
    dut_reset   <= '0';
    dut_enable  <= '1';

    wait until rising_edge(clk);

    --for i in 0 to 2**C_AWIDTH-1 loop
    --  dut_prog_en <= '1';
    --  dut_prog_addr <= std_logic_vector(to_unsigned(i, dut_prog_addr'length));
    --  dut_prog_data <= std_logic_vector(to_unsigned(i, dut_prog_data'length));
    --  wait until rising_edge(clk);
    --end loop;
    --dut_prog_done   <= '1';
    --dut_prog_en     <= '0';

    generate_axi_stream
    (
      G_INPUT_FNAME,
      clk,
      dut_din_integer,
      din_valid_main,
      dut_din_valid,
      dut_din_ready,
      dut_din_last
    );

    wait;

  end process;

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

  p_log_output : process
  begin
    --log_axi_stream
    --(
    --  G_OUTPUT_FNAME,
    --  0,
    --  0,
    --  clk,
    --  dut_dout,
    --  dut_dout_valid,
    --  dut_dout_ready,
    --  dut_dout_last
    --);

    log_bin_axi_stream
    (
      G_OUTPUT_FNAME,
      0,
      4,
      clk,
      dut_dout,
      dut_dout_valid,
      dut_dout_ready,
      dut_dout_last
    );
  
    wait for C_CLK_PERIOD*10;
    report "simulation finished" severity failure;
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

  dut_din         <= std_logic_vector(to_unsigned(dut_din_integer, dut_din'length));


  u_dut : exponential_lut
    generic map
    (
      G_BUFFER_INPUT  => true,
      G_BUFFER_OUTPUT => true
    )
    port map
    (
      clk             => clk,
      reset           => dut_reset,
      enable          => dut_enable,

      din             => dut_din,
      din_valid       => dut_din_valid,
      din_ready       => dut_din_ready,
      din_last        => dut_din_last,

      dout            => dut_dout,
      dout_valid      => dut_dout_valid,
      dout_ready      => dut_dout_ready,
      dout_last       => dut_dout_last
    );

  --u_dut : axis_lut
  --  generic map
  --  (
  --    G_AWIDTH        => C_AWIDTH,
  --    G_DWIDTH        => C_DWIDTH,
  --    G_BUFFER_INPUT  => true,
  --    G_BUFFER_OUTPUT => true
  --  )
  --  port map
  --  (
  --    clk         => clk,
  --    reset       => dut_reset,
  --    enable      => dut_enable,
  --
  --    prog_data   => dut_prog_data,
  --    prog_addr   => dut_prog_addr,
  --    prog_en     => dut_prog_en,
  --    prog_done   => dut_prog_done,
  --
  --    din         => dut_din,
  --    din_valid   => dut_din_valid,
  --    din_ready   => dut_din_ready,
  --    din_last    => dut_din_last,
  --
  --    dout        => dut_dout,
  --    dout_valid  => dut_dout_valid,
  --    dout_ready  => dut_dout_ready,
  --    dout_last   => dut_dout_last
  --  );


end behavioral;
