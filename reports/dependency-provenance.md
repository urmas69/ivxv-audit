# IVXV Phase 2 dependency provenance

## 1. Executive summary

This report evaluates whether every external build input required by IVXV
commit `2785872f84dffb56bbecc41b096a7ee0f2876e64` can be independently
identified, obtained, and verified. The investigation was performed on
2026-07-23 UTC. Classification terms are used exactly as defined in the Phase 2
request.

The fixed source commit is publicly identifiable and is the peeled target of
the annotated release tag `v1.10.4-KOV2025`. Dependency provenance, however,
is incomplete. The build expects an unidentified external Git-LFS checkout;
the exact `tivi.io/core` module, ETCD deployment archive, and database scripts
cannot be reconstructed; several ecosystems lack locks; and no immutable OS
environment defines a bit-for-bit build.

Public infrastructure currently supplies most ordinary Go modules, Gradle
8.11, all 16 direct Maven artifacts, the documented Python releases, and most
named JavaScript upstream releases. This permits an approximation, not
verification of the historical offline build inputs. The Phase 2 result is
therefore that not every required external build input can be independently
identified, obtained, and verified.

## 2. Scope and methodology

The fixed Git tree, its complete locally available history, official and mirror
remote refs, build declarations, package metadata, and primary public
registries were examined. Network observations are timestamped and do not
imply availability before or after the recorded request. Downloaded objects
used as evidence are represented by URL, response metadata, size, and SHA-256;
large caches and build trees are excluded.

Repository facts are labelled as observations. Registry and upstream facts are
external observations. Conclusions that combine those facts are labelled as
inferences. Missing evidence is retained as an unresolved question rather than
silently replaced by a modern dependency.

Reusable commands are under `scripts/`; raw outputs are under
`evidence/command-logs/`; manifests are under
`evidence/dependency-manifests/`; download metadata and hashes are under
`evidence/hashes/`.

No complete IVXV build was run and the IVXV source worktree was not modified.

## 3. Environment and timestamps

- Investigation date: 2026-07-23 UTC.
- Audit repository: `/home/audit/audit/ivxv-audit`, branch `phase-2`.
- Evidence repository: `/home/audit/audit/ivxv`.
- Fixed commit: `2785872f84dffb56bbecc41b096a7ee0f2876e64`.
- Temporary processing root: `/tmp/ivxv-phase2`.
- Initial source state: fixed commit and empty porcelain status, recorded in
  `evidence/command-logs/01-start-source-state.txt`.

Each command log states its UTC time, working directory, shell-escaped command,
relevant locale/path environment, exit status, and combined output.

## 4. Repository and remote provenance

### Direct observations

At `2026-07-23T12:29:16Z`, `git ls-remote --symref` reported the official
`https://github.com/valimised/ivxv.git` default ref as `published`, with both
`HEAD` and `refs/heads/published` at the fixed commit. It advertised four
release tags:

| tag | tag object | peeled commit |
|---|---|---|
| `v1.10.4-KOV2025` | `7c3b9902471c92e9cfd20f10f9226ae5f8299de2` | `2785872f84dffb56bbecc41b096a7ee0f2876e64` |
| `v1.9.10-EP2024` | `6d572ede7626bfb6bad690d6374394d53ff2c701` | `023e072ad22b70f56b0b174789ea4ea349753ee6` |
| `v1.8.2-RK2023` | `cfacf6cda888aa46c809171acb106ee400b61509` | `8a432f7b8d4ed0bb0871f005f650c13bf3250766` |
| `v1.7.7-KOV2021` | `64d6ef255df947a3c7aa0fa52bd18b6f1408fdca` | `49160800174473502e0bee4c8fa87b7ec75bd6f6` |

The relevant advertised refs of `https://github.com/urmas69/ivxv.git` matched
the official branch and four tags exactly. The official remote additionally
advertised pull-request refs; these are review refs, not published build
branches. See `02-official-refs.txt`, `03-mirror-refs.txt`, and the canonical
repository-ref table `repository-provenance.tsv`.

The fixed commit records author and committer Sven Heiberg
`<sven@ivotingcentre.ee>`, timestamp `2025-10-03T12:55:32Z`, and subject
`KOV2025:`. Local ancestry verification establishes that EP2024 commit
`023e072…` is an ancestor. The official GitHub releases API returned an empty
array at the recorded time: tags exist, but no GitHub Release objects or
attached release assets were published through that interface.

