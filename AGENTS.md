# AGENTS.md - modern-base-template template repository

This repository is the language-neutral baseline of the `modern-*-template` family. It owns the shared tooling contract:
`just`, prek, dprint + rumdl for Markdown, Tombi for TOML, shfmt + ShellCheck for shell, yamlfmt for YAML, actionlint,
and source-lines. Downstream projects should copy `AGENTS.md.template` into their own `AGENTS.md` and then add only
project-specific rules.

## Before editing

Read `README.md`, `justfile`, `scripts/README.md`, the quality-tool configuration, the relevant scripts, and the
applicable files under `docs/`. Keep the template runnable and keep its documented contracts aligned.

## Command boundary

- Use `just` as the single human-facing task entrypoint.
- Keep non-trivial orchestration in `scripts/`; keep `justfile` recipes declarative.
- Local agent workflow: after editing, run `just fix`, review its diff, then run `just check`. `just fix` may modify
  files; `just check` is read-only and is the CI-safe gate.
- Run `just check` before claiming a change is complete.
- Use `just hooks-check` when changing hook configuration; Prek complements but does not replace `just check`.
- Keep source-lines as the only repository source-size gate.
- This template has no runtime dependencies, so there is no audit recipe; if a dependency ever appears, add an audit
  recipe and a contracts entry in the same change.

## Tooling boundary

- Every external tool is a pinned standalone binary installed by `scripts/install-tools.sh` into ignored
  `runtime/tools/bin/`; do not introduce a language package manager or global installs.
- Pin versions and upstream SHA-256 checksums for every downloaded artifact.
- prek local hooks only re-run `just` recipes; never add a second command path there.
- Do not grow this template with a main language. New runtime code belongs in the matching `modern-*-template` sibling.

## Template discipline

- Keep `AGENTS.md` (template-maintainer rules) separate from `AGENTS.md.template` (downstream rules).
- Keep downstream instructions portable: do not reference maintainer-local paths or assume that sibling repositories
  exist.
- Pin third-party GitHub Actions to full commit SHAs with release-tag comments, use explicit runner and tool versions,
  and grant only required permissions.
- Do not keep parallel Makefile/Taskfile entrypoints.
- Do not leave obsolete compatibility paths or commented-out implementations.
- Do not modify, revert, commit, or push unrelated user changes.
- Use `trash` in cleanup recipes instead of recursive deletion.

## Agent skills

### Repo skills

None yet.
