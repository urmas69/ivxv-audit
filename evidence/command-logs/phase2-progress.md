# Phase 2 progress

Updated: 2026-07-23 UTC

## Completed work

- Confirmed the audit repository is on `phase-2`.
- Confirmed the IVXV evidence repository starts at commit
  `2785872f84dffb56bbecc41b096a7ee0f2876e64` with a clean worktree.
- Preserved the full Phase 2 request at `phase2-codex-prompt.md`.
- Completed repository/ref and related-repository provenance.
- Completed the full published `common/external` history investigation.
- Completed Go, Gradle/Maven, Python, and JavaScript manifests.
- Completed ETCD/database and OS build-environment investigations.
- Created and validated the 380-row canonical dependency manifest.
- Completed all 16 required report sections.

## Current work

- Phase 2 complete.

## Remaining work

- Build A, Build B, artifact comparison, and the final audit report remain
  pending and are outside Phase 2.

## Failed approaches

- The audit host has no Go executable. Published `h1:` sums were retained and
  proxy objects were independently hashed, but `go mod verify` was not run.
- The Go proxy returned 404 for exact `tivi.io/core` pseudo-version endpoints;
  its reported vanity VCS hostname did not resolve.
- Selected official/mirror/fork paths for database artifacts returned 404.
  These are scoped timestamped negatives, not proof of universal absence.

## Important paths

- Audit repository: `/home/audit/audit/ivxv-audit`
- Read-only source evidence: `/home/audit/audit/ivxv`
- Fixed source commit: `2785872f84dffb56bbecc41b096a7ee0f2876e64`
- Temporary workspace: `/tmp/ivxv-phase2`

## Important commands

- `scripts/capture-command.sh OUTPUT COMMAND [ARG ...]`
- `git -C /home/audit/audit/ivxv show FIXED_COMMIT:PATH`
- `git ls-remote URL`

## Unresolved blockers

- Exact `tivi.io/core` pseudo-version, external dependency repository, ETCD
  payload, offline cache selections, JavaScript bundle, and OS package snapshot
  are not reconstructable from published information.

## Last successful commit

- `fb6f500` — Complete Phase 2 dependency provenance report (pushed to
  `origin/phase-2`).