The official `valimised` organization API listed `evalimine`,
`ivotingverification`, `intcheck`, `ios-ivotingverification`,
`wp-ivotingverification`, `ivxv`, `ivxv-mixnet-adapter`, and `crypto`.
This is a timestamped enumeration, not proof that other historical or private
repositories never existed.

### Inference

The source commit and its release-tag relationship are independently
verifiable from two public Git remotes. The absence of GitHub Release assets
means the GitHub Releases interface supplies no binary-to-source provenance for
KOV2025.

## 5. `common/external` history

The complete published history affecting the path has five commits:
`0032825` introduced `README.rst`; `9e36a72` documented Java offline
dependencies; `e5a6cea` added `install_java_dep`; `8a432f7` added LFS
attributes for `*.deb` and `*.jar`; and `023e072` deleted those files and left
an empty `.gitignore`.

No dependency binary, LFS pointer/OID, or submodule gitlink for this path
occurs in an object reachable from the supplied clone's refs. Historical
documentation describes a separate Git-LFS dependency repository, and
`make external` invokes `git submodule update --init`, but no matching
`.gitmodules` entry, URL, or gitlink revision is published. At KOV2021 commit
`4916080`, the path is an ordinary tree, not mode `160000`.

Thus `023e072` removed placeholder metadata—not dependency binaries stored in
the published parent history. The separately maintained dependency repository
is `not-reconstructable-from-published-information`; no published LFS OID is
available to test for object retention.

## 6. Go findings

The fixed tree has 15 `go.mod` and 13 `go.sum` files; every module declares Go
1.23. The deterministic manifest records 247 `require` occurrences. The sum
files contain 411 distinct module/version pairs, including historical residues
that are not current requirements. Relative `replace` directives make
`ivxv.ee/common/collector` and `ivxv.ee/sessionstatus/api` local inputs despite
their nominal `v1.9.11` requirements.

Published `go.sum` entries provide Go checksum-scheme verification for ordinary
public modules. The evidence run independently obtained proxy `.info`, `.mod`,
and `.zip` data for 139 declared occurrences and recorded object SHA-256
without retaining archives. The remaining 88 declared occurrences are
`not-tested`, not deemed unavailable. The audit host lacked the Go executable,
so `go mod verify` and independent recomputation of Go `h1:` values were not
possible; the script records this limitation.

### `tivi.io/core`

`common/collector/go.mod` and `voting/go.mod` require exact pseudo-version
`v0.2.2-0.20241127235149-149435f9e4f4` and publish matching ZIP and go.mod
`h1:` sums. All three exact-version Go proxy endpoints returned 404. The proxy
reported that vanity lookup targeted
`scceiv-public.gitlab-pages.ivotingcentre.ee/tivi.io-go-get-1`, whose DNS name
did not resolve. The pseudo-version commit is absent from the IVXV object
database.

The published root `core/` is itself module `tivi.io/core`; its README says to
use `GOPRIVATE='tivi.io'` and names branch `feature/crypto-api-2`. This supports
an inference that the original source was private. The local snapshot's
dependency versions differ from the parent graph, no `replace` connects it to
the two consumers, and no public history proves equivalence to pseudo-commit
`149435f9e4f4`. No license file was found under `core/`.

The exact pseudo-version is therefore
`not-reconstructable-from-published-information`. The root snapshot is public
as part of IVXV, but is not a proven substitute. A clean independent module
download could not obtain the required version at the observed time.

## 7. Gradle and Maven findings

`common/java/javavar.mk` requires
`common/external/gradle-8.11/bin/gradle` and uses `common/external/java/` as
Gradle user home. Neither exists in the fixed tree. Online configuration uses
Maven Central; ordinary builds request offline operation. There is no wrapper,
dependency lock, version catalog, or dependency-verification metadata. Java 21
is required by `common/java/common-build.gradle`.

The official Gradle 8.11 binary distribution remains public. Its observed
SHA-256,
`57dafb5c2622c6cc08b993c85b7c06956a2f53536432a30ead46166dbca0f1e9`,
matches the official checksum. IVXV identifies the version but publishes
neither that checksum nor a wrapper. Gradle signs source release tags; no
adjacent detached signature for the binary ZIP was established.

All 16 direct Maven POMs and JARs were available from Maven Central and were
hashed. A deps.dev secondary-evidence reconstruction records 103 distinct
coordinate/version nodes across the dependency graphs. It does not prove what
was present in the missing Gradle cache. The executable declarations use
Bouncy Castle 1.70 and JUnit 4.13.2, conflicting with documentation that names
1.78.1 and JUnit 5.10.0 respectively; build declarations govern.

