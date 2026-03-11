# Changelog

This file contains all the notable changes done to the Ballerina `googleapis.gmail` package through the releases.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

### Changed

## [4.2.0] - 2026-03-10

### Added

- Add `rawData` field (`byte[]`) to `Attachment` and `MessagePart` types to support binary content (e.g. PDF, images) that cannot be represented as UTF-8 strings

### Changed

- Update the Ballerina distribution version from `2201.11.0` to `2201.12.0`

### Fixed

- Fix binary attachment retrieval failing with `"array contains invalid UTF-8 byte value"` error when decoding non-UTF-8 content from the Gmail API

## [4.0.1] - 2024-02-13

### Changed

- Improve documentation

## [4.0.0] - 2023-12-01

### Added

- [Revamp Gmail connector](https://github.com/ballerina-platform/ballerina-library/issues/4874)
