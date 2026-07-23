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

## Attempts

The reconstructed checkout was inventoried and the following were attempted:

- `make clean && make && make test`;
- `make go`;
- `make java`;
- `dpkg-buildpackage -us -uc -b`.

Each stopped at exit 127 because `make` or `dpkg-buildpackage` is unavailable.
No source component compiled, no dependency cache was created, and no package
or binary output exists. The patch applies cleanly and `git diff --check`
passes.

## Research status by area

| area | status | reason |
|---|---|---|
| local `core/` substitution | patch applied | experimental only; no Go tool |
| Go components | not built | Go and Make unavailable |
| Java components | not built | Java, Gradle, and Make unavailable |
| Debian packages | not built | dpkg-buildpackage unavailable |
| Python metadata | inspected in strict checkout | setup metadata commands succeeded |
| JavaScript assets | not reconstructed | no build reached; Phase 2 hashes retained as provenance only |
| ETCD bundle | not substituted | project-specific archive and scripts unavailable |

No reconstructed output is suitable for behavioral or deployment testing yet.
The checkout is suitable for a later tool-enabled build experiment, with the
patch and fixed commit providing traceability.
