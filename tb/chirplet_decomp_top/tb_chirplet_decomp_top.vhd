library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

use std.textio.all;
use ieee.std_logic_textio.all;
use std.env.finish;

library work;
use work.axi_lite_driver_pkg.all;

entity tb_chirplet_decomp_top is
  generic
  (
    G_VLD_COEFF           : real                  := 0.5;
    G_RDY_COEFF           : real                  := 0.5;
    G_RAND_SEED           : integer               := 0;
    G_CHIRPLET_SAMPS      : integer               := 0;
    G_PARAMS_INPUT_FNAME  : string                := "";
    G_OUTPUT_FNAME        : string                := ""
  );
end entity;

architecture behavioral of tb_chirplet_decomp_top is

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

  constant C_CONTROL                  : std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0) := x"0000";
  --constant C_# enable [0]

  constant C_STATUS                   : std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0) := x"0004";
  --constant C_# chirp_gen_ready [0]

  constant C_CHIRP_GEN_NUM_SAMPS_OUT  : std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0) := x"0008";
  constant C_DIN_TAU                  : std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0) := x"000C";
  constant C_DIN_T_STEP               : std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0) := x"0010";
  constant C_DIN_ALPHA1               : std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0) := x"0014";
  constant C_DIN_F_C                  : std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0) := x"0018";
  constant C_DIN_ALPHA2               : std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0) := x"001C";
  constant C_DIN_PHI                  : std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0) := x"0020";
  constant C_DIN_BETA                 : std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0) := x"0024";
  constant C_XCORR_REF_SAMP           : std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0) := x"0028";
  constant XCORR_DOUT_RE_MSBS         : std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0) := x"002C";
  constant XCORR_DOUT_RE_LSBS         : std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0) := x"0030";
  constant XCORR_DOUT_IM_MSBS         : std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0) := x"0034";
  constant XCORR_DOUT_IM_LSBS         : std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0) := x"0038";
  constant CHIRPLET_FEEDBACK          : std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0) := x"003C";


  constant C_CLK_PERIOD : time    := 20 ns; -- 50MHz

  signal clk            : std_logic;
  signal axi_lite_bus   : axi_lite_bus_t;

