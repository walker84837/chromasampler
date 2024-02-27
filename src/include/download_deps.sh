#!/bin/bash

deps=(
	"https://raw.githubusercontent.com/nothings/stb/master/stb_image.h"
	"https://raw.githubusercontent.com/jibsen/parg/master/parg.h"
	"https://raw.githubusercontent.com/jibsen/parg/master/parg.c"
	"https://raw.githubusercontent.com/clibs/inih/master/ini.c"
	"https://raw.githubusercontent.com/clibs/inih/master/ini.h"
)

# Usage: basename "path" ["suffix"]
basename() {
    # Code taken from:
    # https://github.com/dylanaraps/pure-sh-bible
    # This function's code is licensed under MIT License.
    dir=${1%"${1##*[!/]}"}

    dir=${dir##*/}

    dir=${dir%"$2"}

    printf '%s\n' "${dir:-/}"
}

download_dependency() {
	url="$1"
	filename="$(basename "$url")"

	# Check if the file already exists
	if [ -f "$filename" ]; then
		echo "Dependency $filename already exists. Skipping download."
	else
		# Download the file
		echo "Downloading $filename..."
		if command -v curl >/dev/null 2>&1; then
			curl -O -J -L "$url"
		elif command -v wget >/dev/null 2>&1; then
			wget "$url"
		else
			echo "Error: Neither curl nor wget found. Please install one of them."
			exit 1
		fi

		# Check if the download was successful
		if [ $? -eq 0 ]; then
			echo "Download successful: $filename"
		else
			echo "Error: Failed to download $filename"
			exit 1
		fi
	fi
}

# Download each dependency
for dep in "${deps[@]}"; do
	download_dependency "$dep"
done

echo "Dependencies completed successfully."
exit 0
