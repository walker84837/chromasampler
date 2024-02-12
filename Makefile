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

.PHONY: all clean

all: $(TARGET)

$(TARGET): $(OBJS)
	$(CC) $(CFLAGS) -o $@ $^ $(LDFLAGS)

# Rule to build object files from source files
$(BUILD_DIR)/%.o: $(SRC_DIR)/%.c | $(BUILD_DIR)
	$(CC) $(CFLAGS) -c -o $@ $<

$(BUILD_DIR):
	mkdir -p $@

clean:
	rm -rf $(BUILD_DIR) $(TARGET)
