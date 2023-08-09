#include <iostream>
#include <string>
#include <cstring>
#include <filesystem>
#include <opencv4/opencv2/core/mat.hpp>
#include <opencv4/opencv2/core.hpp>
#include <opencv4/opencv2/core/utility.hpp>
#include <opencv4/opencv2/opencv.hpp>
#include <opencv4/opencv2/opencv_modules.hpp>

namespace fs = std::filesystem;

std::string rgbToHex(int r, int g, int b)
{
	std::stringstream stream;
	stream << "#" << std::hex << std::setw(2) << std::setfill('0') << r << std::setw(2) << g << std::setw(2) << b;
	return stream.str();
}

int main(int argc, char *argv[])
{
	if (argv[1] == nullptr)
	{
		throw std::invalid_argument("Please provide an argument.");
	}

	else if (std::strcmp(argv[1], "--help") == 0 || std::strcmp(argv[1], "-h") == 0 || std::strcmp(argv[1], "-help") == 0)
	{
		std::cout << argv[0] << " <image path>" << '\n';
		std::cout << "Finds the average color of an image, given the path." << '\n';
		return 0;
	}

	fs::path image_path(argv[1]);

	if (!fs::exists(image_path))
	{
		throw std::invalid_argument("Image not found.");
	}

	cv::Mat image = cv::imread(std::string(image_path));

	if (image.empty())
	{
		throw std::runtime_error("Error: Could not open or read the image.");
	}

	cv::Scalar avgColor = cv::mean(image);

	int r = static_cast<int>(avgColor[2]);
	int g = static_cast<int>(avgColor[1]);
	int b = static_cast<int>(avgColor[0]);

	std::cout << "Average Color (RGB): rgb(" << r << ", " << g << ", " << b << ")" << '\n';
	std::cout << "Average Color (Hex): " << rgbToHex(r, g, b) << '\n';

	const int numShades = 10;
	for (int i = numShades; i >= 0; --i)
	{
		int shadeR = static_cast<int>(r * (i / static_cast<double>(numShades)));
		int shadeG = static_cast<int>(g * (i / static_cast<double>(numShades)));
		int shadeB = static_cast<int>(b * (i / static_cast<double>(numShades)));

		std::cout << "Shade " << numShades - i << " (RGB): " << shadeR << ", " << shadeG << ", " << shadeB << '\n';
		std::cout << "Shade " << numShades - i << " (Hex): " << rgbToHex(shadeR, shadeG, shadeB) << '\n';
	}

	return 0;
}