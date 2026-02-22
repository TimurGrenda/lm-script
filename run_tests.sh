#!/usr/bin/env bash
# Run the bats test suite using the bats-core git submodule.
# Replaces the former "npx bats tests/" workflow so that
# no Node.js / npm toolchain is required.

set -euo pipefail

# Resolve the directory this script lives in, even if called via symlink
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Path to the bats binary provided by the bats-core submodule
BATS="${SCRIPT_DIR}/tests/test_helper/bats-libs/bats-core/bin/bats"

# Ensure the submodule has been initialised
if [[ ! -x "${BATS}" ]]; then
    echo "Error: bats-core submodule not found at ${BATS}" >&2
    echo "Run: git submodule update --init --recursive" >&2
    exit 1
fi

# Default to running all tests if no arguments are provided.
# If arguments are given, pass them through to bats (e.g. individual test files).
if [[ $# -eq 0 ]]; then
    exec "${BATS}" "${SCRIPT_DIR}/tests/"
else
    exec "${BATS}" "$@"
fi
