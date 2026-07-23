# Phase 3 progress

Updated: 2026-07-23 UTC

## Completed work

- Switched to `phase-3` and fast-forward updated from origin.
- Read `prompts/phase-3-clean-room-build.md` completely.
- Confirmed immutable IVXV evidence checkout is at the fixed commit and clean.
- Reopened Phase 3 after review identified that the prior reports stopped at
  missing host tools.
- Installed user-local official toolchains under `/home/audit/tools` and
  documented URLs, versions, sizes, hashes, and environment variables.
- Ran actual strict Make, Go, Java, generator, documentation, submodule, and
  Debian packaging attempts with independent logs.
- Ran actual reconstruction Go builds, Java builds, Go tests, Java test tasks,
  generator steps, and repeated Debian packaging attempts.
- Added explicit reconstruction patches for local `core/`, user-local Make,
  generated-mode normalization, and module-tidy changes.
- Captured 335 reconstructed output files and SHA-256 hashes.
- Attempted strict `make`, component, test, and Debian package entry points;
  all were blocked by missing host tools.
- Created isolated strict and reconstructed checkouts and captured inventories.
- Applied and documented the single experimental local-`core/` replacement
  patch in the reconstruction checkout.
- Discovered 70 test files and recorded separate strict/reconstructed
  non-execution results.
- Created toolchain, build-input, artifact, and source-change manifests.

## Current work

- Phase 3 complete after user-local toolchain continuation.

## Remaining work

- Phase 3 complete. Build A, Build B, independent comparison, deployment/E2E
  testing, and final audit report remain pending outside this phase.

## Failed approaches

- `sudo -n apt-get install` could not run because the VM requires a password.
- Initial root entry points failed because tools were absent. User-local
  extraction resolved the generic tool blocker.
- Strict published builds remain blocked by missing project-specific
  `common/external` inputs, inaccessible `tivi.io/core`, generated-source
  expectations, and absent packaging support files.
- Reconstruction Debian packaging reached `debian/rules build` but stopped at
  missing `tests/features/steps/__init__.py`; no .deb was produced.

## Important paths

- Audit repository: `/home/audit/audit/ivxv-audit`
- Immutable source evidence: `/home/audit/audit/ivxv`
- Fixed commit: `2785872f84dffb56bbecc41b096a7ee0f2876e64`
- Strict temporary checkout: `/tmp/ivxv-phase3-strict`
- Reconstruction checkout: `/home/audit/audit/ivxv-reconstructed`

## Last successful commit

- `9ab1295` — Run Phase 3 builds with user-local toolchains (pushed to
  `origin/phase-3-clean-room-build`).
