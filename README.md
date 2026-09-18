# modern-base-template

Language-neutral project template. There is no main programming language here: repositories built from this template
carry only `.sh`, `.md`, `.toml`, and YAML sources, plus whatever data or documents a project needs.

It extracts the baseline shared by the `modern-*-template` family:

- `just` as the only task entrypoint; complex orchestration in `scripts/`.
- Pinned standalone binaries in `runtime/tools/bin` (no language package manager): `shfmt`, ShellCheck, Tombi,
  `actionlint`, `dprint`, `rumdl`, `yamlfmt`, and `source-lines`, each verified against upstream SHA-256 checksums.
- One format chain and one lint chain per file type: shfmt + ShellCheck for shell, Tombi for TOML, `yamlfmt` for YAML,
  dprint + rumdl for Markdown (`textWrap: always` at 120 columns).
- Optional prek Git hooks whose local entries only re-run the same `just` recipes.
- `source-lines` as the single repository source-size gate.
- Template discipline: `AGENTS.md` for template maintainers, `AGENTS.md.template` for downstream projects, contracts in
  `docs/contracts.md`, candidates in `docs/backlog.md`.

## Quick start

```sh
just install   # downloads pinned tools into runtime/tools/bin
just format    # write formatter changes
just fix       # format, apply available fixes, then lint
just check     # run every read-only quality gate
```

## Layout

```text
scripts/    Project shell scripts plus installer and background helpers
docs/       Contracts, backlog, and repository notes
.github/    Workflow validation and Dependabot configuration
runtime/    Ignored: installed tools and background-task state
```

## When a main language arrives

Do not grow this template into a polyglot repo. Copy the project into the matching `modern-*-template` sibling and keep
this template for script-and-document projects.
