# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/),
and this project adheres to [Semantic Versioning](https://semver.org/).

## \[Unreleased\]

## \[0.3.0\] - 2024-02-28

### Added

  - Add image file name extracting from absolute path
  - Add optional rgb output

### Changed

  - Change comments to linux kernel-style comments
  - Improve logging in rgb to hex converting
  - Improve makefiles

### Fixed

  - After failure in converting rgb to hex, the color is set to #000000

## \[0.2.0\] - 2024-02-13

### Added

  - Add a new logging framework with basic string formatting.

### Changed

  - Update the Makefile to automatically run `download_deps.sh` and build 
    the static libraries right before compiling.
  - Use a Bash script to download headers instead of providing them.
  - Replace `getopt` with `parg` for command-line argument parsing.

## \[0.1.0\] - 2024-01-04

### Added

  - Initial release of `chromasampler-c`.
