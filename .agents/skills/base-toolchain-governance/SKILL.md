---
name: base-toolchain-governance
description: "Use when reviewing or repairing drift within an accepted language-neutral toolchain contract, upgrading pinned tools, or maintaining its rules and exceptions. For adopting or fully aligning against the shared baseline, including an existing toolchain, use base-toolchain-alignment; one-off lint fixes are outside both skills."
---

# Base Toolchain Governance

Maintain an accepted quality contract in the current repository. Use this for drift review or upgrades within that
contract; when the goal is to align against the shared baseline, use `base-toolchain-alignment` even if tools already
exist. Derive the review scope from the user's original goal; a local governance request does not imply full-template
alignment. Classify the request as inspection-only or authorized repair/upgrade. Inspection-only work uses static,
read-only evidence and reports findings without edits or mutating commands. When repair or upgrade is authorized,
proceed within that scope without redundant approval.

## Inspect the accepted contract

Record the absolute repository path, branch, `HEAD`, and `git status --short --branch`. Read repository instructions,
README, contracts and backlog, task entrypoints, actual configurations, installers, hooks, CI, and relevant docs.
Discover tools from real commands, install mechanisms, hooks, and CI; do not assume a fixed tool list or trust version
caches. Map each tool and gate to its pin source, platform assets, checksums/provenance, config, command, hook, CI,
contract, docs, and owner. Record overlapping edits before any authorized repair.

Compare configured behavior with the accepted contract and check that all maintained source/file families and actual
quality tools are covered by the authoritative gate. Configuration shows what runs; it does not establish desired
policy. Do not describe weakened configuration as compliant by changing documentation. Enabled rules belong in active
policy and enforcing configuration; backlog candidates stay inactive until explicitly promoted, then leave the backlog.
For each exception, verify the paths and rules it actually matches, whether new files and future code inherit it, and
which errors the retained checks still catch; inspect matcher behavior and use focused counterexamples when needed to
establish the true boundary. A passing configuration, race, or zero-issue result alone does not establish that the
exception is justified. Classify mismatches as existing failures, regressions, accepted exceptions, authorized repairs,
or missing prerequisites.

## Repair drift or upgrade pinned tools

Reconcile only the authorized scope. For upgrades, inspect release notes and compatibility for tools actually found in
the repository; update compatible tools in coherent batches. Update every associated version and checksum surface,
supported-platform mapping, installer verification, CI setup, commands, and docs. Preserve standalone-binary
installation and do not introduce a package manager, lockfile, or runtime requirement through this baseline. Treat
changing those contracts as an explicit decision within the user's authorization.

Keep one owner per behavior unless the accepted contract deliberately splits it. Maintain exceptions with concrete scope
and rationale. Search for stale tool names and pins across installers, checksums, configs, commands, hooks, CI,
contracts, and docs. One-off lint fixes do not invoke this workflow.

## Validate and report

For inspection-only requests, use read-only static checks; do not run mutating hooks or formatters. For authorized
changes, run focused affected checks and the authoritative repository gate. Run mutating hooks only when authorized and
relevant to changed hook config, tool versions, matching, or commands, or when consistency requires it; review their
diff before the final read-only check. Do not run whole-tree auto-fixes against unclassified dirty changes.

This template's lack of runtime dependencies and audit recipe is intentional. Dependency audit is not applicable; verify
standalone-tool provenance, pins, platform coverage, and SHA-256 checksums. Do not add an audit recipe, package manager,
or lockfile solely to satisfy a generic audit workflow. If this repository separately owns runtime dependencies, follow
its explicit contract for those dependencies.

Reconcile findings and any authorized repairs with the user's goal and the in-scope inventory. Report coverage, accepted
behavior, contract impact, repairs or upgrade versions, pin/checksum consistency, exceptions, and actual validation
evidence. Distinguish prior failures, new regressions, unexecuted checks, out-of-scope work, and missing prerequisites.
State whether read-only review is complete, scoped remediation is complete, or broader alignment remains incomplete.
Findings-only inspection may complete with findings; remediation is complete only when required gates pass and config,
commands, hooks, CI, pins, checksums, docs, and accepted policy agree. A handoff retains the original goal and
unresolved work without implying completion beyond the reviewed scope.
