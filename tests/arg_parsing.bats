#!/usr/bin/env bats
# Unit tests for parse_args() — the argument parser.
# This is the highest-value test file since argument parsing has the most
# interesting boundary behavior and edge cases.

setup() {
  load 'test_helper/common_setup'
  _common_setup
  _source_lm
}

@test "no arguments: default template, empty prompt" {
  parse_args

  assert_equal "${LLM_OPTS[*]}" "-t general"
  assert_equal "$PROMPT" ""
}

@test "prompt after -- separator" {
  parse_args -- "hello world"

  assert_equal "$PROMPT" "hello world"
  assert_equal "${LLM_OPTS[*]}" "-t general"
}

@test "multi-word prompt after --" {
  parse_args -- this is a multi word prompt

  assert_equal "$PROMPT" "this is a multi word prompt"
}

@test "-t code suppresses default template" {
  parse_args -t code

  # Should have -t code, NOT -t general
  assert_equal "${LLM_OPTS[*]}" "-t code"
  assert_equal "$has_template" "true"
}

@test "--template code suppresses default template" {
  parse_args --template code

  assert_equal "${LLM_OPTS[*]}" "--template code"
  assert_equal "$has_template" "true"
}

@test "flags before -- accumulated in LLM_OPTS" {
  parse_args -m gpt-4 -- hello

  # -m and gpt-4 are separate entries in LLM_OPTS, plus the default template
  assert_equal "${LLM_OPTS[*]}" "-m gpt-4 -t general"
  assert_equal "$PROMPT" "hello"
}

@test "multiple flags before --" {
  parse_args -m gpt-4 -s system-prompt -- hello

  assert_equal "${LLM_OPTS[*]}" "-m gpt-4 -s system-prompt -t general"
  assert_equal "$PROMPT" "hello"
}

@test "no -- separator: no prompt, all args are opts" {
  parse_args -m gpt-4 -s "be concise"

  assert_equal "$PROMPT" ""
  # Everything goes to LLM_OPTS since there's no -- separator
  assert_equal "${LLM_OPTS[*]}" "-m gpt-4 -s be concise -t general"
}

@test "empty prompt after --" {
  parse_args --

  assert_equal "$PROMPT" ""
  assert_equal "${LLM_OPTS[*]}" "-t general"
}

@test "unrecognized flags pass through (e.g. -T is not -t)" {
  # -T is not the template flag, should be passed through as a regular opt
  parse_args -T something -- hello

  assert_equal "${LLM_OPTS[*]}" "-T something -t general"
  assert_equal "$PROMPT" "hello"
}
