# lm

An editor-based wrapper for [llm](https://github.com/simonw/llm). Opens your
`$EDITOR` to compose prompts, streams responses rendered as Markdown, and
supports multi-turn conversations and history browsing. Also does not need
the quotes

## Clone

### Normal Usage
```bash
git clone https://github.com/TimurGrenda/lm-script.git
```
### Development
Clone with submodules (test helper libraries)
```bash
git clone --recurse-submodules https://github.com/TimurGrenda/lm-script.git
```

If you already cloned without `--recurse-submodules`:

```bash
git submodule init
git submodule update
```

## Installation

Add `lm` to your `PATH` so you can run it from any terminal:

```bash
# Create a symlink in a directory that is already on your PATH
ln -s "$(pwd)/lm" ~/.local/bin/lm
```

After that, open a new terminal and type `lm -- your question here` to get a
quick answer.

To update, just `git pull` inside the cloned directory.

## Usage

```bash
# Open editor to compose a prompt
./lm

# Inline prompt (everything after -- is the prompt)
./lm -- explain quicksort

# Continue a previous conversation (interactive picker)
./lm --history-continue

# View a past conversation
./lm --history-view

```

## LLM Template

The script uses an [llm](https://github.com/simonw/llm) template named
**`general`** by default (pass `--template <name>` to override). This template
should instruct the model to end every response with a short menu of single-letter
options for continuing or expanding the conversation — for example:

```
(e) expand  (s) summarize  (d) deeper  (c) counter-argument
```

This is the reason the conversation loop accepts a single-letter quick reply:
pressing one of those letters sends it straight to the model, which recognises
it as the chosen option and continues accordingly.

Create the template with `llm`:

```bash
llm templates edit general
```

and include an instruction like:

> At the end of every response, offer 2-5 follow-up options as single
> lowercase letters in parentheses, e.g. `(e) expand on this point`.

## Running tests

```bash
./run_tests.sh
```
