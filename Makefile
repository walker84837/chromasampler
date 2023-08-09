CXX = g++
CXXFLAGS = -O3 -std=c++17
LIBS = -lopencv_core -lopencv_imgcodecs
INCLUDE = -I/usr/include/opencv4
TARGET = ChromaSampler.app

SRC = main.cpp

$(TARGET): $(SRC)
	$(CXX) $(CXXFLAGS) -o $(TARGET) $(SRC) $(INCLUDE) $(LIBS)

clean:
	rm -f $(TARGET)

.PHONY: clean