Direct artifacts are `public-verifiable`; the complete absent offline cache is
`not-reconstructable-from-published-information` because dynamic metadata,
transitive selection, and cache contents are not locked or verified.

## 8. Python findings

`setup.py` names eleven requirements without version constraints and omits
Schematics despite its imports. The architecture documentation supplies exact
versions for ten non-setuptools requirements and Schematics 2.1.1, but no
setuptools version. These are documented versions, not `setup.py` pins.

Debian packaging expects `common/external/python/requirements.txt` and
`wheels/`, installs using `--no-index` and `--require-hash` with Python 3.10,
and preserves wheel hashes. Those inputs are absent from the fixed tree and
visible prior `common/external` content.

All eleven documented releases remain on PyPI; release filenames,
compatibility markers, upload times, and registry SHA-256 values are recorded.
The chosen wheels and all transitive versions remain unknown without the
missing hashed requirements file. Setuptools is
`not-reconstructable-from-published-information`. The other named releases are
publicly verifiable as upstream releases, but byte identity to the build's
missing wheels is not established.

## 9. JavaScript findings

Debian packaging expects unpacked SB Admin 2, Bootstrap, DataTables, Font
Awesome, and jQuery directories. HTML consumes those paths and SB Admin 2's
vendor tree. Architecture documentation identifies Bootstrap 3.4.1, jQuery
3.7.1, DataTables 2.3.2, Font Awesome 6.7.2, metisMenu 1.1.3, and SB Admin 2
3.3.7+1.

The first five releases and upstream SB Admin 2 3.3.7 remain public and their
npm tarballs were hashed without retention. `3.3.7+1` is a historical WebJar
release; the npm 3.3.7 tarball is not asserted byte-identical. No package or
lock manifest defines which files were unpacked, copied, or rebuilt.
Consequently upstream releases are identifiable, but the absent expected
static tree and bundled/minified file bytes cannot be reconstructed uniquely.

## 10. ETCD/database findings

Commit `023e072` first made packaging require
`ivxv-storage_db_install.sh`, `ivxv-storage_db_uninstall.sh`, and
`ivxv-storage_db.tar.gz` from `common/external/database/etcd`. In the same
change, packaging removed `etcd (>= 3.2.26)` and replaced system-service
handling with the missing custom scripts.

No version, content, URL, hash, signature, or license is published for any of
the three files. Official, mirror, and selected fork path queries found no
copies; those 404s establish only the exact timestamped requests. It is
reasonable to infer that the tarball was a deployment bundle rather than a
demonstrably pristine upstream distribution, but its actual contents remain
unknown. All three items are
`not-reconstructable-from-published-information`.

## 11. Operating-system environment findings

The fixed source identifies Ubuntu 22.04 LTS Jammy and `amd64` for service
packages (`all` for architecture-independent packages). The changelog records
Go 1.21, Python 3.10, Java 17, and debhelper 13 as 1.9.0 migration targets;
current build files separately require Go 1.23 and Java 21.

`debian/control` primarily specifies unbounded package relationships.
`debhelper-compat (= 13)` fixes a compatibility level, not an Ubuntu revision.
No APT sources, snapshot date, package lock, container/VM digest, CI
configuration, buildinfo/source package, or infrastructure-as-code definition
fixes the environment.

Jammy packages and historical snapshot services are public, but published
information does not select exact revisions. The OS dependencies are
`public-unpinned`, and a bit-identical package environment is not uniquely
reconstructable.

## 12. Related repositories and release artifacts

The related official-repository enumeration and official IVXV Releases API
response are recorded in `06-valimised-org-repositories.json` and
`07-official-releases.json`. Negative results apply only to the exact API
queries and retrieval time.

Official related repositories include `ivotingverification`,
`ios-ivotingverification`, `ivxv-mixnet-adapter`, `intcheck`, `crypto`, and
archived predecessor `evalimine`. None is identified by the IVXV tree as the
missing dependency bundle. Official tags provide GitHub-generated source
archives; the Releases API exposed no external caches, Debian packages, source
packages, SBOMs, checksums, or signed build manifests. Selected public fork
path checks likewise found no ETCD bundle.

## 13. Consolidated dependency classification

The canonical item-level record is
`evidence/dependency-manifests/dependency-provenance.csv`. Every row uses one
of: `public-verifiable`, `public-unpinned`, `public-historical-only`,
`uncertain-origin`, `apparently-internal`, `unavailable`, or
`not-reconstructable-from-published-information`.

The manifest has 380 deterministically ordered rows. Repeated Go module
requirements are intentionally retained per requiring component. Maven
transitives are deduplicated per coordinate/version after graph
reconstruction. Important aggregate classifications are:

| input class | classification | basis |
|---|---|---|
| ordinary proxy-verified Go modules | `public-verifiable` | pinned versions, published `go.sum`, proxy objects |
| untested Go declaration rows | `uncertain-origin` | partial evidence run; not treated as failed |
| exact `tivi.io/core` pseudo-version | `not-reconstructable-from-published-information` | proxy 404, failed vanity origin, no proven local equivalence |
| Gradle 8.11 | `public-verifiable` | official distribution and matching SHA-256 |
| direct Maven coordinates | `public-verifiable` | exact declarations and Maven Central objects |
| complete Gradle offline cache | `not-reconstructable-from-published-information` | no lock, verification metadata, or cache manifest |
| documented Python releases | `public-verifiable` | exact documentation and PyPI hashes; not proof of chosen wheels |
| Python wheel/transitive closure | `not-reconstructable-from-published-information` | missing hash-pinned requirements and wheel tree |
| documented JavaScript releases | public, chiefly `public-verifiable` | exact documentation and upstream registry objects |
| SB Admin `3.3.7+1` | `public-historical-only` | historical WebJar identity; current npm release is only 3.3.7 |
| unpacked JavaScript vendor tree | `not-reconstructable-from-published-information` | no package/lock/copy manifest |
| external Git-LFS repository | `not-reconstructable-from-published-information` | no URL, gitlink revision, or LFS OID |
| three ETCD/database files | `not-reconstructable-from-published-information` | no contents, version, source, or hash |
| Jammy/APT environment | `public-unpinned` | public package names but no snapshot or exact revisions |

An upstream artifact marked `public-verifiable` means that exact named upstream
release was obtained and hashed or authenticated by its ecosystem. It does not
assert byte identity with an absent copied cache or unpacked vendor tree.

## 14. Reproducibility implications

An independent party can reproduce the fixed Git tree identity and fetch a
large majority of conventional ecosystem artifacts. They cannot reproduce the
declared build input set exactly because:

1. the dependency checkout described by project documentation is unidentified;
2. two Go consumers require an inaccessible private-origin pseudo-version
   without a local replacement;
3. custom database install/uninstall scripts and archive are absent;
4. Gradle resolution is neither locked nor cryptographically verified by IVXV;
5. Python's expected hash-pinned wheel closure is absent;
6. JavaScript's unpacked/minified/fonts/plugins tree has no machine-readable
   lock or content manifest; and
7. Ubuntu packages and toolchains are not pinned to a snapshot or image.

Changing current registries into a successful build would select substitutes
or contemporary transitive metadata and would not establish the inputs used
for KOV2025. No published GitHub release binaries, signed manifest, SBOM,
buildinfo, or image digest closes the source-to-binary chain.

## 15. Unresolved questions

- What is the URL and exact revision of the separately maintained
  `common/external` Git-LFS repository?
- Were any LFS objects or dependency bundles published through a non-GitHub
  election distribution channel, and under what signed manifest?
- Is root `core/` intended to replace
  `tivi.io/core@v0.2.2-0.20241127235149-149435f9e4f4`; if so, which public
  commit proves equivalence and why is no `replace` directive present?
- What license applies to `core/` and the exact inaccessible pseudo-version?
- What are the contents, ETCD version, modifications, hashes, signatures, and
  licenses of the three database artifacts?
- Which exact Gradle transitive graph/cache metadata was used for KOV2025?
- What were the missing Python requirements hashes, chosen wheel filenames,
  setuptools version, and complete transitive closure?
- How was `common/external/js` assembled, especially SB Admin `3.3.7+1`,
  DataTables bundles, themes, plugins, fonts, and minified files?
- What immutable Ubuntu snapshot, package versions, build image, and toolchain
  produced the election artifacts?
- Where are the KOV2025 binary packages, source packages, checksums, signatures,
  SBOM, `.buildinfo`, and deployment hashes, if publicly available?

## 16. Phase 2 conclusion

Phase 2 is complete. Every identified class of build input has an item-level
classification or an explicit unresolved state in the canonical manifest.
Most conventional upstream packages are public, but the external bundle,
private-origin Go module, database payload, offline-cache selections, vendor
tree, and OS package snapshot prevent unique reconstruction of all required
inputs.

Therefore the fixed IVXV commit does **not** publish enough provenance to let
an independent party identify, obtain, and verify every external build input
or recreate the KOV2025 build environment bit-for-bit. This is a dependency
provenance and reproducibility conclusion only; it is not evidence about
election behavior or results.
