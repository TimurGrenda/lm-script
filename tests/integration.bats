#!/usr/bin/env bats
# End-to-end integration tests with all mocks active.
# These tests run the lm script as a subprocess and verify the full pipeline.

setup() {
  load 'test_helper/common_setup'
  _common_setup

  export MOCK_LLM_LOG MOCK_BAT_LOG
  MOCK_LLM_LOG="$(mktemp)"
  MOCK_BAT_LOG="$(mktemp)"
  export MOCK_LLM_RESPONSE="mock llm output"

  # Use `true` as EDITOR so that get_input returns empty when called
  # from the conversation loop (the editor leaves the file empty,
  # get_input detects no content, the loop breaks).
  export EDITOR="true"
}

teardown() {
  rm -f "$MOCK_LLM_LOG" "$MOCK_BAT_LOG"
}

@test "inline prompt passed to llm with default template" {
  run "$LM_SCRIPT" -- "explain bash"

  assert_success

  # Verify llm was called with the default template and the prompt
  run cat "$MOCK_LLM_LOG"
  assert_output --partial "-t general"
  assert_output --partial "explain bash"
}

@test "custom template overrides default" {
  run "$LM_SCRIPT" -t code -- "explain bash"

  assert_success

  # Verify llm was called with -t code, not -t general
  run cat "$MOCK_LLM_LOG"
  assert_output --partial "-t code"
  refute_output --partial "-t general"
}
