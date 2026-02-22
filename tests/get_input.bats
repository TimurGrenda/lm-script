#!/usr/bin/env bats
# Tests for get_input() — editor input validation.
# These tests use a mock EDITOR that writes controlled content to the temp file.

setup() {
  load 'test_helper/common_setup'
  _common_setup
  _source_lm

  # Create a temp directory for test artifacts
  TEST_TMPDIR="$(mktemp --directory)"

  # Override TMPDIR so get_input() creates files in our test directory
  export TMPDIR="$TEST_TMPDIR"
}

teardown() {
  rm -rf "$TEST_TMPDIR"
}

# Helper: create a mock editor that writes specific content to the file it receives
_mock_editor_with_content() {
  local content="$1"
  local editor_script="$TEST_TMPDIR/mock_editor.sh"
  # The mock editor writes the specified content to its last argument (the file)
  cat > "$editor_script" <<EDITOR_EOF
#!/bin/bash
echo '$content' > "\${!#}"
EDITOR_EOF
  chmod +x "$editor_script"
  export EDITOR="$editor_script"
}

# Helper: create a mock editor that leaves the file empty
_mock_editor_empty() {
  local editor_script="$TEST_TMPDIR/mock_editor.sh"
  cat > "$editor_script" <<'EDITOR_EOF'
#!/bin/bash
# Leave the file as-is (empty)
true
EDITOR_EOF
  chmod +x "$editor_script"
  export EDITOR="$editor_script"
}

# Helper: create a mock editor that writes specific raw content
_mock_editor_raw() {
  local content="$1"
  local editor_script="$TEST_TMPDIR/mock_editor.sh"
  # Use printf to handle newlines and whitespace precisely
  cat > "$editor_script" <<EDITOR_EOF
#!/bin/bash
printf '%s' '$content' > "\${!#}"
EDITOR_EOF
  chmod +x "$editor_script"
  export EDITOR="$editor_script"
}

@test "empty editor output returns empty" {
  _mock_editor_empty

  run get_input

  assert_success
  assert_output ""
}

@test "non-empty editor output returns content" {
  _mock_editor_with_content "hello world"

  run get_input

  assert_success
  assert_output "hello world"
}

@test "whitespace-only returns empty" {
  _mock_editor_raw "   "

  run get_input

  assert_success
  assert_output ""
}

@test "newlines-only returns empty" {
  local editor_script="$TEST_TMPDIR/mock_editor.sh"
  cat > "$editor_script" <<'EDITOR_EOF'
#!/bin/bash
printf '\n\n\n' > "${!#}"
EDITOR_EOF
  chmod +x "$editor_script"
  export EDITOR="$editor_script"

  run get_input

  assert_success
  assert_output ""
}

@test "tmpfile variable reset after empty input" {
  _mock_editor_empty
  tmpfile="should-be-cleared"

  get_input

  assert_equal "$tmpfile" ""
}
