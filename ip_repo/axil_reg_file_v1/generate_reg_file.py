def write_all(template_file_obj, reg_file_obj, constants, registers):
  for line in template_file_obj:
    if line[0] != "#":
      reg_file_obj.write(line)
    else:
      type = line[1:line.find(",")]
      num_spaces = int(line[line.find(",")+1:line.find("spaces")])
      if type == "constant data width":
        wr_line = ""
        for j in range(num_spaces):
          wr_line += " "
        wr_line += "constant C_REG_FILE_DATA_WIDTH : integer := %s;\n" % constants[0][1]
        reg_file_obj.write(wr_line)
      elif type == "constant address width":
        wr_line = ""
        for j in range(num_spaces):
          wr_line += " "
        wr_line += "constant C_REG_FILE_ADDR_WIDTH : integer := %s;\n" % constants[1][1]
        reg_file_obj.write(wr_line)
      elif type == "register names":
        for i in range(len(registers)):
          wr_line = ""
          for j in range(num_spaces):
            wr_line += " "
          wr_line += "%s : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);\n" % registers[i][0]
          reg_file_obj.write(wr_line)
      elif type == "register wr pulses":
        for i in range(len(registers)):
          wr_line = ""
          for j in range(num_spaces):
            wr_line += " "
          wr_line += "%s_wr_pulse : std_logic;\n" % registers[i][0]
          reg_file_obj.write(wr_line)
      elif type == "register rd pulses":
        for i in range(len(registers)):
          wr_line = ""
          for j in range(num_spaces):
            wr_line += " "
          wr_line += "%s_rd_pulse : std_logic;\n" % registers[i][0]
          reg_file_obj.write(wr_line)
      elif type == "register addresses":
        for i in range(len(registers)):
          wr_line = ""
          for j in range(num_spaces):
            wr_line += " "
          wr_line += "constant %s_addr : integer range 0 to 2**C_REG_FILE_ADDR_WIDTH-1 := %i;\n" % (registers[i][0], registers[i][2])
          reg_file_obj.write(wr_line)
      elif type == "wr pulse eq zero":
        for i in range(len(registers)):
          wr_line = ""
          for j in range(num_spaces):
            wr_line += " "
          wr_line += "registers.%s_wr_pulse <= '0';\n" % registers[i][0]
          reg_file_obj.write(wr_line)
      elif type == "rd pulse eq zero":
        for i in range(len(registers)):
          wr_line = ""
          for j in range(num_spaces):
            wr_line += " "
          wr_line += "registers.%s_rd_pulse <= '0';\n" % registers[i][0]
          reg_file_obj.write(wr_line)
      elif type == "rd pulse eq one":
        for i in range(len(registers)):
          wr_line = ""

          for j in range(num_spaces):
            wr_line += " "
          wr_line += "when std_logic_vector(to_unsigned(%s_addr, C_REG_FILE_ADDR_WIDTH)) =>\n" % registers[i][0]

          for j in range(num_spaces):
            wr_line += " "
          wr_line += "  registers.%s_rd_pulse <= '1';\n" % registers[i][0]

          reg_file_obj.write(wr_line)
      elif type == "awaddr case":
        for i in range(len(registers)):
          if registers[i][1] == "RW":
            wr_line = ""

            for j in range(num_spaces):
              wr_line += " "
            wr_line += "when std_logic_vector(to_unsigned(%s_addr, C_REG_FILE_ADDR_WIDTH)) =>\n" % registers[i][0]

            for j in range(num_spaces):
              wr_line += " "
            wr_line += "  registers.%s <= s_axi_wdata;\n" % registers[i][0]

            for j in range(num_spaces):
              wr_line += " "
            wr_line += "  registers.%s_wr_pulse <= '1';\n" % registers[i][0]

            reg_file_obj.write(wr_line)
      elif type == "araddr case":
        for i in range(len(registers)):
          if registers[i][1] == "RW":
            wr_line = ""

            for j in range(num_spaces):
              wr_line += " "
            wr_line += "when std_logic_vector(to_unsigned(%s_addr, C_REG_FILE_ADDR_WIDTH)) =>\n" % registers[i][0]

            for j in range(num_spaces):
              wr_line += " "
            wr_line += "  s_axi_rdata <= registers.%s;\n" % registers[i][0]

            reg_file_obj.write(wr_line)
      elif type == "reset regs":
        for i in range(len(registers)):
          if registers[i][1] == "RW":
            wr_line = ""
            for j in range(num_spaces):
              wr_line += " "
            if constants[0][1] == 32:
              wr_line += "registers.%s <= x\"%08X\";\n" % (registers[i][0], registers[i][3])
            if constants[0][1] == 24:
              wr_line += "registers.%s <= x\"%06X\";\n" % (registers[i][0], registers[i][3])
            if constants[0][1] == 16:
              wr_line += "registers.%s <= x\"%04X\";\n" % (registers[i][0], registers[i][3])
            if constants[0][1] == 8:
              wr_line += "registers.%s <= x\"%02X\";\n" % (registers[i][0], registers[i][3])
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

def get_registers(data_file_name):
  data_file_obj = open(data_file_name, "r")
  reg_count = 0

  for line in data_file_obj:
    #if (line[0] != "#") and (line[0] != "[") and (line != "") and (line != "\n"):
    if line[0] == "#":
      pass
    elif line[0] == "[":
      pass
    elif line == "":
      pass
    elif line == "\n":
      pass
    elif line == "\n\r":
      pass
    elif line == "\r\n":
      pass
    else:
      reg_count += 1

  data_file_obj.seek(0)
  registers = [[None, None, None] for i in range(reg_count)]
  reg_count = 0
  for line in data_file_obj:
    if line[0] == "#":
      pass
    elif line[0] == "[":
      pass
    elif line == "":
      pass
    elif line == "\n":
      pass
    elif line == "\n\r":
      pass
    elif line == "\r\n":
      pass
    else:
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
  template_file_name = "axil_reg_file.template"
  reg_file_name = "axil_reg_file.vhd"
  data_file_name = "registers.dat"
  constants = get_constants(data_file_name)
  registers = get_registers(data_file_name)

  print(constants)
  print(registers)

  template_file_obj = open(template_file_name, "r")
  reg_file_obj = open(reg_file_name, "w")
  write_all(template_file_obj, reg_file_obj, constants, registers)

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
