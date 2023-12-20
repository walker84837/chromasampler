#include <filesystem>
#include <iostream>
#include <sstream>
#include <iomanip>
#include <opencv4/opencv2/opencv.hpp>
#include <string>
#include "../include/cxxopts.hpp"
#include "wrappers.hpp"

namespace fs = std::filesystem;

using std::string;
using std::endl;
using std::cout;
using std::cerr;

string rgb_to_hex(int r, int g, int b)
{
	std::stringstream stream;
	stream << "#" << std::hex << std::setw(2) << std::setfill('0') << r
		<< std::setw(2) << g << std::setw(2) << b;
	return stream.str();
}

int main(int argc, char **argv)
{
	constexpr int DEFAULT_SHADES = 10;
	string DEFAULT_NUM_SHADES = std::to_string(DEFAULT_SHADES);

	cxxopts::Options options("ChromaSampler", "Finds the average color of an image.");
	options.add_options()("h,help", "Show help")(
			"i,image", "Image path", cxxopts::value<string>())(
			"n,shades", "Number of shades",
			cxxopts::value<int>()->default_value(DEFAULT_NUM_SHADES));

	auto result = options.parse(argc, argv);

	if (result.count("help")) {
		cout << options.help() << endl;
		return 0;
	}

	if (!result.count("image")) {
		cerr << "ERROR: Please provide an image path!" << endl;
		return 1;
	}

	int num_shades = result["shades"].as<int>();
	fs::path image_path(result["image"].as<string>());

	if (!fs::exists(image_path)) {
		cerr << "ERROR: Image not found!" << endl;
		return 1;
	}

	cv::Mat image = cv::imread(image_path.string());

	if (image.empty()) {
		cerr << "ERROR: Could not open or read the image!" << endl;
		return 1;
	}

	cv::Scalar avg_color = cv::mean(image);

	int r = static_cast<int>(avg_color[2]);
	int g = static_cast<int>(avg_color[1]);
	int b = static_cast<int>(avg_color[0]);

	double shades = static_cast<double>(num_shades);

	std::cout << "Average colors:" << std::endl;
	std::cout << "rgb(" << r << ", " << g << ", " << b << ")" << std::endl;
	std::cout << rgb_to_hex(r, g, b) << std::endl;

	for (int i = num_shades; i >= 0; --i) {
		int shade_r = static_cast<int>(r * (i / shades));
		int shade_g = static_cast<int>(g * (i / shades));
		int shade_b = static_cast<int>(b * (i / shades));

		int number_shades_iter = num_shades - i;

		std::cout << "Shade " << number_shades_iter << ": rgb(" << shade_r << ", " << shade_g << ", " << shade_b
			<< ")" << std::endl;

		std::cout << "Shade " << number_shades_iter << ": " << rgb_to_hex(shade_r, shade_g, shade_b) << std::endl;
	}

	return 0;
}
