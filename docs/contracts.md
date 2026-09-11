# Enabled code contract

> **Layer 1 Stable** (currently MUST) plus a few layer 2 constraints that may be promoted later. When changing any
> section: sync executable configuration and the necessary backlog → `just check`. This document must not form a second
> rule set beside `justfile`, `prek.toml`, or CI.

**Layer 0 Invariant** is not restated at length here; see the maintainer contract in the root `AGENTS.md`.

## Stable (layer 1: currently MUST)

### S1. No main-language boundary

| Policy                                                                                           | Enforcement                  |
| ------------------------------------------------------------------------------------------------ | ---------------------------- |
| This template only carries `.sh`, `.md`, `.toml`, YAML, and pure data files                      | Directory convention, review |
| When a main language is needed, migrate to the matching `modern-*-template`; do not grow it here | Root `AGENTS.md`, review     |
| Tools are always standalone binaries; do not introduce a language package manager                | `scripts/install-tools.sh`   |

### S2. Command entrypoints and script boundary

- Human-visible tasks have only `just` entrypoints; complex shell orchestration lives in `scripts/`.
- Project shell scripts live in `scripts/` and are automatically covered by shfmt, ShellCheck, and the source-lines
  gate.
- Do not keep parallel Makefile, Taskfile, or legacy compatibility entrypoints.

Enforcement: directory convention, `justfile-check`, `just check`, and review.

### S3. Format and documentation baseline

- Shell, TOML, YAML, and Markdown each have one format chain: shfmt for shell; Tombi for TOML; `yamlfmt` for YAML;
  dprint for Markdown format, rumdl for Markdown lint. Markdown `textWrap` is `always` at 120 columns.
- Tombi promotes every warning to an error in `just check`.
- source-lines is the only repository source-size gate: by default each file stays at or below 300 effective code lines
  and 1000 total lines; total lines include effective code, comment-only lines, and blank lines. 300/1000 is a
  governance guardrail, not a universal defect threshold; crossing it first triggers a split or refactor review.
- A file may raise its cap only with an exact-path reason in source-lines.toml; do not pre-relax tests or examples.
- When adding or renaming a recipe, script, or quality tool, sync `scripts/README.md`, the README, and help text.

Enforcement: `just fmt-check`, `just lint`, `source-lines.toml`, `just check`.

### S4. Tool supply chain

| Policy                                                    | Enforcement                    |
| --------------------------------------------------------- | ------------------------------ |
| Pin every downloaded tool and verify its upstream SHA-256 | `scripts/install-tools.sh`     |
| Install tools only into ignored `runtime/tools/bin/`      | `.gitignore`, installer script |
| prek local hooks only reuse `just` recipes                | `prek.toml`                    |

Hooks and `just check` share the same implementation path; do not add a second check command inside hooks.

### S5. Quality gate and dependency audit

- `just check` is the only local quality-gate aggregate: justfile syntax, the four format checks, Markdown/shell/TOML/
  workflow lint, and source-lines.
- This template has no runtime dependencies, so there is no `audit` recipe. If any dependency is introduced (including a
  new downloaded tool), add the matching audit entry here and the recipe in the same change; do not skip it silently.

### S6. Downstream copy contract

Template-maintainer rules stay in the root `AGENTS.md`. Downstream projects copy `AGENTS.md.template` and then add
project-specific rules. Downstream contracts must not reference maintainer-local paths, sibling repositories, or implied
tools outside this template.

## Evolving (layer 2: not promoted by default)

There are currently no Evolving entries that have been promoted and are in force. Candidate practices live in
[`backlog.md`](./backlog.md); after enabling one, move the policy into this section, sync configuration, and delete the
original backlog entry.

## Change log

| Date       | Change                                                                                  |
| ---------- | --------------------------------------------------------------------------------------- |
| 2026-08-24 | Initial version: language-neutral baseline extracted from the modern-\*-template family |
