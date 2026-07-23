# Phase 3 progress

Updated: 2026-07-23 UTC

## Completed work

- Switched to `phase-3` and fast-forward updated from origin.
- Read `prompts/phase-3-clean-room-build.md` completely.
- Confirmed immutable IVXV evidence checkout is at the fixed commit and clean.
- Attempted strict `make`, component, test, and Debian package entry points;
  all were blocked by missing host tools.
- Created isolated strict and reconstructed checkouts and captured inventories.
- Applied and documented the single experimental local-`core/` replacement
  patch in the reconstruction checkout.
- Discovered 70 test files and recorded separate strict/reconstructed
  non-execution results.
- Created toolchain, build-input, artifact, and source-change manifests.

## Current work

- Final validation, report review, README update, commit, and push.

## Remaining work

- Phase 3 complete. Build A, Build B, independent comparison, deployment/E2E
  testing, and final audit report remain pending outside this phase.

## Failed approaches

- `sudo -n apt-get install` could not run because the VM requires a password.
- `make`, Go, Java, Gradle, compiler, and `dpkg-buildpackage` were absent, so
  no compilation, test runner, or package output was possible.

## Important paths

- Audit repository: `/home/audit/audit/ivxv-audit`
- Immutable source evidence: `/home/audit/audit/ivxv`
- Fixed commit: `2785872f84dffb56bbecc41b096a7ee0f2876e64`
- Strict temporary checkout: `/tmp/ivxv-phase3-strict`
- Reconstruction checkout: `/home/audit/audit/ivxv-reconstructed`

## Last successful commit

- `5b17fcf` — Add Phase 3 clean-room build specification. (Update this field
  after the completion commit.)
