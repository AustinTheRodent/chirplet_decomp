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


  component chirplet_gen is
    port
    (
      clk             : in std_logic;
      reset           : in std_logic;
      enable          : in std_logic;
  
      din_tau         : in  std_logic_vector(31 downto 0); -- floating point
      din_t_step      : in  std_logic_vector(31 downto 0); -- floating point
      din_alpha1      : in  std_logic_vector(31 downto 0); -- floating point
      din_f_c         : in  std_logic_vector(31 downto 0); -- floating point
      din_alpha2      : in  std_logic_vector(31 downto 0); -- floating point
      din_phi         : in  std_logic_vector(31 downto 0); -- floating point
      din_beta        : in  std_logic_vector(31 downto 0); -- floating point
      din_valid       : in  std_logic;
      din_ready       : out std_logic;
      din_last        : in  std_logic;
  
      dout            : out std_logic_vector(31 downto 0);
      dout_valid      : out std_logic;
      dout_ready      : in  std_logic;
      dout_last       : out std_logic
    );
  end component;

  constant C_SAMPS_TO_CAPTURE : integer := 10000;

  constant C_CLK_PERIOD   : time    := 20 ns; -- 50MHz
  constant C_DWIDTH       : integer := 32;
  constant C_AWIDTH       : integer := 16;

  signal clk              : std_logic;
  signal dut_reset        : std_logic;
  signal dut_enable       : std_logic;

  signal input_counter    : unsigned(31 downto 0);
  signal output_counter   : unsigned(31 downto 0);

  signal time_step        : std_logic_vector(31 downto 0);
  signal tau              : std_logic_vector(31 downto 0);
  signal alpha1           : std_logic_vector(31 downto 0);
  signal f_c              : std_logic_vector(31 downto 0);
  signal alpha2           : std_logic_vector(31 downto 0);
  signal phi              : std_logic_vector(31 downto 0);
  signal beta             : std_logic_vector(31 downto 0);

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

  signal stream_log1_data        : std_logic_vector(31 downto 0);
  signal stream_log1_data_valid  : std_logic;
  signal stream_log1_data_ready  : std_logic;
  signal stream_log1_data_last   : std_logic;

  signal stream_log2_data        : std_logic_vector(31 downto 0);
  signal stream_log2_data_valid  : std_logic;
  signal stream_log2_data_ready  : std_logic;
  signal stream_log2_data_last   : std_logic;

  signal stream_log3_data        : std_logic_vector(31 downto 0);
  signal stream_log3_data_valid  : std_logic;
  signal stream_log3_data_ready  : std_logic;
  signal stream_log3_data_last   : std_logic;

  signal stream_log4_data        : std_logic_vector(31 downto 0);
  signal stream_log4_data_valid  : std_logic;
  signal stream_log4_data_ready  : std_logic;
  signal stream_log4_data_last   : std_logic;

  signal stream_log5_data        : std_logic_vector(31 downto 0);
  signal stream_log5_data_valid  : std_logic;
  signal stream_log5_data_ready  : std_logic;
  signal stream_log5_data_last   : std_logic;

  signal stream_log6_data        : std_logic_vector(31 downto 0);
  signal stream_log6_data_valid  : std_logic;
  signal stream_log6_data_ready  : std_logic;
  signal stream_log6_data_last   : std_logic;

