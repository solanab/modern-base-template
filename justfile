set shell := ["bash", "-euo", "pipefail", "-c"]

repo := justfile_directory()
tool_bin := repo + "/runtime/tools/bin"
shfmt_bin := tool_bin + "/shfmt"
shellcheck_bin := tool_bin + "/shellcheck"
tombi_bin := tool_bin + "/tombi"
dprint_bin := tool_bin + "/dprint"
rumdl_bin := tool_bin + "/rumdl"
actionlint_bin := tool_bin + "/actionlint"
yamlfmt_bin := tool_bin + "/yamlfmt"
source_lines_bin := tool_bin + "/source-lines"
source_lines_version := "0.2.0"

default: help

alias h := help
alias i := install
alias l := lint
alias f := fmt
alias c := check
alias bg := bg-start

help:
    @cat scripts/help.txt

install: install-tools install-source-lines

install-tools:
    ./scripts/install-tools.sh

install-source-lines:
    ./scripts/install-source-lines.sh {{ quote(source_lines_version) }}

hooks-install:
    command -v prek >/dev/null 2>&1 || { echo 'prek is optional; install it with `uv tool install prek` or `brew install prek`' >&2; exit 1; }
    prek install

hooks-check:
    command -v prek >/dev/null 2>&1 || { echo 'prek is optional; install it with `uv tool install prek` or `brew install prek`' >&2; exit 1; }
    prek run --all-files

markdown-format:
    test -x {{ quote(dprint_bin) }} || { echo 'run `just install` first' >&2; exit 1; }
    {{ quote(dprint_bin) }} fmt --allow-no-files

markdown-fmt-check:
    test -x {{ quote(dprint_bin) }} || { echo 'run `just install` first' >&2; exit 1; }
    {{ quote(dprint_bin) }} check --allow-no-files

markdown-lint:
    test -x {{ quote(rumdl_bin) }} || { echo 'run `just install` first' >&2; exit 1; }
    {{ quote(rumdl_bin) }} check --deny-config-warnings

justfile-check:
    just --unstable --fmt --check

fmt: shell-fmt toml-fmt yaml-fmt markdown-format

fmt-check: shell-fmt-check toml-fmt-check yaml-lint markdown-fmt-check

shell-fmt:
    test -x {{ quote(shfmt_bin) }} || { echo 'run `just install` first' >&2; exit 1; }
    {{ quote(shfmt_bin) }} -w -i 2 -ci scripts/*.sh

shell-fmt-check:
    test -x {{ quote(shfmt_bin) }} || { echo 'run `just install` first' >&2; exit 1; }
    output="$({{ quote(shfmt_bin) }} -d -i 2 -ci scripts/*.sh)"; if [[ -n "$output" ]]; then printf '%s\n' "$output"; exit 1; fi

shell-lint:
    test -x {{ quote(shellcheck_bin) }} || { echo 'run `just install` first' >&2; exit 1; }
    {{ quote(shellcheck_bin) }} scripts/*.sh

toml-fmt:
    test -x {{ quote(tombi_bin) }} || { echo 'run `just install` first' >&2; exit 1; }
    {{ quote(tombi_bin) }} format

toml-fmt-check:
    test -x {{ quote(tombi_bin) }} || { echo 'run `just install` first' >&2; exit 1; }
    {{ quote(tombi_bin) }} format --check

toml-lint:
    test -x {{ quote(tombi_bin) }} || { echo 'run `just install` first' >&2; exit 1; }
    {{ quote(tombi_bin) }} lint --error-on-warnings

yaml-fmt:
    test -x {{ quote(yamlfmt_bin) }} || { echo 'run `just install` first' >&2; exit 1; }
    {{ quote(yamlfmt_bin) }} -gitignore_excludes .

yaml-lint:
    test -x {{ quote(yamlfmt_bin) }} || { echo 'run `just install` first' >&2; exit 1; }
    {{ quote(yamlfmt_bin) }} -lint -gitignore_excludes .

lint: markdown-lint shell-lint toml-lint actionlint

actionlint:
    test -x {{ quote(actionlint_bin) }} || { echo 'run `just install` first' >&2; exit 1; }
    {{ quote(actionlint_bin) }}

source-lines:
    test -x {{ quote(source_lines_bin) }} || { echo 'run `just install` first' >&2; exit 1; }
    {{ quote(source_lines_bin) }} --config {{ quote(repo + "/source-lines.toml") }} {{ quote(repo) }}

check: justfile-check fmt-check lint source-lines

# Start an arbitrary local command in the background; command runs as a trusted shell command

# Example: just bg docs './scripts/gen-docs.sh'
bg-start name command:
    ./scripts/background.sh start {{ quote(name) }} {{ quote(command) }}

bg-stop name timeout="10":
    ./scripts/background.sh stop {{ quote(name) }} {{ quote(timeout) }}

bg-status name:
    ./scripts/background.sh status {{ quote(name) }}

bg-list:
    ./scripts/background.sh list

bg-logs name lines="80":
    ./scripts/background.sh logs {{ quote(name) }} {{ quote(lines) }}

clean:
    for path in dist build runtime; do if [[ -e "$path" ]]; then trash "$path"; fi; done
