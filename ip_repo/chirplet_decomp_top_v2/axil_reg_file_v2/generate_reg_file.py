def strip_newline(input_string):
  ret_string = input_string
  if ret_string == "":
    return ""
  if ret_string[len(ret_string)-1] == "\r":
    ret_string = ret_string[0:-1]
  if ret_string == "":
    return ""
  if ret_string[len(ret_string)-1] == "\n":
    ret_string = ret_string[0:-1]
  if ret_string == "":
    return ""
  if ret_string[len(ret_string)-1] == "\r":
    ret_string = ret_string[0:-1]
  if ret_string == "":
    return ""
  return ret_string

def strip_whitespace(input_string):
  ret_string = input_string
  count = 0
  for i in range(len(ret_string)):
    if ret_string[i] != " ":
      break
    else:
      count += 1
  ret_string = ret_string[count:]
  count = 0
  for i in reversed(range(len(ret_string))):
    if ret_string[i] != " ":
      break
    else:
      count += 1
  return ret_string[0:len(ret_string)-count]

def add_spaces(input_string, num_spaces):
  ret_string = input_string
  for i in range(num_spaces):
    ret_string += " "
  return ret_string

def write_all(template_file_obj, reg_file_obj, constants, registers, sub_registers):
  for line in template_file_obj:
    if line[0] != "#":
      reg_file_obj.write(line)
    else:
      type = line[1:line.find(",")]
      num_spaces = int(line[line.find(",")+1:line.find("spaces")])
      if type == "constant data width":
        wr_line = ""
        wr_line = add_spaces(wr_line, num_spaces)
        wr_line += "constant C_REG_FILE_DATA_WIDTH : integer := %s;\n" % constants[0][1]
        reg_file_obj.write(wr_line)
      elif type == "constant address width":
        wr_line = ""
        wr_line = add_spaces(wr_line, num_spaces)
        wr_line += "constant C_REG_FILE_ADDR_WIDTH : integer := %s;\n" % constants[1][1]
        reg_file_obj.write(wr_line)
      elif type == "register names":
        for i in range(len(registers)):
          wr_line = ""
          wr_line = add_spaces(wr_line, num_spaces)
          wr_line += "%s_REG : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);\n" % registers[i][0]
          reg_file_obj.write(wr_line)
      elif type == "register wr pulses":
        for i in range(len(registers)):
          wr_line = ""
          wr_line = add_spaces(wr_line, num_spaces)
          wr_line += "%s_REG_wr_pulse : std_logic;\n" % registers[i][0]
          reg_file_obj.write(wr_line)
      elif type == "register rd pulses":
        for i in range(len(registers)):
          wr_line = ""
          wr_line = add_spaces(wr_line, num_spaces)
          wr_line += "%s_REG_rd_pulse : std_logic;\n" % registers[i][0]
          reg_file_obj.write(wr_line)
      elif type == "register addresses":
        for i in range(len(registers)):
          wr_line = ""
          wr_line = add_spaces(wr_line, num_spaces)
          wr_line += "constant %s_addr : integer range 0 to 2**C_REG_FILE_ADDR_WIDTH-1 := %i;\n" % (registers[i][0], registers[i][2])
          reg_file_obj.write(wr_line)
      elif type == "wr pulse eq zero":
        for i in range(len(registers)):
          wr_line = ""
          wr_line = add_spaces(wr_line, num_spaces)
          wr_line += "registers.%s_REG_wr_pulse <= '0';\n" % registers[i][0]
          reg_file_obj.write(wr_line)
      elif type == "rd pulse eq zero":
        for i in range(len(registers)):
          wr_line = ""
          wr_line = add_spaces(wr_line, num_spaces)
          wr_line += "registers.%s_REG_rd_pulse <= '0';\n" % registers[i][0]
          reg_file_obj.write(wr_line)
      elif type == "rd pulse eq one":
        for i in range(len(registers)):
          wr_line = ""
          wr_line = add_spaces(wr_line, num_spaces)
          wr_line += "when std_logic_vector(to_unsigned(%s_addr, C_REG_FILE_ADDR_WIDTH)) =>\n" % registers[i][0]
          wr_line = add_spaces(wr_line, num_spaces)
          wr_line += "  registers.%s_REG_rd_pulse <= '1';\n" % registers[i][0]
          reg_file_obj.write(wr_line)
      elif type == "awaddr case":
        for i in range(len(registers)):
          if registers[i][1] == "RW":
            wr_line = ""
            wr_line = add_spaces(wr_line, num_spaces)
            wr_line += "when std_logic_vector(to_unsigned(%s_addr, C_REG_FILE_ADDR_WIDTH)) =>\n" % registers[i][0]
            wr_line = add_spaces(wr_line, num_spaces)
            wr_line += "  registers.%s_REG <= s_axi_wdata;\n" % registers[i][0]
            wr_line = add_spaces(wr_line, num_spaces)
            wr_line += "  registers.%s_REG_wr_pulse <= '1';\n" % registers[i][0]
            reg_file_obj.write(wr_line)
      elif type == "araddr case":
        for i in range(len(registers)):
          wr_line = ""
          wr_line = add_spaces(wr_line, num_spaces)
          wr_line += "when std_logic_vector(to_unsigned(%s_addr, C_REG_FILE_ADDR_WIDTH)) =>\n" % registers[i][0]
          wr_line = add_spaces(wr_line, num_spaces)
          wr_line += "  s_axi_rdata <= registers.%s_REG;\n" % registers[i][0]
          reg_file_obj.write(wr_line)
      elif type == "reset regs":
        for i in range(len(registers)):
          if registers[i][1] == "RW":
            wr_line = ""
            wr_line = add_spaces(wr_line, num_spaces)
            if constants[0][1] == 32:
              wr_line += "registers.%s_REG <= x\"%08X\";\n" % (registers[i][0], registers[i][3])
            if constants[0][1] == 24:
              wr_line += "registers.%s_REG <= x\"%06X\";\n" % (registers[i][0], registers[i][3])
            if constants[0][1] == 16:
              wr_line += "registers.%s_REG <= x\"%04X\";\n" % (registers[i][0], registers[i][3])
            if constants[0][1] == 8:
              wr_line += "registers.%s_REG <= x\"%02X\";\n" % (registers[i][0], registers[i][3])
            reg_file_obj.write(wr_line)
      elif type == "reset read only regs":
        for i in range(len(registers)):
          if registers[i][1] == "RO":
            wr_line = ""
            wr_line = add_spaces(wr_line, num_spaces)
            if constants[0][1] == 32:
              wr_line += "registers.%s_REG <= x\"%08X\";\n" % (registers[i][0], registers[i][3])
            if constants[0][1] == 24:
              wr_line += "registers.%s_REG <= x\"%06X\";\n" % (registers[i][0], registers[i][3])
            if constants[0][1] == 16:
              wr_line += "registers.%s_REG <= x\"%04X\";\n" % (registers[i][0], registers[i][3])
            if constants[0][1] == 8:
              wr_line += "registers.%s_REG <= x\"%02X\";\n" % (registers[i][0], registers[i][3])
            reg_file_obj.write(wr_line)
      elif type == "read only regs":
        for i in range(len(registers)):
          if registers[i][1] == "RO":
            for j in range(len(sub_registers[i][1])):
              wr_line = ""
              wr_line = add_spaces(wr_line, num_spaces)
              wr_line += "if s_%s_%s_v = '1' then \n" % \
                (sub_registers[i][0], sub_registers[i][1][j])
              wr_line = add_spaces(wr_line, num_spaces)
              wr_line += "  registers.%s_REG(%s) <= s_%s_%s;\n" % \
                (sub_registers[i][0], sub_registers[i][2][j], sub_registers[i][0], sub_registers[i][1][j])
              wr_line = add_spaces(wr_line, num_spaces)
              wr_line += "end if;\n"
              reg_file_obj.write(wr_line)

      elif type == "read only regs port":
        for i in range(len(registers)):
          if registers[i][1] == "RO":
            for j in range(len(sub_registers[i][1])):
              wr_line = ""
              wr_line = add_spaces(wr_line, num_spaces)
              wr_line += "s_%s_%s : in std_logic_vector(%s);\n" % \
                (sub_registers[i][0], sub_registers[i][1][j], sub_registers[i][3][j])
              wr_line = add_spaces(wr_line, num_spaces)
              wr_line += "s_%s_%s_v : in std_logic;\n\n" % \
                (sub_registers[i][0], sub_registers[i][1][j])
              reg_file_obj.write(wr_line)

      elif type == "subreg type":
        for i in range(len(registers)):
          if registers[i][1] == "RW":
            wr_line = "  type %s_subreg_t is record\n" % sub_registers[i][0]
            for j in range(len(sub_registers[i][1])):
              wr_line = add_spaces(wr_line, num_spaces)
              wr_line += "%s : std_logic_vector(%s);\n" % (sub_registers[i][1][j], sub_registers[i][3][j])
            wr_line += "  end record;\n\n"
            reg_file_obj.write(wr_line)

      elif type == "subreg declare":
        for i in range(len(registers)):
          if registers[i][1] == "RW":
            wr_line = ""
            wr_line = add_spaces(wr_line, num_spaces)
            wr_line += "%s : %s_subreg_t;\n" % (sub_registers[i][0], sub_registers[i][0])
            reg_file_obj.write(wr_line)

      elif type == "subreg assign":
        for i in range(len(registers)):
          if registers[i][1] == "RW":
            for j in range(len(sub_registers[i][1])):
              wr_line = ""
              wr_line = add_spaces(wr_line, num_spaces)
              wr_line += "registers.%s.%s <= registers.%s_REG(%s);\n" % \
                (sub_registers[i][0], sub_registers[i][1][j], sub_registers[i][0], sub_registers[i][2][j])
              reg_file_obj.write(wr_line)

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

