SRC_DIR   := ./src
#OBJ_DIR   := ./obj
EXE_DIR   := ./bin
#SRC_FILES := $(wildcard $(SRC_DIR)/*.c)
#OBJ_FILES := $(patsubst $(SRC_DIR)/%.c,$(OBJ_DIR)/%.o,$(SRC_FILES))
LDFLAGS   := 
CPPFLAGS  := 
CXXFLAGS  := 

all: chirplet_decomp

chirplet_decomp:
	gcc -o $(EXE_DIR)/chirplet_decomp $(SRC_DIR)/chirplet_decomp.c

clean:
	rm -f $(EXE_DIR)/*.exe
	rm -f $(OBJ_DIR)/*.o
