# Go dependency provenance findings

Observed 2026-07-23 UTC at IVXV commit
`2785872f84dffb56bbecc41b096a7ee0f2876e64`.

## Published dependency state

The tree contains 15 `go.mod` and 13 `go.sum` files. All modules declare Go
1.23. `declared-modules.tsv` records every `require` occurrence (247 rows,
including repetitions between components). The declarations pin versions,
including transitive requirements recorded as `// indirect`. The sum files
contain 411 distinct module/version pairs; many are historical graph residues
and are not requirements in the corresponding current `go.mod`.

All `ivxv.ee/common/collector` and `ivxv.ee/sessionstatus/api` requirements are
replaced by relative paths. Their nominal `v1.9.11` versions therefore are not
network inputs for this checkout. The relative replacements are published and
uniquely identify the local source used.

The host did not have the `go` executable, so `go mod verify` and calculation
of Go's `h1:` hashes from downloaded archives were not performed. The
reproducible script records this limitation, preserves published `h1:` values,
and independently downloads proxy `.info`, `.mod`, and `.zip` objects into a
temporary directory while recording HTTP status, final URL, size, and SHA-256.
The checked-in `proxy-artifacts.tsv` is a partial run stopped to meet the audit
handoff; 139 declared occurrences were verified through their proxy ZIP. Rows
marked `not-tested` must not be read as unavailable. No downloaded archive is
retained in this repository.

For ordinary public modules, declarations plus `go.sum` provide
content-addressed verification through the Go checksum scheme. Module ZIP
signatures are generally not separately published; SumDB authentication,
where available to the Go client, is the relevant transparency mechanism.
Licenses were not exhaustively extracted in this slice and remain to be
populated from the authoritative module archives.

## `tivi.io/core`

Direct observations:

* `common/collector/go.mod` and `voting/go.mod` require
  `tivi.io/core v0.2.2-0.20241127235149-149435f9e4f4`.
* Both sum files publish identical hashes:
  ZIP `h1:NgIyqKugpgiIia6wiRM6I9E1XStcitd1x8wIs0z75f8=` and go.mod
  `h1:iVb6IvZMOrl1JPCwSkeVv7sV7Cd9cDjmyCg4xOvRL+w=`.
* On 2026-07-23, all three exact-version Go proxy endpoints returned 404.
  The proxy diagnostic says the vanity import lookup redirects to
  `scceiv-public.gitlab-pages.ivotingcentre.ee/tivi.io-go-get-1`, whose DNS
  name did not resolve.
* `https://tivi.io/` itself resolved and returned HTTP 200, but the required
  module path did not yield retrievable VCS metadata through the Go proxy.
* Pseudo-version commit prefix `149435f9e4f4` is not an object in the
  investigated IVXV Git object database.
* The repository nevertheless publishes a root `core/` module with module
  identity `tivi.io/core`, Go 1.23, and a README naming it “TIVI Core Go
  library.” That README instructs use of `GOPRIVATE='tivi.io'` and branch
  `feature/crypto-api-2`, strong evidence that its original source was treated
  as private.
* The fixed IVXV commit is a single observed snapshot for `core/`; public Git
  history available in this checkout does not establish that its content is
  byte-equivalent to pseudo-version commit `149435f9e4f4`. The local module's
  dependency versions also differ from the versions selected in the parent
  collector graph. There is no license file under `core/`.

Conservative classification: the exact pseudo-version is
`not-reconstructable-from-published-information`. The published local `core/`
snapshot is identifiable, but equivalence to the required pseudo-version,
original repository history, authorship chain, and license cannot be proven
from current public evidence. A clean independent module download cannot
obtain the exact required version from `proxy.golang.org` at the recorded
time.

## Reproducibility impact

The ordinary pinned modules appear reconstructable from public Go
infrastructure, subject to completing the scripted verification. Local
`replace` directives make IVXV's two internal module dependencies
self-contained. `tivi.io/core` is the material exception: builds of components
that import it may succeed only if the published root `core/` is wired in by
an external workspace/build rule, or if a private cache/source is supplied.
Neither substitution nor source equivalence is declared in the affected
`go.mod` files, so the exact dependency graph is not independently
reconstructable from the published module metadata alone.
