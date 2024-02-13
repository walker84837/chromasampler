CC = gcc
CFLAGS = -Ofast -std=gnu11 -static -Wextra -Wall
LDFLAGS = -lm -L./src/lib -lparg -llogging
SRC_DIR = src
BUILD_DIR = build

# List all source files
SRCS = $(wildcard $(SRC_DIR)/*.c)

# Generate a list of object files in the build directory
OBJS = $(patsubst $(SRC_DIR)/%.c,$(BUILD_DIR)/%.o,$(SRCS))

# The final executable
TARGET = chromasampler

.PHONY: all clean deps

all: deps $(TARGET)

# Rule to run the script in src/include
deps:
	cd $(SRC_DIR)/include && ./download_deps.sh
	cd $(SRC_DIR)/logging && make -f Makefile
# deps-libparg:
# Rule to clone the parg library and build it
	cd $(SRC_DIR)/lib && git clone https://github.com/jibsen/parg.git
	cd $(SRC_DIR)/lib/parg && cmake . && cmake --build . && mv libparg.a .. && cd .. && rm -rf parg


$(TARGET): $(OBJS)
	$(CC) $(CFLAGS) -o $@ $^ $(LDFLAGS)

# Rule to build object files from source files
$(BUILD_DIR)/%.o: $(SRC_DIR)/%.c | $(BUILD_DIR)
	$(CC) $(CFLAGS) -c -o $@ $<

$(BUILD_DIR):
	mkdir -p $@

clean:
	rm -rf $(BUILD_DIR) $(TARGET) $(SRC_DIR)/lib/libparg.a $(SRC_DIR)/lib/liblogging.a $(SRC_DIR)/include/*.c $(SRC_DIR)/include/*.h
