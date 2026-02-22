#!/usr/bin/env bats
# Static analysis — ensures the lm script passes shellcheck.

setup() {
  load 'test_helper/common_setup'
  _common_setup
}

@test "lm passes shellcheck" {
  # --shell=bash: explicitly set the shell dialect
  # --external-sources: allow sourced files (not relevant here, but future-proof)
  run shellcheck --shell=bash --external-sources "$LM_SCRIPT"
  assert_success
}
