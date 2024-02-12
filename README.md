# chromasampler-c

![Licensed under GNU
GPLv3](https://img.shields.io/badge/license-GNU%20GPLv3-blue.svg)

`chromasampler-c` efficiently calculates the average colour of an image.

It can extract dominant colour information from images in various formats.
This makes it useful for tasks such as image analysis, colour-based sorting,
or generating colour palettes.

## Table of Contents

1.  [Installation](#installation)
2.  [Usage](#usage)
3.  [Roadmap](#roadmap)
4.  [Contributing](#contributing)
5.  [License](#license)

## Installation

To use `chromasampler-c`, follow these steps:

1.  Clone the repository:
    ``` console
    git clone https://github.com/walker84837/chromasampler-c.git
    ```
2.  Navigate to the project directory: `cd chromasampler-c`
3.  Go to `src/include` and run the `download_deps.sh` script:
    ```console
    ./download_deps.sh
    ```
3.  Compile the program:
    ``` console
    make
    ```
## Usage

The program is executed from the command line, allowing users to specify the
input image file using the `-f` option. Here's an example:

``` console
./chromasampler -f path/to/your/image.png
```

  - `-f`: Specify the filename of the input image.
  - `-h`: Display the help message with usage information.

## Roadmap

There are no specific plans for future releases at the moment. Feel free to
contribute ideas or enhancements through the issue tracker.

## Contributing

Contributions are welcome! If you'd like to contribute, please

  - Follow the [Linux kernel coding style](https://docs.kernel.org/process/coding-style.html).
  - Follow the [code of conduct](CODE_OF_CONDUCT.md).
  - If you're proposing new changes, open an issue.

If you encounter any issues or have questions, feel free to open an issue on the
[issue tracker](https://github.com/walker84837/chromasampler-c/issues).

## License

This project is licensed under the [GNU GPLv3](LICENSE.md).

Feel free to use, contribute, or provide feedback. If you are interested in
becoming a maintainer, please get in touch.

**NOTE**: Development may slow down or stop in the future.
