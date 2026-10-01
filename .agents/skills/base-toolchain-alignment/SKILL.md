---
name: base-toolchain-alignment
description: "Use when adopting this language-neutral quality baseline, replacing its tools, or migrating quality infrastructure, then repairing resulting debt. For drift reviews and pinned-tool upgrades, use base-toolchain-governance; one-off lint fixes are outside both skills."
---

# Base Toolchain Alignment

Adopt or replace the shared quality layer in a language-neutral repository while preserving its product behavior and any
existing language or runtime contract. Use this for a new baseline, tool replacement, or quality-infrastructure
migration and the debt caused by that work. Ordinary one-off lint or format fixes use the normal coding workflow;
existing-tool drift and upgrades belong to `base-toolchain-governance`.

## Establish the source and target

Record the absolute source and target paths, branch, `HEAD`, and `git status --short --branch`. Use a clean baseline
commit unless the user selects a dirty snapshot; label and record its changed paths. Classify target edits that overlap
the work and preserve unrelated changes.

Read both repositories' instructions, README, `justfile` or equivalent task entrypoints, contracts, backlog, tool
configs, installers, hooks, CI, and relevant docs. Inventory tools from actual commands and install mechanisms. For each
tool and file family, record owner, pin source, platform coverage, checksum/provenance verification, config, commands,
hooks, CI, docs, and keep/add/remove/replace decisions. Identify shared baseline ownership and deliberate vendored
configuration. Do not infer pins from version caches.

The base baseline uses pinned standalone binaries and SHA-256 checksums across declared platforms; it does not impose a
language package manager, lockfile, or runtime. Preserve the target's language, runtime, package identity, APIs, and
product behavior while adopting the shared quality layer unless the user authorized a contract change. Capture relevant
before behavior and define the observable after behavior. Keep migration decisions explicit and resolve only debt caused
by the accepted migration.

Compare observed configuration with the accepted target contract. Treat configuration as evidence of what runs, not
proof that it is desired. Correct mismatches without weakening policy or rewriting docs to bless accidental behavior.
Transfer a replaced tool's config, commands, installer and checksums, hooks, CI, and documentation ownership together;
remove stale paths and duplicate owners. Keep only justified exceptions with scope and rationale.

## Validate and report

Use the repository's native task entrypoint and focused checks, then its authoritative quality gate. Run mutating hooks
only when authorized and when hook configuration, tool versions, matching, or commands changed, or when needed for
consistency; inspect their diff before the final read-only check. Do not run whole-tree formatters or hooks against a
dirty tree without first accounting for affected edits.

This baseline has no runtime dependency audit recipe by design. Dependency audit is not applicable: verify tool
provenance, version pins, platform coverage, and checksums instead. Do not invent a package-manager lockfile or mandate
an audit recipe. If the adopted target has a separate runtime dependency contract, follow that project's established
audit path without imposing it on this language-neutral baseline.

Search for removed or replaced tool references using the inventory. Report source and target snapshots, before/after
behavior, ownership decisions, preserved runtime/product contract, pin and checksum coverage, relevant gate results,
exceptions, existing failures, regressions, and unavailable prerequisites. Inspection completion is distinct from
remediation completion; claim remediation only when the target contract is satisfied and required gates pass.