def count_major_regs(data_file_name):
  data_file_obj = open(data_file_name, "r")
  reg_count = 0
  subreg_process = False
  for line in data_file_obj:
    line = strip_whitespace(strip_newline(line))
    if line == "":
      pass
    elif line[0] == "#":
      pass
    elif line[0] == "[":
      pass
    elif line[0] == "{":
      subreg_process = True
    elif line[0] == "}":
      subreg_process = False
    elif subreg_process == False:
      if line.find("{") != -1:
        subreg_process = True
      reg_count += 1
  data_file_obj.close()
  return reg_count

def get_registers(data_file_name):
  reg_count = count_major_regs(data_file_name)

  data_file_obj = open(data_file_name, "r")

  registers = [[None, None, None, None] for i in range(reg_count)] # [name, type, address, reset val]
  sub_registers = [[None, None, None, None] for i in range(reg_count)] # [major_reg_name, subreg_name, range, range_less]

  reg_count = 0
  current_reg_name = 0
  subreg_process = False
  for line in data_file_obj:
    line = strip_whitespace(strip_newline(line))
    if line == "":
      pass
    elif line[0] == "#":
      pass
    elif line[0] == "[":
      pass
    elif line == "{":
      subreg_process = True
      subreg_name = []
      subreg_range = []
      subreg_range_less = []
    elif line == "}":
      subreg_process = False
      sub_registers[reg_count-1] = [current_reg_name, subreg_name, subreg_range, subreg_range_less]

    elif subreg_process == True:
      subreg_args = line.split()
      subreg_name.append(subreg_args[0])
      range_tmp = strip_whitespace(subreg_args[1][1:-1])
      range_tmp = range_tmp.replace(":", " downto ")
      subreg_range.append(range_tmp)
      range_max = int(range_tmp.split()[0])
      range_min = int(range_tmp.split()[2])
      subreg_range_less.append("%i downto %i" % (range_max-range_min, 0))

    else:
      if line.find("{") != -1:
        subreg_process = True
        subreg_name = []
        subreg_range = []
        subreg_range_less = []
      reg_args = line.split()
      name = reg_args[0]
      type = reg_args[1]
      address = reg_args[2]
      reset_val = reg_args[3]
      current_reg_name = name
      if address[0:2] == "0x":
        address = int(address[2:len(address)], 16)
      else:
        address = int(address)
      if reset_val[0:2] == "0x":
        reset_val = int(reset_val[2:len(reset_val)], 16)
      else:
        reset_val = int(reset_val)
      registers[reg_count] = [name, type, address, reset_val]
      reg_count += 1

  data_file_obj.close()
  return [registers, sub_registers]

def main():
  print("Starting Register File HDL Generator")
  template_file_name = "axil_reg_file.template"
  reg_file_name = "axil_reg_file.vhd"
  data_file_name = "registers.dat"
  constants = get_constants(data_file_name)
  [registers, sub_registers] = get_registers(data_file_name)

  print("")
  print(constants)
  print(registers)

  #return 1

  template_file_obj = open(template_file_name, "r")
  reg_file_obj = open(reg_file_name, "w")
  write_all(template_file_obj, reg_file_obj, constants, registers, sub_registers)

  template_file_obj.close()
  reg_file_obj.close()
  return 0

if __name__ == "__main__":
  ret = main()
  if ret == 0:
    print("register file successfully generated")
  else:
    print("register file not generated successfully")
    print("return code: "+str(ret))
