# Scripts

The root `justfile` is the only task entrypoint. Non-trivial shell behavior lives here so recipes remain easy to audit.

## Tool installation

`install-tools.sh` installs every external tool as a pinned standalone binary. The template has no main language, so
there is no language package manager to lean on; downloaded releases are the single tool path:

| Tool         | Version | Reason                                                 |
| ------------ | ------- | ------------------------------------------------------ |
| `shfmt`      | 3.14.1  | Shell formatting for `scripts/*.sh`                    |
| ShellCheck   | 0.11.0  | Static analysis for `scripts/*.sh`                     |
| Tombi        | 1.4.1   | TOML formatting, linting, and schema-aware diagnostics |
| `actionlint` | 1.7.12  | GitHub Actions workflow validation                     |
| `dprint`     | 0.56.1  | Markdown formatting                                    |
| `rumdl`      | 0.2.60  | Markdown linting                                       |
| `yamlfmt`    | 0.21.0  | YAML formatting checks                                 |

The script supports Linux and macOS on amd64 and arm64. Every download uses an upstream SHA-256 checksum and installs
into ignored `runtime/tools/bin/` paths. `just install` is idempotent.

shfmt reads `.editorconfig`, which sets two-space indentation, indented `case` arms, and binary-operator line breaks.

Prek is intentionally installed outside this script because it is an optional Git-hook runner rather than a build
dependency. Its local hooks only re-run the repository's own `just` recipes, so hook runs and `just check` share one
implementation.

`install-source-lines.sh` downloads the pinned installer from the public `solanab/source-lines-dist` GitHub Release with
`curl`; no GitHub credentials are required. The installer checksum is pinned in the consumer script, and the release
installer verifies the binary archive checksum and version before writing `runtime/tools/bin/source-lines`.

## `background.sh`

`background.sh` manages named, trusted local development commands. Each task has one PID file, one command file, one
process-group mode file, and one log file under ignored `runtime/` paths. Names are restricted to letters, digits, dots,
underscores, and hyphens. On systems with `setsid`, the task gets its own process group so `just` cannot clean it up
when the recipe exits; stop operations target only that recorded PID/group and never search by port or process name.

Do not use this helper for production services. Use a dedicated system or user service with explicit ownership, restart,
logging, and permission policy.

## Conventions

1. Keep complex orchestration in `scripts/`; keep `justfile` recipes declarative.
2. Keep `just check` aligned with CI.
3. Pin downloaded tools and verify their upstream checksums.
4. Update `help.txt` and this document when adding or renaming a recipe or script.
5. Use `trash` for user-requested cleanup recipes; temporary installer directories may be removed directly by their
   owning script.
6. Project shell scripts belong in `scripts/`; they are automatically covered by shfmt, ShellCheck, and source-lines.
