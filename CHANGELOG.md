# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/).

## [Unreleased]

### Added

- Interactive readline mode: when `:` is the last argument (nothing after it), `INTERACTIVE_PROMPT` is set to `true`.
- `get_readline_input()` function: reads a single-line prompt via readline, bypassing shell metacharacter issues.
- `main()` now uses `get_readline_input()` when `INTERACTIVE_PROMPT` is true, completing the interactive readline workflow.
- Integration test for interactive readline mode (bare `:` with `LM_TTY` feeding input).

### Changed

- Replaced `--` prompt separator with `:` in argument parsing. `:` is a shell-safe single character, and bare `:` (with no prompt text) triggers interactive readline mode where the prompt bypasses bash parsing entirely.
