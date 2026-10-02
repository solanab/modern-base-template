---
name: base-toolchain-alignment
description: "Use when aligning a repository against this language-neutral quality baseline, including re-aligning an existing toolchain, adopting it, or replacing quality infrastructure. For drift within an accepted contract or pinned-tool upgrades, use base-toolchain-governance; one-off lint fixes are outside both skills."
---

# Base Toolchain Alignment

Align a target repository against the shared quality baseline while preserving its product behavior and language or
runtime contract. This includes a full re-alignment when the target already has tools, rules, or quality infrastructure;
existing tools do not make that request a governance-only drift review. Also use this for adopting the baseline,
replacing tools, and resolving debt caused by the accepted alignment. Drift within an already accepted contract and
pinned-tool upgrades belong to `base-toolchain-governance`; ordinary one-off lint or format fixes use the normal coding
workflow.

## Establish scope and snapshots

Derive scope from the user's original goal. A request to repair local governance does not silently become full-template
alignment, and a request to align the template does not shrink to the first visible lint failure. Record absolute source
and target paths, branch, `HEAD`, and `git status --short --branch`. Fix the source snapshot at a commit or explicitly
label a selected dirty snapshot and its changed paths. Classify overlapping target edits and preserve unrelated changes.

Read both repositories' instructions, README, task entrypoints, contracts, backlog, tool configs, installers, hooks, CI,
docs, release workflows, and relevant automation. Enumerate the complete in-scope source surface from the fixed source
snapshot: quality tools and rules, task entrypoints, hooks, CI, docs, and release paths. Inspect actual commands and
install mechanisms; do not infer pins from version caches. Produce a decision table with one row per surface or coherent
file family, recording scope, source behavior, target behavior, decision/status, evidence, and validation. Include
explicit keep/add/remove/replace choices, owners, pin sources, supported platforms, and checksum/provenance behavior
where relevant. Mark evidence and checks that are unavailable instead of treating them as passed.

The base baseline uses pinned standalone binaries and SHA-256 checksums across declared platforms; it does not impose a
language package manager, lockfile, or runtime. Preserve the target's language, runtime, package identity, APIs, and
product behavior while adopting the shared quality layer unless the user authorized a contract change. Capture relevant
before behavior and define the observable after behavior. Keep migration decisions explicit and resolve only debt caused
by the accepted migration.

Compare observed configuration with the accepted target contract and the user's requested scope. Configuration is
evidence of what runs, not proof that it is desired. Correct mismatches without weakening policy or rewriting docs to
bless accidental behavior. Transfer a replaced tool's config, commands, installer and checksums, hooks, CI, release
paths, and documentation ownership together; remove stale paths and duplicate owners. A product-specific difference may
be justified, but neither copy it mechanically nor expand scope to change it without authorization. Validate each
exception's actual matched paths/rules, whether new files and future code inherit it, and which errors the retained
checks still catch. Inspect matcher behavior and use focused counterexamples when needed to establish the true boundary.
Passing configuration, race, or zero-issue checks alone does not justify an exception.

## Validate and report

Use the repository's native task entrypoint and focused checks, then its authoritative quality gate. Run mutating hooks
only when authorized and when hook configuration, tool versions, matching, or commands changed, or when needed for
consistency; inspect their diff before the final read-only check. Do not run whole-tree formatters or hooks against a
dirty tree without first accounting for affected edits.

This baseline has no runtime dependency audit recipe by design. Dependency audit is not applicable: verify tool
provenance, version pins, platform coverage, and checksums instead. Do not invent a package-manager lockfile or mandate
an audit recipe. If the adopted target has a separate runtime dependency contract, follow that project's established
audit path without imposing it on this language-neutral baseline.

Search for removed or replaced tool references using the inventory. Reconcile every table row with current evidence and
the original user goal before claiming completion. Report snapshots, behavior, ownership decisions, preserved
runtime/product contract, pin and checksum coverage, gate results, exceptions, existing failures, regressions, and
unavailable prerequisites. State the evidence-supported status: read-only review complete, scoped remediation complete,
full alignment complete, or incomplete. Full alignment is complete only when every in-scope table row agrees with the
accepted baseline or has a validated, justified exception, and required gates pass. State any unexecuted, out-of-scope,
or prerequisite-blocked work. A handoff must retain the original goal, unresolved rows, and next actions so it cannot
imply broader completion.
