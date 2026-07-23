# Phase 3 test execution

## Discovery

The fixed tree contains 70 test source files in each isolated checkout:
Go `_test.go` files, Java test classes, and no repository `tests/` directory.
The complete deterministic list is in
`evidence/test-results/{strict,reconstructed}/discovered-tests.txt`.

The root `Makefile` defines `make test`, `make test-go`, `make test-java`, and
`make test-python`; the Python target delegates to a missing `tests` directory.

## Execution

Both isolated tracks ran the test harness script. Go tests were not executed
because Go was unavailable. Python discovery was not executed because the
repository has no `tests/` directory. Java tests could not execute because
Java/Gradle and Make were unavailable. No test passed, failed, or was skipped
by a test runner; all 70 discovered files in each track are therefore
unexecuted.

This is distinct from a passing or failing test result. The machine-readable
logs are `evidence/test-results/strict/execution.log` and
`evidence/test-results/reconstructed/execution.log`.

## Static/build checks

The source build-system search is preserved in
`evidence/build-a/build-system-search.txt`; no scanner result was treated as a
finding. Python setup metadata was checked without installation and returned
the package name and version recorded in the strict report.
