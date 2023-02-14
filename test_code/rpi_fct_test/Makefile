SRC_DIR   := ./
#SRC_DIR   := ./src
OBJ_DIR   := ./
#OBJ_DIR   := ./obj
#EXE_DIR   := ./bin
EXE_DIR   := ./
SRC_FILES := $(wildcard $(SRC_DIR)/*.c)
OBJ_FILES := $(patsubst $(SRC_DIR)/%.c,$(OBJ_DIR)/%.o,$(SRC_FILES))
LDFLAGS   := -lwiringPi
CPPFLAGS  := -lwiringPi
CXXFLAGS  := 

$(EXE_DIR)/main: $(OBJ_FILES)
	gcc $(LDFLAGS) -o $@ $^

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.c
	gcc $(CPPFLAGS) $(CXXFLAGS) -c -o $@ $<

clean:
	rm -f $(EXE_DIR)/main
	rm -f $(OBJ_DIR)/*.o
