def write_all(reg_file_obj, constants, registers):
    reg_file_obj.write('''\
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package reg_file_pkg is\n
''')
    
    for line in constants:
        if line[0] == "REG_FILE_DATA_WIDTH":
            REG_FILE_DATA_WIDTH = line[1]
        if line[0] == "REG_FILE_ADDR_WIDTH":
            REG_FILE_ADDR_WIDTH = line[1]
        if line[0] == "REG_FILE_MSB_FIRST":
            REG_FILE_MSB_FIRST = line[1]
    
    reg_file_obj.write("    constant REG_FILE_DATA_WIDTH : integer := %i;\n" % REG_FILE_DATA_WIDTH);
    reg_file_obj.write("    constant REG_FILE_ADDR_WIDTH : integer := %i;\n" % REG_FILE_ADDR_WIDTH);
    reg_file_obj.write("    constant REG_FILE_MSB_FIRST : integer := %i;\n\n" % REG_FILE_MSB_FIRST);
    reg_file_obj.write("    type reg_t is record\n");
    
    for reg_line in registers:
        reg_file_obj.write("        %s : std_logic_vector(REG_FILE_DATA_WIDTH-1 downto 0); -- %s\n" % (reg_line[0], reg_line[1]))
        if reg_line[1] == "RW":
            reg_file_obj.write("        %s_pulse : std_logic;\n" % reg_line[0])
        reg_file_obj.write("\n")
    reg_file_obj.write("    end record;\n\n")
    reg_file_obj.write("    type transaction_state_t is (get_addr, load_reg, write_reg, read_reg);\n\n")
    reg_file_obj.write("end package;\n\n")
    reg_file_obj.write('''\
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.reg_file_pkg.all;

entity reg_file is
    port
    (
        clk : in std_logic;
        reset : in std_logic;
        
        transaction_en : in std_logic;
        rw : in std_logic; -- '0' = read, '1' = write
        rw_ready : out std_logic;
        
        reg_cs : in std_logic;
        reg_spi_clk : in std_logic;
        reg_miso : out std_logic;
        reg_mosi : in std_logic;\n
''')
    for reg_index in range(len(registers)):
        if registers[reg_index][1] == "RO":
            reg_file_obj.write("        %s : in std_logic_vector(REG_FILE_DATA_WIDTH-1 downto 0);\n" % (registers[reg_index][0]))
    reg_file_obj.write('''\n\
        reg_out : out reg_t        

    );
end entity;

architecture rtl of reg_file is

    component spi_slave is
        generic
        (
            constant DWIDTH : natural range 1 to 32;
            constant MSB_FIRST : natural range 0 to 1 -- 0=LSB_FIRST
        );
        port
        (
            clk : in std_logic;
            reset : in std_logic;
            enable : in std_logic;
            
            chip_select : in std_logic;
            spi_clk : in std_logic;
            spi_data_out : out std_logic;
            spi_data_in : in std_logic;
            
            din : in std_logic_vector(DWIDTH-1 downto 0);
            din_valid : in std_logic;
            din_last : in std_logic;
            din_ready : out std_logic;
            
            dout : out std_logic_vector(DWIDTH-1 downto 0);
            dout_valid : out std_logic;
            dout_last : out std_logic;
            dout_ready : in std_logic
        );
    end component;
    
''')

    for reg_index in range(len(registers)):
        reg_file_obj.write("    constant %s_addr : integer range 0 to 2**REG_FILE_ADDR_WIDTH-1 := %i;\n" % (registers[reg_index][0], registers[reg_index][2]))

    reg_file_obj.write('''
    signal transaction_state : transaction_state_t;
    signal reg_int : reg_t;

    signal rw_ready_int : std_logic;
    signal address : integer range -1 to 2**REG_FILE_ADDR_WIDTH-1;

    signal spi_slv_dout : std_logic_vector(REG_FILE_ADDR_WIDTH-1 downto 0);
    signal spi_slv_dout_valid : std_logic;
    signal spi_slv_din_valid : std_logic;
    signal spi_slv_din_ready : std_logic;
    signal spi_slv_din : std_logic_vector(REG_FILE_DATA_WIDTH-1 downto 0);

    signal transaction_en_cross_0 : std_logic;
    signal transaction_en_cross_1 : std_logic;
    signal rw_cross_0 : std_logic;
    signal rw_cross_1 : std_logic;

begin

    p_domain_cross : process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                transaction_en_cross_0 <= '0';
                transaction_en_cross_1 <= '0';
                
                rw_cross_0 <= '0';
                rw_cross_1 <= '0';
            else
                transaction_en_cross_0 <= transaction_en;
                transaction_en_cross_1 <= transaction_en_cross_0;
                
                rw_cross_0 <= rw;
                rw_cross_1 <= rw_cross_0;
            end if;
        end if;
    end process;
    
    reg_out <= reg_int;
    rw_ready <= rw_ready_int;
''')
        
    reg_file_obj.write("\n")
    reg_file_obj.write("    spi_slv_din <=\n")
    for reg_index in range(len(registers)):
        reg_file_obj.write("        reg_int.%s when address = %s_addr else\n" % (registers[reg_index][0],registers[reg_index][0]))
    reg_file_obj.write("        (others => '0');\n")

    reg_file_obj.write('''
    p_write_reg : process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
''')

    for reg_index in range(len(registers)):
        if registers[reg_index][1] == "RW":
                reg_file_obj.write("                reg_int.%s <= std_logic_vector(to_unsigned(%i, REG_FILE_DATA_WIDTH));\n" % \
                                  (registers[reg_index][0],registers[reg_index][3]))
                reg_file_obj.write("                reg_int.%s_pulse <= '0';\n" % \
                                  (registers[reg_index][0]))

    reg_file_obj.write('''
            else
                if transaction_state = write_reg and
                   spi_slv_dout_valid = '1' and
                   rw_cross_1 = '1' and
                   transaction_en_cross_1 = '1' and
                   rw_ready_int = '1' then
                    case (address) is 
''')

    for reg_index in range(len(registers)):
        if registers[reg_index][1] == "RW":
            reg_file_obj.write("                        when %s_addr =>\n" % registers[reg_index][0])
            reg_file_obj.write("                            reg_int.%s <= spi_slv_dout;\n" % registers[reg_index][0])
            reg_file_obj.write("                            reg_int.%s_pulse <= '1';\n" % registers[reg_index][0])


    reg_file_obj.write("                        when others =>\n")
    for reg_index in range(len(registers)):
        if registers[reg_index][1] == "RW":
            reg_file_obj.write("                            reg_int.%s <= reg_int.%s;\n" % (registers[reg_index][0], registers[reg_index][0]))
        
    reg_file_obj.write('''
                    end case;
                else
''')

    for reg_index in range(len(registers)):
        if registers[reg_index][1] == "RW":
            reg_file_obj.write("                    reg_int.%s_pulse <= '0';\n" % registers[reg_index][0])

    reg_file_obj.write('''
                end if;
            end if;
        end if;
    end process;

''')

    for reg_index in range(len(registers)):
        if registers[reg_index][1] == "RO":
            reg_file_obj.write("    reg_int.%s <= %s;\n"\
                                % (registers[reg_index][0], registers[reg_index][0]))
    
    reg_file_obj.write('''
    p_transaction_sm : process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                transaction_state <= get_addr;
                rw_ready_int <= '0';
                spi_slv_din_valid <= '0';
                address <= -1;
            else
                case(transaction_state) is 
                    when get_addr =>
                        rw_ready_int <= '0';
                        if spi_slv_dout_valid = '1' then
                            address <= to_integer(unsigned(spi_slv_dout));
                            transaction_state <= load_reg;
                            spi_slv_din_valid <= '1';
                        end if;
                        
                    when load_reg =>
                        if spi_slv_din_ready = '1' then
                            spi_slv_din_valid <= '0';
                            if rw_cross_1 = '1' then
                                transaction_state <= write_reg;
                            else
                                transaction_state <= read_reg;
                            end if; 
                        end if;
                        
                    when write_reg =>
                        rw_ready_int <= '1';
                        if spi_slv_dout_valid = '1' then
                            transaction_state <= get_addr;
                        end if;
                        
                    when read_reg =>
                        rw_ready_int <= '1';
                        if spi_slv_dout_valid = '1' then
                            transaction_state <= get_addr;
                        end if;
                            
                    when others =>
                        transaction_state <= get_addr;
                        
                end case;
                
                if transaction_en_cross_1 = '0' then
                    transaction_state <= get_addr;
                end if;
                
            end if;
        end if;
    end process;

    u_spi_slave : spi_slave
        generic map
        (
            DWIDTH => REG_FILE_DATA_WIDTH,
            MSB_FIRST => REG_FILE_MSB_FIRST
        )
        port map
        (
            clk => clk,
            reset => reset,
            enable => '1',
            
            chip_select => reg_cs,
            spi_clk => reg_spi_clk,
            spi_data_out => reg_miso,
            spi_data_in => reg_mosi,
            
            din => spi_slv_din,
            din_valid => spi_slv_din_valid,
            din_last => '0',
            din_ready => spi_slv_din_ready,
            
            dout => spi_slv_dout,
            dout_valid => spi_slv_dout_valid,
            dout_last => open,
            dout_ready => '1'
        );

end rtl;
''')

