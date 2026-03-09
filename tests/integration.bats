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
  run "$LM_SCRIPT" : "explain bash"

  assert_success

  # Verify llm was called with the default template and the prompt
  run cat "$MOCK_LLM_LOG"
  assert_output --partial "-t general"
  assert_output --partial "explain bash"
}

@test "custom template overrides default" {
  run "$LM_SCRIPT" -t code : "explain bash"

  assert_success

  # Verify llm was called with -t code, not -t general
  run cat "$MOCK_LLM_LOG"
  assert_output --partial "-t code"
  refute_output --partial "-t general"
}

@test "interactive readline mode passes prompt to llm" {
  # Verify the full pipeline: bare ":" triggers get_readline_input(), which reads
  # from LM_TTY, and the resulting prompt reaches llm.
  #
  # With a file (not a real tty), read -e doesn't enable actual readline editing;
  # this test verifies the plumbing (argument reaches llm), not the interactive
  # experience.
  #
  # LM_TTY is used for both readline input and the conversation loop's read,
  # so re-opening the file re-reads stale content and the loop never exits on
  # its own. We run lm in the background, poll MOCK_LLM_LOG for the expected
  # prompt, then kill the process. This avoids GNU `timeout` (not on stock macOS).
  local prompt_file
  prompt_file="$(mktemp)"
  echo "explain bash" > "$prompt_file"
  export LM_TTY="$prompt_file"

  "$LM_SCRIPT" : &>/dev/null &
  local lm_pid=$!

  # Poll until llm is called with the prompt (up to 3 s)
  local i
  for i in $(seq 1 30); do
    grep --quiet "explain bash" "$MOCK_LLM_LOG" 2>/dev/null && break
    sleep 0.1
  done

  # Kill the lingering conversation loop
  kill "$lm_pid" 2>/dev/null
  wait "$lm_pid" 2>/dev/null || true

  run cat "$MOCK_LLM_LOG"
  assert_output --partial "explain bash"

  rm -f "$prompt_file"
}
