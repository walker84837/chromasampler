CXX = g++
CXXFLAGS = -Ofast -std=gnu++17 -march=native -mtune=native
LIBS = -lopencv_core -lopencv_imgcodecs
INCLUDE = $(shell pkg-config --cflags --libs opencv4)
TARGET = chromasampler

SRC = src/main.cpp

$(TARGET): $(SRC)
	$(CXX) $(CXXFLAGS) -o $(TARGET) $(SRC) $(INCLUDE) $(LIBS)

clean:
	rm -f $(TARGET)

.PHONY: clean
