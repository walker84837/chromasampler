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
#include "include/parg.h"
#include "logging/logging.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <stdint.h>
#include <stdbool.h>

typedef struct {
	uint64_t red;
	uint64_t green;
	uint64_t blue;
} rgb_color_t;

char *basename(const char *path)
{
	char *dir = (char *)path;

	/*
	 * Strip all trailing forward-slashes '/' from the end of the string.
	 */
	size_t len = strlen(dir);
	while (len > 0 && dir[len - 1] == '/') {
		dir[--len] = '\0';
	}

	char *last_slash = strrchr(dir, '/');

	/*
	 * If a slash is found, return everything after it, otherwise, return
	 * the original string.
	 */
	if (last_slash != NULL) {
		dir = last_slash + 1;
	}

	return dir;
}

const char *get_file_extension(const char *file_name)
{
	/*
	 * Find the last occurrence of '.'
	 */
	const char *dot = strrchr(file_name, '.');

	if (dot == NULL || dot == file_name) {
		/*
		 * No dot found or dot is the first character (no extension).
		 */
		return NULL;
	} else {
		/*
		 * Return the extension (substring after the last dot).
		 */
		return dot + 1;
	}
}

void rgb_to_hex(char **hex_color, uint8_t red, uint8_t green, uint8_t blue)
{
	/*
	 * Allocate memory for the hex color string (including the null terminator).
	 */
	*hex_color = (char *)malloc(8);

	if (!(*hex_color)) {
		fatal_error("Allocating memory for hex color failed.");
		exit(EXIT_FAILURE);
	}

	if (snprintf(*hex_color, 8, "#%02x%02x%02x", red, green, blue) != 7) {
		error("Converting RGB-formatted color to hexadecimal format failed.");
		warning("Something wrong happened during formatting. Setting the color to #000000");
		*hex_color = "#000000";
	}
}

bool is_null_or_empty(const char *str)
{
	return str == NULL || *str == '\0';
}

static rgb_color_t calculate_average_rgb(const char *filename)
{
	const char *extension = get_file_extension(filename);

	if (is_null_or_empty(extension)) {
		warning("The image doesn't have a file extension or is `NULL`. Expect errors to happen.");
	}

	int width, height, channels;

	/*
	 * Load the image with `desired_channels` set to 0 to get the actual
	 * channels in the image.
	 */
	uint8_t *image = stbi_load(filename, &width, &height, &channels, 0);
	char *filename_base = basename(filename);

	if (!image) {
		fatal_error("Failed to load image '%s'", filename_base);
		exit(EXIT_FAILURE);
	}

	info("Loaded image '%s' (%dx%d).", filename_base, width, height);

	rgb_color_t average_rgb = {0, 0, 0};

	uint64_t total_pixels = width * height;

	/*
	 * If the alpha channel is present, ignore it, because taking it into
	 * consideration leads to counting the colors incorrectly, leading to
	 * an inaccurate color average.
	 */
	if (channels == 4) {
		warning("4 channels found in '%s', forcing 3 channels.", filename_base);
		channels = 3;
	}

	/*
	 * We are using uint64_t just in case the image is of big resolution, 
	 * and the total pixels have more than 2^31 - 1.
	 */
	for (uint64_t i = 0; i < total_pixels; ++i) {
		/*
		 * Calculate the correct index based on the actual number of channels 
		 */
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
	const char *filename = NULL;
	struct parg_state ps;
	parg_init(&ps);

	const struct parg_option longopts[] = {
		{"file", PARG_REQARG, NULL, 'f'},
		{"verbose", PARG_NOARG, NULL, 'v'},
		{"help", PARG_NOARG, NULL, 'h'},
		{0, 0, 0, 0}
	};

	bool rgb = false;
	int opt;
	while ((opt = parg_getopt_long(&ps, argc, argv, "rf:h", longopts, NULL)) != -1) {
		switch (opt) {
			case 'f':
				filename = ps.optarg;
				break;
			case 'r':
				rgb = true;
				break;
			case 'h':
				printf("%s: find the average color in an image\n", argv[0]);
				printf("Usage: %s [-f filename]\n", argv[0]);
				puts("  -f  file name of the image");
				puts("  -h  open this help");
				exit(EXIT_SUCCESS);
			default:
				fprintf(stderr, "unknown argument: run again with -h for help.\n");
				exit(EXIT_FAILURE);
		}
	}

	if (filename == NULL) {
		fatal_error("No image was provided");
		exit(EXIT_FAILURE);
	}

	rgb_color_t average_rgb = calculate_average_rgb(filename);
	char *hex_color = NULL;

	rgb_to_hex(
		&hex_color,
		average_rgb.red,
		average_rgb.green,
		average_rgb.blue
	);

	if (rgb) {
		printf("rgb(%lu, %lu, %lu)\n",
			average_rgb.red,
			average_rgb.green,
			average_rgb.blue
		);
	}

	printf("%s\n", hex_color);

	free(hex_color);
	return 0;
}
