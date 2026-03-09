# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/).

## [Unreleased]

### Changed

- Replaced `--` prompt separator with `:` in argument parsing. `:` is a shell-safe single character, and bare `:` (with no prompt text) triggers interactive readline mode where the prompt bypasses bash parsing entirely.

### Added

- Interactive readline mode: when `:` is the last argument (nothing after it), `INTERACTIVE_PROMPT` is set to `true`.
