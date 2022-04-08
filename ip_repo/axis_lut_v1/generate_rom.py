import numpy as np

def main():
    ADDR_WIDTH = 8 # [bits]
    DWIDTH = 16
    SAMPLES_USED = 200 # samples
    output_file = open("rom.txt", "w")
    
    for i in range(2**ADDR_WIDTH):
        if i < SAMPLES_USED:
            dav_val = int(2**DWIDTH/2 + (2**DWIDTH/2-1)*np.sin(i*2*np.pi/SAMPLES_USED))
            output_file.write("tmp(%i) := std_logic_vector(to_unsigned(%i, %i));\n" % (i, dav_val, DWIDTH));
        else:
            output_file.write("tmp(%i) := std_logic_vector(to_unsigned(0, %i));\n" % (i, DWIDTH))
        #print(i)
    #tmp(addr_pos) := std_logic_vector(to_unsigned(addr_pos, DATA_WIDTH));
    output_file.close()

if __name__ == "__main__":
    main()

