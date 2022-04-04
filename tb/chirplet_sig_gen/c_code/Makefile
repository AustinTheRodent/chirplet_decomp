SRC_DIR   := ./src
#OBJ_DIR   := ./obj
EXE_DIR   := ./bin
#SRC_FILES := $(wildcard $(SRC_DIR)/*.c)
#OBJ_FILES := $(patsubst $(SRC_DIR)/%.c,$(OBJ_DIR)/%.o,$(SRC_FILES))
LDFLAGS   := 
CPPFLAGS  := 
CXXFLAGS  := 
#
#$(EXE_DIR)/txt_to_bin.exe: $(OBJ_FILES)
#	gcc $(LDFLAGS) -o $@ $^
#
#$(OBJ_DIR)/%.o: $(SRC_DIR)/%.c
#	gcc $(CPPFLAGS) $(CXXFLAGS) -c -o $@ $<
#
#clean:
#	rm -f $(EXE_DIR)/*.exe
#	rm -f $(OBJ_DIR)/*.o

all: txt_to_bin bin_to_txt filter calc_evm

txt_to_bin:
	gcc -o $(EXE_DIR)/txt_to_bin $(SRC_DIR)/txt_to_bin.c

bin_to_txt:
	gcc -o $(EXE_DIR)/bin_to_txt $(SRC_DIR)/bin_to_txt.c

filter:
	gcc -o $(EXE_DIR)/filter $(SRC_DIR)/filter.c

calc_evm:
	gcc -lm -o $(EXE_DIR)/calc_evm $(SRC_DIR)/calc_evm.c

clean:
	rm -f $(EXE_DIR)/*.exe
	rm -f $(OBJ_DIR)/*.o
