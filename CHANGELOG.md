# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/),
and this project adheres to [Semantic Versioning](https://semver.org/).

## \[Unreleased\]

### Added

  - Update the Makefile to automatically run `download_deps.sh` and build 
    the static libraries right before compiling.

## \[0.2.0\] - 2024-02-13

### Added

  - Add a new logging framework with basic string formatting.

### Changed

  - Use a Bash script to download headers instead of providing them.
  - Replace `getopt` with `parg` for command-line argument parsing.

## \[0.1.0\] - 2024-01-04

### Added

  - Initial release of `chromasampler-c`.