begin

  p_clk : process
  begin
    wait for C_CLK_PERIOD/2;
    clk <= '0';
    wait for C_CLK_PERIOD/2;
    clk <= '1';
  end process;

  p_main : process

    variable v_char_buffer  : character;

    type char_file_t is file of character;
    file file_ptr : char_file_t;

  begin
    -- reset signals to defaults:
    dut_reset       <= '1';
    dut_enable      <= '0';
    dut_din_integer <= 0;
    dut_din_last    <= '0';
    din_valid_main  <= '0';

    file_open(file_ptr, G_INPUT_FNAME(G_INPUT_FNAME'left to G_INPUT_FNAME'right-3) & "bin");
    for i in 0 to 3 loop
      read(file_ptr, v_char_buffer);
      time_step(i*8+8-1 downto i*8) <= std_logic_vector(to_unsigned(character'pos(v_char_buffer), 8));
    end loop;

    for i in 0 to 3 loop
      read(file_ptr, v_char_buffer);
      tau(i*8+8-1 downto i*8) <= std_logic_vector(to_unsigned(character'pos(v_char_buffer), 8));
    end loop;

    for i in 0 to 3 loop
      read(file_ptr, v_char_buffer);
      alpha1(i*8+8-1 downto i*8) <= std_logic_vector(to_unsigned(character'pos(v_char_buffer), 8));
    end loop;

    for i in 0 to 3 loop
      read(file_ptr, v_char_buffer);
      f_c(i*8+8-1 downto i*8) <= std_logic_vector(to_unsigned(character'pos(v_char_buffer), 8));
    end loop;

    for i in 0 to 3 loop
      read(file_ptr, v_char_buffer);
      alpha2(i*8+8-1 downto i*8) <= std_logic_vector(to_unsigned(character'pos(v_char_buffer), 8));
    end loop;

    for i in 0 to 3 loop
      read(file_ptr, v_char_buffer);
      phi(i*8+8-1 downto i*8) <= std_logic_vector(to_unsigned(character'pos(v_char_buffer), 8));
    end loop;

    for i in 0 to 3 loop
      read(file_ptr, v_char_buffer);
      beta(i*8+8-1 downto i*8) <= std_logic_vector(to_unsigned(character'pos(v_char_buffer), 8));
    end loop;
    file_close(file_ptr);


    wait for C_CLK_PERIOD*100;
    wait until rising_edge(clk);
    dut_reset   <= '0';
    dut_enable  <= '1';

    wait until rising_edge(clk);

    din_valid_main  <= '1';

    --generate_axi_stream
    --(
    --  G_INPUT_FNAME,
    --  clk,
    --  dut_din_integer,
    --  din_valid_main,
    --  dut_din_valid,
    --  dut_din_ready,
    --  dut_din_last
    --);

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

  stream_log1_data       <= << signal u_dut.fc_times_phi_real     : std_logic_vector(31 downto 0) >>;
  stream_log1_data_valid <= << signal u_dut.final_mult_din_valid  : std_logic >>;
  stream_log1_data_ready <= << signal u_dut.final_mult_din_ready  : std_logic >>;
  stream_log1_data_last  <= '0';


  stream_log2_data       <= << signal u_dut.fc_times_phi_imag     : std_logic_vector(31 downto 0) >>;
  stream_log2_data_valid <= << signal u_dut.final_mult_din_valid  : std_logic >>;
  stream_log2_data_ready <= << signal u_dut.final_mult_din_ready  : std_logic >>;
  stream_log2_data_last  <= '0';


  stream_log3_data       <= << signal u_dut.alpha2_times_gauss_real : std_logic_vector(31 downto 0) >>;
  stream_log3_data_valid <= << signal u_dut.final_mult_din_valid    : std_logic >>;
  stream_log3_data_ready <= << signal u_dut.final_mult_din_ready    : std_logic >>;
  stream_log3_data_last  <= '0';


  stream_log4_data       <= << signal u_dut.alpha2_times_gauss_imag : std_logic_vector(31 downto 0) >>;
  stream_log4_data_valid <= << signal u_dut.final_mult_din_valid    : std_logic >>;
  stream_log4_data_ready <= << signal u_dut.final_mult_din_ready    : std_logic >>;
  stream_log4_data_last  <= '0';


  stream_log5_data       <= << signal u_dut.final_mult_real       : std_logic_vector(31 downto 0) >>;
  stream_log5_data_valid <= << signal u_dut.final_mult_dout_valid : std_logic >>;
  stream_log5_data_ready <= << signal u_dut.final_mult_dout_ready : std_logic >>;
  stream_log5_data_last  <= '0';


  stream_log6_data       <= << signal u_dut.final_mult_imag       : std_logic_vector(31 downto 0) >>;
  stream_log6_data_valid <= << signal u_dut.final_mult_dout_valid : std_logic >>;
  stream_log6_data_ready <= << signal u_dut.final_mult_dout_ready : std_logic >>;
  stream_log6_data_last  <= '0';

  p_log1_output : process
  begin

    log_bin_axi_stream
    (
      G_OUTPUT_FNAME & "fc_times_phi_real.bin",
      C_SAMPS_TO_CAPTURE,
      4,
      clk,
      stream_log1_data,
      stream_log1_data_valid,
      stream_log1_data_ready,
      stream_log1_data_last
    );
  
    wait for C_CLK_PERIOD*10;
    wait;
    --report "simulation finished" severity failure;
  end process;

  p_log2_output : process
  begin

    log_bin_axi_stream
    (
      G_OUTPUT_FNAME & "fc_times_phi_imag.bin",
      C_SAMPS_TO_CAPTURE,
      4,
      clk,
      stream_log2_data,
      stream_log2_data_valid,
      stream_log2_data_ready,
      stream_log2_data_last
    );
  
    wait for C_CLK_PERIOD*10;
    wait;
    --report "simulation finished" severity failure;
  end process;

  p_log3_output : process
  begin

    log_bin_axi_stream
    (
      G_OUTPUT_FNAME & "alpha2_times_gauss_real.bin",
      C_SAMPS_TO_CAPTURE,
      4,
      clk,
      stream_log3_data,
      stream_log3_data_valid,
      stream_log3_data_ready,
      stream_log3_data_last
    );
  
    wait for C_CLK_PERIOD*10;
    wait;
    --report "simulation finished" severity failure;
  end process;

  p_log4_output : process
  begin

    log_bin_axi_stream
    (
      G_OUTPUT_FNAME & "alpha2_times_gauss_imag.bin",
      C_SAMPS_TO_CAPTURE,
      4,
      clk,
      stream_log4_data,
      stream_log4_data_valid,
      stream_log4_data_ready,
      stream_log4_data_last
    );
  
    wait for C_CLK_PERIOD*10;
    wait;
    --report "simulation finished" severity failure;
  end process;

  p_log5_output : process
  begin

    log_bin_axi_stream
    (
      G_OUTPUT_FNAME & "final_mult_real.bin",
      C_SAMPS_TO_CAPTURE,
      4,
      clk,
      stream_log5_data,
      stream_log5_data_valid,
      stream_log5_data_ready,
      stream_log5_data_last
    );
  
    wait for C_CLK_PERIOD*10;
    wait;
    --report "simulation finished" severity failure;
  end process;

  p_log6_output : process
  begin

    log_bin_axi_stream
    (
      G_OUTPUT_FNAME & "final_mult_imag.bin",
      C_SAMPS_TO_CAPTURE,
      4,
      clk,
      stream_log6_data,
      stream_log6_data_valid,
      stream_log6_data_ready,
      stream_log6_data_last
    );
  
    wait for C_CLK_PERIOD*10;
    report "simulation finished" severity failure;
    wait;
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

  u_dut : chirplet_gen
    port map
    (
      clk             => clk,
      reset           => dut_reset,
      enable          => dut_enable,
  
      din_tau         => tau,
      din_t_step      => time_step,
      din_alpha1      => alpha1,
      din_f_c         => f_c,
      din_alpha2      => alpha2,
      din_phi         => phi,
      din_beta        => beta,
      din_valid       => dut_din_valid,
      din_ready       => open,
      din_last        => '0',
  
      dout            => open,
      dout_valid      => open,
      dout_ready      => dout_ready_rand,
      dout_last       => open
    );

end behavioral;
