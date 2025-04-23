# chromasampler

[![Build with Zig](https://github.com/walker84837/chromasampler/actions/workflows/zig.yml/badge.svg)](https://github.com/walker84837/chromasampler/actions/workflows/zig.yml)
![Licensed under GNU GPLv3](https://img.shields.io/badge/license-GNU%20GPLv3-blue.svg)

`chromasampler` calculates the average colour of an image.

It can extract the average colour from images in a variety of formats. This
makes it useful for tasks such as image analysis, colour sorting or colour
palette generation.

## Table of Contents

1.  [Installation](#installation)
2.  [Usage](#usage)
3.  [Roadmap](#roadmap)
4.  [Contributing](#contributing)
5.  [License](#license)

## Installation

To use `chromasampler`, follow these steps:

1.  Clone the repository:

    ``` console
    git clone https://github.com/walker84837/chromasampler.git
    ```

2.  Navigate to the project directory: `cd chromasampler`

3.  Compile the program:

    ``` console
    zig build
    ```

## Usage

The program is executed from the command line, allowing users to specify the
input image file using the `-f` option. Here's an example:

``` console
./chromasampler -f path/to/your/image
```

  - `-f`: Specify the filename of the input image.
  - `-r`: Output the average color in RGB format.
  - `-h`: Display the help message with usage information.
  - The `.img` in image.img refers to one of these formats, which are the 
    only ones supported as of now.

The supported image formats are:

  - **JPEG**: baseline & progressive (12 bpc/arithmetic not supported, same as
    stock IJG lib)
  - **PNG**: 1/2/4/8/16-bit-per-channel
  - **TGA**
  - **BMP**: non-1bpp, non-RLE
  - **PSD**: composited view only, no extra channels, 8/16 bit-per-channel
  - **GIF**: \*comp always reports as 4-channel
  - **HDR**: radiance rgbE format
  - **PIC**: Softimage PIC
  - **PNM**: PPM and PGM binary only

## Roadmap

  - [ ] Configuration with [INI](https://github.com/ziglibs/ini).

## Contributing

Contributions are welcome! If you'd like to contribute, please

  - Follow the [code of conduct](CODE_OF_CONDUCT.md).
  - If you're proposing new changes, open an issue.

If you encounter any issues or have questions, feel free to open an issue on the
[issue tracker](https://github.com/walker84837/chromasampler/issues).

## License

This project is licensed under the [GNU GPLv3](LICENSE.md).

**NOTE**: Development *may* slow down or stop in the future.