def get_constants(data_file_name):
    data_file_obj = open(data_file_name, "r")
    num_constants = 0
    for line in data_file_obj:
        if line[0] == "[":
            num_constants += 1
    data_file_obj.seek(0)
    
    constants = [[str, str] for i in range(num_constants)]
    constant_count = 0
    for line in data_file_obj:
        if line[0] != "#":
            if line[0] == "[":
                name = line[1:line.find(" ")]
                val = line[line.find(" ")+1:line.find("]")]
                constants[constant_count] = [name, int(val)]
                constant_count += 1
            
    data_file_obj.close()
    return constants

def get_registers(data_file_name):
    data_file_obj = open(data_file_name, "r")
    reg_count = 0
    
    for line in data_file_obj:
        if (line[0] != "#") and (line[0] != "[") and (line != "") and (line != "\n"):
            reg_count += 1
    
    data_file_obj.seek(0)
    registers = [[None, None, None] for i in range(reg_count)]
    reg_count = 0
    for line in data_file_obj:
        if (line[0] != "#") and (line[0] != "[") and (line != "") and (line != "\n"):
            name = line[0:line.find(" ")]
            line = line[line.find(" ")+1:len(line)]
            type = line[0:line.find(" ")]
            line = line[line.find(" ")+1:len(line)]
            address = line[0:line.find(" ")]
            if address[0:2] == "0x":
                address = int(address[2:len(address)], 16)
            else:
                address = int(address)
            line = line[line.find(" ")+1:len(line)]
            reset_val = line[0:line.find(" ")]
            if reset_val[0:2] == "0x":
                reset_val = int(reset_val[2:len(reset_val)], 16)
            else:
                reset_val = int(reset_val)
            registers[reg_count] = [name, type, address, reset_val]
            reg_count += 1
    
    data_file_obj.close()
    return registers
    

def main():
    print("Starting Register File HDL Generator")
    reg_file_name = "reg_file.vhd"
    data_file_name = "registers.dat"
    constants = get_constants(data_file_name)
    registers = get_registers(data_file_name)
    
    reg_file_obj = open(reg_file_name, "w")
    write_all(reg_file_obj, constants, registers)
    
    
    
    reg_file_obj.close()
    return 0;
    
    
    
    

if __name__ == "__main__":
    ret = main()
    if ret == 0:
        print("register file successfully generated")
    else:
        print("register file not generated successfully")
        print("return code: "+str(ret))