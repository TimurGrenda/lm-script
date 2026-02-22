#!/usr/bin/env bats
# Tests for early-exit routes: --history-view, --history-continue.
# These test the case statement in main() that handles special arguments.

setup() {
  load 'test_helper/common_setup'
  _common_setup

  # Set up log files for call assertions
  export MOCK_LLM_LOG
  MOCK_LLM_LOG="$(mktemp)"
}

teardown() {
  rm -f "$MOCK_LLM_LOG"
}

@test "--history-view displays selected conversation" {
  # Configure fzf to return a known conversation_id
  export MOCK_FZF_OUTPUT="abc123 | 2024-01-01 | some prompt"
  export MOCK_LLM_LOGS_LIST="conversation content here"

  run "$LM_SCRIPT" --history-view

  assert_success
  # The llm mock was called with "logs list --cid abc123"
  assert [ -s "$MOCK_LLM_LOG" ]
  run cat "$MOCK_LLM_LOG"
  assert_output --partial "logs list --cid abc123"
}

@test "--history-view exits cleanly on fzf cancel" {
  # Simulate user pressing Esc in fzf (non-zero exit)
  export MOCK_FZF_EXIT=1

  run "$LM_SCRIPT" --history-view

  assert_success
}

@test "--history-view exits cleanly on empty selection" {
  # fzf returns success but empty output
  export MOCK_FZF_OUTPUT=""

  run "$LM_SCRIPT" --history-view

  assert_success
}

