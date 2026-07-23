# Phase 3 test execution

## Discovery

The fixed tree contains 70 test source files in each isolated checkout:
Go `_test.go` files, Java test classes, and no repository `tests/` directory.
The complete deterministic list is in
`evidence/test-results/{strict,reconstructed}/discovered-tests.txt`.

The root `Makefile` defines `make test`, `make test-go`, `make test-java`, and
`make test-python`; the Python target delegates to a missing `tests` directory.

## Strict execution

The initial harness ran before tool installation and recorded unavailable
runners. After installation, strict Go module tests were run independently with
Go 1.23.12. `common/tools/go` passed. Several modules reached real compilation;
`common/collector` and `voting` remained blocked by inaccessible
`tivi.io/core`. `choices`, `sessionstatus`, and `sessionstatus/api` passed with
`CGO_ENABLED=0`; native CGo linking otherwise lacked the extracted libc archive
at the absolute system path. Strict Java tests remained blocked by the absent
`common/external/gradle-8.11` path. Strict tests never used reconstruction
patches.

## Reconstruction execution

The reconstructed `make test ONLINE=1 CGO_ENABLED=0` run executed real Go tests
and stopped at the common collector aggregate target. Independent module runs
then continued. Passing module commands included `choices`, `mid`, `proxy`,
`sessionstatus`, `sessionstatus/api`, `smartid`, `storage`, `verification`,
`votesorder`, `voting`, `webeid`, and `common/tools/go`; `core` and
`common/collector` had test failures. The aggregate run exposed fixture or
trust-store-dependent failures in `mid`, `ocsp`, `smartid`, and `tsp`, including
certificate/OCSP/TSA verification errors. Detailed output is in
`phase3-toolchain-recon-test-cgo0.txt`, `phase3-recon-core-final.txt`, and
per-module command logs.

Reconstructed Java test targets executed successfully but were reported by
Gradle as `NO-SOURCE` or `SKIPPED`; no Java test method ran. This is a build
system result, not a passing Java test suite.

Python test discovery was attempted; the repository has no `tests/` directory.
The Debian build independently confirmed that the missing
`tests/features/steps/__init__.py` is referenced by the version generator.

The machine-readable logs are `evidence/test-results/strict/execution.log`,
`evidence/test-results/reconstructed/execution.log`, the per-module command
logs, and `evidence/test-results/reconstructed/package-summary.txt`.

## Static/build checks

The source build-system search is preserved in
`evidence/build-a/build-system-search.txt`; no scanner result was treated as a
finding. Python setup metadata was checked without installation and returned
the package name and version recorded in the strict report.