begin

  u_dut : entity work.chirplet_decomp_top
    port map
    (
      s_axi_aclk    => clk,
      a_axi_aresetn => axi_lite_bus.axi_aresetn,

      s_axi_awaddr  => axi_lite_bus.axi_awaddr,
      s_axi_awvalid => axi_lite_bus.axi_awvalid,
      s_axi_awready => axi_lite_bus.axi_awready,

      s_axi_wdata   => axi_lite_bus.axi_wdata,
      s_axi_wstrb   => axi_lite_bus.axi_wstrb,
      s_axi_wvalid  => axi_lite_bus.axi_wvalid,
      s_axi_wready  => axi_lite_bus.axi_wready,

      s_axi_bresp   => axi_lite_bus.axi_bresp,
      s_axi_bvalid  => axi_lite_bus.axi_bvalid,
      s_axi_bready  => axi_lite_bus.axi_bready,

      s_axi_araddr  => axi_lite_bus.axi_araddr,
      s_axi_arvalid => axi_lite_bus.axi_arvalid,
      s_axi_arready => axi_lite_bus.axi_arready,

      s_axi_rdata   => axi_lite_bus.axi_rdata,
      s_axi_rresp   => axi_lite_bus.axi_rresp,
      s_axi_rvalid  => axi_lite_bus.axi_rvalid,
      s_axi_rready  => axi_lite_bus.axi_rready
    );

  p_clk : process
  begin
    wait for C_CLK_PERIOD/2;
    clk <= '0';
    wait for C_CLK_PERIOD/2;
    clk <= '1';
  end process;

  p_main : process
    variable address        : std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
    variable reg_val        : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
    variable bit_val        : std_logic;
    variable bit_pos        : integer;

    variable v_char_buffer  : character;
    type char_file_t is file of character;
    file file_ptr           : char_file_t;
  begin
    init_axi_driver(axi_lite_bus);
    reset_axi_driver(axi_lite_bus, clk);  

    address := C_CONTROL;
    reg_val := x"00000000";
    axi_write_reg(axi_lite_bus => axi_lite_bus, axi_aclk => clk, address => address, d_value => reg_val);

    address := C_CONTROL;
    reg_val := x"00000001";
    axi_write_reg(axi_lite_bus => axi_lite_bus, axi_aclk => clk, address => address, d_value => reg_val);


    address := C_XCORR_REF_SAMP;
    reg_val := x"00000000";
    for i in 0 to 10048 loop
      axi_write_reg(axi_lite_bus => axi_lite_bus, axi_aclk => clk, address => address, d_value => reg_val);
    end loop;


    address := C_STATUS;
    bit_pos := 0;
    bit_val := '0';
    while bit_val = '0' loop
      --axi_read_reg(axi_lite_bus => axi_lite_bus, axi_aclk => clk, address => address, d_value => reg_val);
      axi_read_bit(axi_lite_bus => axi_lite_bus, axi_aclk => clk, address => address, bit_value => bit_val, bit_position => bit_pos);
    end loop;

    address := C_CHIRP_GEN_NUM_SAMPS_OUT;
    reg_val := std_logic_vector(to_unsigned(G_CHIRPLET_SAMPS, C_S_AXI_DATA_WIDTH));
    axi_write_reg(axi_lite_bus => axi_lite_bus, axi_aclk => clk, address => address, d_value => reg_val);

    file_open(file_ptr, G_PARAMS_INPUT_FNAME(G_PARAMS_INPUT_FNAME'left to G_PARAMS_INPUT_FNAME'right-3) & "bin");
    
    for i in 0 to 3 loop
      read(file_ptr, v_char_buffer);
      reg_val(i*8+8-1 downto i*8) := std_logic_vector(to_unsigned(character'pos(v_char_buffer), 8));
    end loop;
    address := C_DIN_T_STEP;
    axi_write_reg(axi_lite_bus => axi_lite_bus, axi_aclk => clk, address => address, d_value => reg_val);
    
    for i in 0 to 3 loop
      read(file_ptr, v_char_buffer);
      reg_val(i*8+8-1 downto i*8) := std_logic_vector(to_unsigned(character'pos(v_char_buffer), 8));
    end loop;
    address := C_DIN_TAU;
    axi_write_reg(axi_lite_bus => axi_lite_bus, axi_aclk => clk, address => address, d_value => reg_val);
    
    for i in 0 to 3 loop
      read(file_ptr, v_char_buffer);
      reg_val(i*8+8-1 downto i*8) := std_logic_vector(to_unsigned(character'pos(v_char_buffer), 8));
    end loop;
    address := C_DIN_ALPHA1;
    axi_write_reg(axi_lite_bus => axi_lite_bus, axi_aclk => clk, address => address, d_value => reg_val);
    
    for i in 0 to 3 loop
      read(file_ptr, v_char_buffer);
      reg_val(i*8+8-1 downto i*8) := std_logic_vector(to_unsigned(character'pos(v_char_buffer), 8));
    end loop;
    address := C_DIN_F_C;
    axi_write_reg(axi_lite_bus => axi_lite_bus, axi_aclk => clk, address => address, d_value => reg_val);
    
    for i in 0 to 3 loop
      read(file_ptr, v_char_buffer);
      reg_val(i*8+8-1 downto i*8) := std_logic_vector(to_unsigned(character'pos(v_char_buffer), 8));
    end loop;
    address := C_DIN_ALPHA2;
    axi_write_reg(axi_lite_bus => axi_lite_bus, axi_aclk => clk, address => address, d_value => reg_val);
    
    for i in 0 to 3 loop
      read(file_ptr, v_char_buffer);
      reg_val(i*8+8-1 downto i*8) := std_logic_vector(to_unsigned(character'pos(v_char_buffer), 8));
    end loop;
    address := C_DIN_PHI;
    axi_write_reg(axi_lite_bus => axi_lite_bus, axi_aclk => clk, address => address, d_value => reg_val);
    
    for i in 0 to 3 loop
      read(file_ptr, v_char_buffer);
      reg_val(i*8+8-1 downto i*8) := std_logic_vector(to_unsigned(character'pos(v_char_buffer), 8));
    end loop;
    address := C_DIN_BETA;
    axi_write_reg(axi_lite_bus => axi_lite_bus, axi_aclk => clk, address => address, d_value => reg_val);
    
    file_close(file_ptr);
    
    address := C_STATUS;
    bit_pos := 1;
    bit_val := '0';
    while bit_val = '0' loop
      --axi_read_reg(axi_lite_bus => axi_lite_bus, axi_aclk => clk, address => address, d_value => reg_val);
      axi_read_bit(axi_lite_bus => axi_lite_bus, axi_aclk => clk, address => address, bit_value => bit_val, bit_position => bit_pos);
    end loop;
    
    address := XCORR_DOUT_RE_MSBS;
    axi_read_reg(axi_lite_bus => axi_lite_bus, axi_aclk => clk, address => address, d_value => reg_val);
    
    address := XCORR_DOUT_RE_LSBS;
    axi_read_reg(axi_lite_bus => axi_lite_bus, axi_aclk => clk, address => address, d_value => reg_val);
    
    address := XCORR_DOUT_IM_MSBS;
    axi_read_reg(axi_lite_bus => axi_lite_bus, axi_aclk => clk, address => address, d_value => reg_val);
    
    address := XCORR_DOUT_IM_LSBS;
    axi_read_reg(axi_lite_bus => axi_lite_bus, axi_aclk => clk, address => address, d_value => reg_val);

    ---------------------------------------
    -- feedback mode:
    address := C_CONTROL;
    reg_val := x"00000003";
    axi_write_reg(axi_lite_bus => axi_lite_bus, axi_aclk => clk, address => address, d_value => reg_val);

    address := C_STATUS;
    bit_pos := 0;
    bit_val := '0';
    while bit_val = '0' loop
      axi_read_bit(axi_lite_bus => axi_lite_bus, axi_aclk => clk, address => address, bit_value => bit_val, bit_position => bit_pos);
    end loop;

    file_open(file_ptr, G_PARAMS_INPUT_FNAME(G_PARAMS_INPUT_FNAME'left to G_PARAMS_INPUT_FNAME'right-3) & "bin");

    for i in 0 to 3 loop
      read(file_ptr, v_char_buffer);
      reg_val(i*8+8-1 downto i*8) := std_logic_vector(to_unsigned(character'pos(v_char_buffer), 8));
    end loop;
    address := C_DIN_T_STEP;
    axi_write_reg(axi_lite_bus => axi_lite_bus, axi_aclk => clk, address => address, d_value => reg_val);

    for i in 0 to 3 loop
      read(file_ptr, v_char_buffer);
      reg_val(i*8+8-1 downto i*8) := std_logic_vector(to_unsigned(character'pos(v_char_buffer), 8));
    end loop;
    address := C_DIN_TAU;
    axi_write_reg(axi_lite_bus => axi_lite_bus, axi_aclk => clk, address => address, d_value => reg_val);

    for i in 0 to 3 loop
      read(file_ptr, v_char_buffer);
      reg_val(i*8+8-1 downto i*8) := std_logic_vector(to_unsigned(character'pos(v_char_buffer), 8));
    end loop;
    address := C_DIN_ALPHA1;
    axi_write_reg(axi_lite_bus => axi_lite_bus, axi_aclk => clk, address => address, d_value => reg_val);

    for i in 0 to 3 loop
      read(file_ptr, v_char_buffer);
      reg_val(i*8+8-1 downto i*8) := std_logic_vector(to_unsigned(character'pos(v_char_buffer), 8));
    end loop;
    address := C_DIN_F_C;
    axi_write_reg(axi_lite_bus => axi_lite_bus, axi_aclk => clk, address => address, d_value => reg_val);

    for i in 0 to 3 loop
      read(file_ptr, v_char_buffer);
      reg_val(i*8+8-1 downto i*8) := std_logic_vector(to_unsigned(character'pos(v_char_buffer), 8));
    end loop;
    address := C_DIN_ALPHA2;
    axi_write_reg(axi_lite_bus => axi_lite_bus, axi_aclk => clk, address => address, d_value => reg_val);

    for i in 0 to 3 loop
      read(file_ptr, v_char_buffer);
      reg_val(i*8+8-1 downto i*8) := std_logic_vector(to_unsigned(character'pos(v_char_buffer), 8));
    end loop;
    address := C_DIN_PHI;
    axi_write_reg(axi_lite_bus => axi_lite_bus, axi_aclk => clk, address => address, d_value => reg_val);

    for i in 0 to 3 loop
      read(file_ptr, v_char_buffer);
      reg_val(i*8+8-1 downto i*8) := std_logic_vector(to_unsigned(character'pos(v_char_buffer), 8));
    end loop;
    address := C_DIN_BETA;
    axi_write_reg(axi_lite_bus => axi_lite_bus, axi_aclk => clk, address => address, d_value => reg_val);

    file_close(file_ptr);

    wait for C_CLK_PERIOD*100;

    address := CHIRPLET_FEEDBACK;
    for i in 0 to 1258*8-1 loop
      axi_read_reg(axi_lite_bus => axi_lite_bus, axi_aclk => clk, address => address, d_value => reg_val);
    end loop;


    wait for C_CLK_PERIOD*100;
    report "simulation finished" severity failure;

    wait;
  end process;

end behavioral;
