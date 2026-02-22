#!/bin/bash
# Common setup for all bats test files.
# Loads bats helper libraries, prepends mock directory to PATH,
# and provides a helper to source the lm script safely.

_common_setup() {
  # Resolve paths relative to the test file location
  local test_dir
  test_dir="$(cd "$(dirname "$BATS_TEST_FILENAME")" && pwd)"
  PROJECT_ROOT="$(cd "$test_dir/.." && pwd)"

  # Load bats helper libraries
  load "$test_dir/test_helper/bats-libs/bats-support/load"
  load "$test_dir/test_helper/bats-libs/bats-assert/load"
  load "$test_dir/test_helper/bats-libs/bats-file/load"

  # Prepend mocks to PATH so they shadow real commands
  export PATH="$test_dir/test_helper/mocks:$PATH"

  # Redirect tty writes to /dev/null so tests don't hang or write to terminal
  export LM_TTY="/dev/null"

  # Point to the lm script
  export LM_SCRIPT="$PROJECT_ROOT/lm"
}

# Source the lm script without executing main().
# Only works after the refactoring adds the source guard.
_source_lm() {
  # shellcheck source=../../lm
  source "$LM_SCRIPT"
}
