---
name: base-toolchain-governance
description: "Use when reviewing or repairing drift in an established language-neutral toolchain, upgrading pinned tools, or maintaining accepted quality rules and exceptions. For baseline adoption or replacement, use base-toolchain-alignment; one-off lint fixes are outside both skills."
---

# Base Toolchain Governance

Maintain an established quality contract in the current repository. First classify the request as inspection-only or
authorized repair/upgrade. Inspection-only work uses static, read-only evidence and reports findings without edits or
mutating commands. When repair or upgrade is authorized, proceed within that scope without redundant approval.

## Inspect the accepted contract

Record the absolute repository path, branch, `HEAD`, and `git status --short --branch`. Read repository instructions,
README, contracts and backlog, task entrypoints, actual configurations, installers, hooks, CI, and relevant docs.
Discover tools from real commands, install mechanisms, hooks, and CI; do not assume a fixed tool list or trust version
caches. Map each tool and gate to its pin source, platform assets, checksums/provenance, config, command, hook, CI,
contract, docs, and owner. Record overlapping edits before any authorized repair.

Compare configured behavior with the accepted contract. Configuration shows what runs; it does not establish desired
policy. Do not describe weakened configuration as compliant by changing documentation. Enabled rules belong in active
policy and enforcing configuration; backlog candidates stay inactive until explicitly promoted, then leave the backlog.
Review exceptions for owner, scope, rationale, and evidence. Classify mismatches as existing failures, regressions,
accepted exceptions, authorized repairs, or missing prerequisites.

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

Report inventory coverage, accepted behavior, findings and contract impact, repairs or upgrade versions, pin/checksum
consistency, exceptions, and validation. Distinguish prior failures, new regressions, and missing prerequisites.
Findings-only inspection may complete with findings; remediation is complete only when all required gates pass and
config, commands, hooks, CI, pins, checksums, docs, and accepted policy agree.
