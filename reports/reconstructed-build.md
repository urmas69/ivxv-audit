# Phase 3 Track 2 — controlled research reconstruction

## Scope

The reconstruction checkout is `/home/audit/audit/ivxv-reconstructed`, at the
same fixed commit before modification. It contains only the explicit patch
`patches/reconstruction/0001-use-published-local-core.patch`.

## Modification

The patch adds local `replace tivi.io/core => ../../core` and
`replace tivi.io/core => ../core` directives for `common/collector` and
`voting`, respectively. It substitutes the published root `core/` snapshot
for the inaccessible pseudo-version required by those modules.

This is a research substitution. The Phase 2 evidence recorded proxy 404s,
an unresolved vanity VCS hostname, absence of pseudo-commit `149435f9e4f4`
from the IVXV object database, and no proof that local `core/` is equivalent.
The patch therefore cannot represent KOV2025 provenance or behavior.

## Toolchain and explicit external substitutions

The same official user-local toolchain was used for reconstruction. The
Gradle distribution was exposed at the expected path through an explicitly
documented symlink to `/home/audit/tools/gradle/gradle-8.11`; no dependency
cache or build tree was committed. Debian packaging additionally used the
explicit `0002-use-user-local-make.patch` and a local fakeroot wrapper. These
are research substitutions, not KOV2025 inputs.

## Attempts and actual results

The reconstructed checkout was inventoried and the following were attempted:

- `make clean && make && make test`;
- `make go`;
- `make java`;
- `dpkg-buildpackage -us -uc -b`.

After user-local installation, `make java ONLINE=1` completed successfully
for `common/java`, `key`, `processor`, and `auditor`. Gradle reported
`BUILD SUCCESSFUL` for all four distributions, including generated JARs,
start scripts, and distribution archives. `make go ONLINE=1 CGO_ENABLED=0`
completed successfully for all Go components after running the core error
generator. Direct Go tests also built every reconstructed module; the generated
test run exposed environment-dependent failures described in the test report.

The first native-CGo attempt failed because the extracted user-local GCC could
not use `/usr/lib/x86_64-linux-gnu/libc_nonshared.a` without root-installed
development paths. The successful reconstruction build used
`CGO_ENABLED=0`; this is an explicit toolchain behavior difference.

`make test-java ONLINE=1` completed successfully, but Gradle reported
`NO-SOURCE` for the Java test tasks. `make test ONLINE=1 CGO_ENABLED=0`
executed Go tests and stopped at the common collector test target after real
test failures. Independent module test commands continued through all
reconstructed Go modules.

The successful Java build and later Go build emitted 335 inventoried files,
including service JARs, launcher scripts, distribution archives, and Go
executables. Paths and sizes are in `evidence/build-reconstruction/output-files.tsv`;
SHA-256 values are in `output-sha256sums.txt`. No package cache or binary tree
was copied into the audit repository.

Debian packaging was attempted repeatedly. It progressed through `dh clean` and
`debian/rules build` with extracted dpkg/debhelper/fakeroot tooling, then
failed in `common/tools/update_project_version.py` because the fixed tree
references the absent `tests/features/steps/__init__.py`. A dependency-checked
run also reported absent `build-essential`, `dh-exec`, `dh-python`, and
`python3-all` before the extracted tools were added. No Debian package was
produced.

## Research status by area

| area | status | reason |
|---|---|---|
| local `core/` substitution | patch applied and built | experimental only; no equivalence to KOV2025 |
| Go components | built with `CGO_ENABLED=0` | local core patch and generated code; not KOV2025 original |
| Java components | built successfully | Gradle distribution exposed at expected external path |
| Debian packages | not produced | missing `tests/features/steps/__init__.py` stops `debian/rules build` |
| Python metadata | inspected in strict checkout | setup metadata commands succeeded |
| JavaScript assets | not reconstructed | no build reached; Phase 2 hashes retained as provenance only |
| ETCD bundle | not substituted | project-specific archive and scripts unavailable |

Reconstructed Java distributions and Go binaries are suitable for later
behavioral testing as research artifacts. They are traceable to the fixed
commit, explicit reconstruction patches, user-local toolchain manifest, and
temporary dependency caches. They cannot be attributed to KOV2025 production.
