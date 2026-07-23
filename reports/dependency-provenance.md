# IVXV Phase 2 dependency provenance

## 1. Executive summary

This report evaluates whether every external build input required by IVXV
commit `2785872f84dffb56bbecc41b096a7ee0f2876e64` can be independently
identified, obtained, and verified. The investigation was performed on
2026-07-23 UTC. Classification terms are used exactly as defined in the Phase 2
request.

The fixed source commit is publicly identifiable and is the peeled target of
the signed-or-annotated release tag `v1.10.4-KOV2025`. Dependency provenance,
however, is incomplete: the build expects an unpublished `common/external`
layout, several ecosystems are not fully pinned, and no published immutable OS
package environment uniquely defines a bit-for-bit build.

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

_Findings are consolidated below after history and object-availability checks._

## 6. Go findings

_Findings are consolidated below from the Go module manifest and verification
logs._

## 7. Gradle and Maven findings

_Findings are consolidated below from Gradle distribution and Maven artifact
checks._

## 8. Python findings

_Findings are consolidated below from declarations, packaging history, and
PyPI metadata._

## 9. JavaScript findings

_Findings are consolidated below from expected static paths, historical
content, and upstream distributions._

## 10. ETCD/database findings

_Findings are consolidated below from history, packaging, documentation, and
public artifact searches._

## 11. Operating-system environment findings

_Findings are consolidated below from package, image, and CI declarations._

## 12. Related repositories and release artifacts

The related official-repository enumeration and official IVXV Releases API
response are recorded in `06-valimised-org-repositories.json` and
`07-official-releases.json`. Negative results apply only to the exact API
queries and retrieval time.

## 13. Consolidated dependency classification

The canonical item-level record is
`evidence/dependency-manifests/dependency-provenance.csv`. Every row uses one
of: `public-verifiable`, `public-unpinned`, `public-historical-only`,
`uncertain-origin`, `apparently-internal`, `unavailable`, or
`not-reconstructable-from-published-information`.

## 14. Reproducibility implications

_Consolidated after ecosystem reconciliation._

## 15. Unresolved questions

_Consolidated after ecosystem reconciliation._

## 16. Phase 2 conclusion

_Final conclusion pending completion and cross-check of all ecosystem
manifests._
