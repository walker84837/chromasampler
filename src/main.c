/*
 * chromasampler-c: Find the average color in an image.
 * Copyright (C) 2024 walker84837
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

#define STB_IMAGE_IMPLEMENTATION
#include "include/stb_image.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <stdint.h>

typedef struct {
	uint64_t red;
	uint64_t green;
	uint64_t blue;
} RGBColor;

static void rgb_to_hex(char **hex_color, unsigned char red, unsigned char green, unsigned char blue)
{
	// Allocate memory for the hex color string (including the null terminator)
	*hex_color = (char *)malloc(8);

	if (!(*hex_color)) {
		perror("Memory allocation error");
		exit(EXIT_FAILURE);
	}

	if (snprintf(*hex_color, 8, "#%02x%02x%02x", red, green, blue) != 7) {
		fprintf(stderr, "Error converting RGB to hex\n");
		exit(EXIT_FAILURE);

	}
}

static RGBColor calculate_average_rgb(const char *filename)
{
	int width, height, channels;

	// Load the image with desired_channels set to 0 to get the actual channels
	// in the image
	unsigned char *image = stbi_load(filename, &width, &height, &channels, 0);

	if (!image) {
		perror("Error loading image");
		exit(EXIT_FAILURE);
	}

	RGBColor average_rgb = {0, 0, 0};

	uint64_t total_pixels = width * height;

	// If the alpha channel is present, ignore it.
	if (channels == 4) {
		channels = 3;
	}

	for (uint64_t i = 0; i < total_pixels; ++i) {
		// Calculate the correct index based on the actual number of channels
		uint64_t index = i * channels;

		average_rgb.red += image[index];
		average_rgb.green += image[index + 1];
		average_rgb.blue += image[index + 2];
	}

	average_rgb.red /= total_pixels;
	average_rgb.green /= total_pixels;
	average_rgb.blue /= total_pixels;

	stbi_image_free(image);

	return average_rgb;
}

int main(int argc, char **argv)
{
	const char *filename = "image.png";

	int opt;
	while ((opt = getopt(argc, argv, "f:h")) != -1) {
		switch (opt) {
			case 'f':
				filename = optarg;
				break;
			case 'h':
				printf("%s: find the average color in an image\n", argv[0]);
				printf("Usage: %s [-f filename]\n", argv[0]);
				puts("  -f  file name of the image");
				puts("  -h  open this help");
				exit(EXIT_SUCCESS);
			default:
				fprintf(stderr, "Usage: %s [-f filename]\n", argv[0]);
				exit(EXIT_FAILURE);
		}
	}

	RGBColor average_rgb = calculate_average_rgb(filename);
	char *hex_color = NULL;
	rgb_to_hex(&hex_color, average_rgb.red, average_rgb.green, average_rgb.blue);
	printf("Average color (RGB): rgb(%lu, %lu, %lu)\n", average_rgb.red, average_rgb.green, average_rgb.blue);
	printf("Average colors (Hex): %s\n", hex_color);

	free(hex_color);

	return 0;
}
