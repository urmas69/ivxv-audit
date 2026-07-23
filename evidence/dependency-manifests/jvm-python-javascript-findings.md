# JVM, Python, and JavaScript provenance findings

Evidence time: 2026-07-23 UTC. Fixed tree: `2785872f84dffb56bbecc41b096a7ee0f2876e64`.

## Gradle and Maven

Direct observation: `common/java/javavar.mk` requires
`common/external/gradle-8.11/bin/gradle` and uses `common/external/java/` as the
Gradle user home. The fixed tree contains neither directory. Online mode uses
only `mavenCentral()`; normal mode adds `--offline`. There is no Gradle wrapper,
dependency lockfile, version catalog, or dependency-verification metadata.
`common/java/common-build.gradle` requires Java 21.

The official `gradle-8.11-bin.zip` remained available from
`services.gradle.org` (redirecting to the official Gradle GitHub release) and
hashed to `57dafb5c2622c6cc08b993c85b7c06956a2f53536432a30ead46166dbca0f1e9`,
matching the official `.sha256` response. IVXV publishes the version but not
this checksum. Gradle publishes signed release tags, but no detached signature
was found adjacent to this binary ZIP.

All 16 directly declared Maven coordinates had both POM and JAR files on the
canonical Maven Central host. Their hashes are in
`evidence/hashes/java/maven-direct-artifacts.csv`. A secondary deps.dev graph
enumeration produced 108 root/node rows and 103 distinct coordinate/version
pairs in `java/graphs/maven-resolved-graphs.csv`. This is reproducible public
resolution evidence, not proof of the absent original cache.

Important discrepancies: the architecture table says Bouncy Castle 1.78.1,
but the executable declaration pins `bcprov-jdk15on` and `bcpkix-jdk15on`
1.70. It says JUnit 5.10.0, while the build pins JUnit 4.13.2. The declaration
governs the build. Because Gradle resolution is not locked or verified and the
offline cache is absent, its original exact contents and metadata cannot be
reconstructed uniquely even though current resolution is public.

## Python

Direct observation: `setup.py` names eleven requirements without version
constraints. It omits `schematics`, despite extensive imports from that package.
The architecture table gives exact versions for the ten non-setuptools
requirements and Schematics 2.1.1. It gives no setuptools version.

Debian packaging expects `common/external/python/requirements.txt` and a
`wheels/` directory, installs with `--no-index`, `--require-hash`, and Python
3.10, and deliberately disables nondeterminism stripping for that package so
wheel hashes remain valid. None of the expected files is tracked at the fixed
commit or in the visible prior `common/external` tree.

All eleven documented exact releases remain public on PyPI. Registry metadata,
all release filenames, Python compatibility markers, upload times, and SHA-256
values are recorded in `evidence/hashes/python/`; the ecosystem manifest uses
the sdist SHA-256 as a stable representative hash. The absent hash-pinned
requirements file prevents identification of the originally selected wheel
filenames and transitive versions. Setuptools is
`not-reconstructable-from-published-information`; named-but-unpinned setup
requirements are reproducible only when combined with the architecture table,
not from packaging metadata alone.

## JavaScript

Direct observation: Debian packaging expects unpacked directories for SB Admin
2, Bootstrap, DataTables, Font Awesome and jQuery. HTML uses those paths, and
SB Admin 2 also supplies its `vendor/` tree. The architecture table gives:
Bootstrap 3.4.1, jQuery 3.7.1, DataTables 2.3.2, Font Awesome 6.7.2,
metisMenu 1.1.3, and SB Admin 2 3.3.7+1.

Exact npm releases remain public for the first five and upstream SB Admin 2
3.3.7. Downloaded tarballs were hashed without retention or execution; npm
integrity and SHA-1 values are also recorded. The `3.3.7+1` identifier is a
historical WebJar release (`org.webjars:startbootstrap-sb-admin-2:3.3.7+1`);
the npm artifact is 3.3.7 and is not asserted byte-identical. Because the
expected IVXV tree is absent, npm tarball availability does not establish
which files were copied, whether bundles were rebuilt, or byte identity of
`datatables.min.js/css` and the SB Admin vendor tree.

## Reproducibility conclusion for these ecosystems

The authoritative Gradle distribution, direct Maven artifacts, documented
Python releases, and most JavaScript upstream releases are publicly obtainable
and hashable. That does not recreate the missing offline inputs uniquely:
Gradle has no locks/verification, Python's hash-pinned wheel manifest is absent,
and JavaScript has no package/lock manifest or preserved bundle. A clean online
dependency resolution can be approximated; the historical offline build input
set cannot be proven byte-for-byte from the fixed published tree.
