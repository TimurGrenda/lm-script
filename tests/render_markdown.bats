#!/usr/bin/env bats
# Pipeline test for render_markdown() — verifies it pipes through bat correctly.

setup() {
  load 'test_helper/common_setup'
  _common_setup
  _source_lm

  # Set up a log file so we can verify bat was called with correct args
  export MOCK_BAT_LOG
  MOCK_BAT_LOG="$(mktemp)"
}

teardown() {
  rm -f "$MOCK_BAT_LOG"
}

@test "render_markdown pipes input through bat with correct arguments" {
  # Feed some markdown through render_markdown directly (no subshell needed)
  run render_markdown <<< "# Hello"

  assert_success
  assert_output "# Hello"

  # Verify bat was called with the expected arguments
  run cat "$MOCK_BAT_LOG"
  assert_output --partial "--style=plain"
  assert_output --partial "--paging=never"
  assert_output --partial "--language"
  assert_output --partial "md"
}
