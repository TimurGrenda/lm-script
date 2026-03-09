# Plan: Replace `--` separator with `:` and add interactive readline

**Created**: 2026-03-09T12:00:00Z
**Status**: Ready for implementation

## Goal

Replace the `--` prompt separator with `:` to avoid bash metacharacter issues (parentheses, backticks, etc. cause syntax errors before `lm` runs), and add an interactive readline mode when `:` is used with no prompt after it.

## Refined Requirements

- Replace `--` with `:` in `parse_args()` as the prompt separator
- `lm : some text` → inline prompt (same as old `lm -- some text`)
- `lm :` (bare) → interactive single-line readline prompt with `prompt: ` indicator
- `:` is combinable with flags: `lm -m gpt-4 : explain quicksort`
- Remove `--` support entirely (clean break, no backwards compat)
- No new flags added (avoids conflicts with llm's own flags)
- Scope: initial query only, conversation loop unchanged
- Update all tests from `--` to `:`
- Add new tests for interactive readline mode
- Update README with new syntax
- Create CHANGELOG.md

## Implementation Steps

### Step 1: Modify parse_args() in lm script

**File**: `lm` (lines 65-99)
**Action**: modify
**Details**: Replace the `--` case with `:` case in the `while` loop. Update the function comment. When `:` is the last argument (no remaining args after shift), set a flag `INTERACTIVE_PROMPT=true` instead of setting PROMPT.

### Step 2: Add get_readline_input() function and wire up main()

**File**: `lm` (after line 20, and lines 134-142)
**Action**: modify
**Details**: Add a `get_readline_input()` function that uses `read -e -r -p "prompt: "` from `$LM_TTY`. In `main()`, add a branch: if `INTERACTIVE_PROMPT` is true, call `get_readline_input` and use its output.

### Step 3: Update arg_parsing.bats tests

**File**: `tests/arg_parsing.bats`
**Action**: modify
**Details**: Change all `--` references to `:` in test cases. Add new test for bare `:` setting `INTERACTIVE_PROMPT=true`. Add test for `:` with text after setting `PROMPT`.

### Step 4: Update integration.bats tests

**File**: `tests/integration.bats`
**Action**: modify
**Details**: Change `--` to `:` in both integration tests. Add a test for interactive readline mode using a heredoc or similar to feed input.

### Step 5: Update README.md

**File**: `README.md`
**Action**: modify
**Details**: Replace all `--` usage examples with `:`. Add a note about the advantage of `:` over `--` (no quoting needed for special chars). Add the `lm :` interactive mode example.

### Step 6: Create CHANGELOG.md

**File**: `CHANGELOG.md`
**Action**: create
**Details**: Create changelog with an Unreleased section documenting the separator change and interactive readline addition.

## Files Affected

| File | Action | Description |
|------|--------|-------------|
| `lm` | modify | Replace `--` with `:` in parse_args, add get_readline_input(), update main() |
| `tests/arg_parsing.bats` | modify | Update all `--` to `:`, add tests for bare `:` and INTERACTIVE_PROMPT |
| `tests/integration.bats` | modify | Update `--` to `:`, add interactive mode test |
| `README.md` | modify | Update examples, document `:` advantages |
| `CHANGELOG.md` | create | Initial changelog with unreleased changes |

## Risks & Open Questions

- `read -e` enables readline editing but may not be available in all bash versions (should be fine on modern systems)
- Need to handle Ctrl+C/Ctrl+D in readline gracefully (empty input → exit)
- ShellCheck must still pass after changes

## Testing

- Run `./run_tests.sh` after all changes
- Run `shellcheck lm` to verify static analysis
- Manual test: `lm : explain quicksort` and `lm :` (interactive)
- Manual test: `lm : how to apply commits (starting with some commit)` — the original failing case
