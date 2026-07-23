# Phase 2 progress

Updated: 2026-07-23 UTC

## Completed work

- Confirmed the audit repository is on `phase-2`.
- Confirmed the IVXV evidence repository starts at commit
  `2785872f84dffb56bbecc41b096a7ee0f2876e64` with a clean worktree.
- Preserved the full Phase 2 request at `phase2-codex-prompt.md`.

## Current work

- Repository and remote provenance.
- Parallel Go, Java/Gradle, Python, JavaScript, `common/external`, ETCD, OS,
  and release-artifact investigations.

## Remaining work

- Reconcile ecosystem manifests into the canonical CSV.
- Complete the report and unresolved-question register.
- Verify source and audit repository state.
- Commit and push all completed Phase 2 work.
- Mark Phase 2 complete in `README.md` only after validation.

## Failed approaches

- None recorded yet.

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

- None recorded yet.

## Last successful commit

- `d693559` — Phase 1 baseline; no Phase 2 commit yet.
