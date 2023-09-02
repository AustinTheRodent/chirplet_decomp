SRC_DIR   := ./src
OBJ_DIR   := ./obj
EXE_DIR   := ./bin
SRC_FILES := $(wildcard $(SRC_DIR)/*.c)
OBJ_FILES := $(patsubst $(SRC_DIR)/%.c,$(OBJ_DIR)/%.o,$(SRC_FILES))
LDFLAGS   := 
CPPFLAGS  := 
CXXFLAGS  := 

$(EXE_DIR)/main.exe: $(OBJ_FILES)
	gcc $(LDFLAGS) -o $@ $^

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.c
	gcc $(CPPFLAGS) $(CXXFLAGS) -c -o $@ $<

clean:
	rm -f $(EXE_DIR)/*.exe
	rm -f $(OBJ_DIR)/*.o
