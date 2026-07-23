# `common/external`, ETCD, OS, and release provenance findings

Observed at `2026-07-23` UTC unless an evidence log gives a more precise time.

## `common/external`

- Direct observation: the complete published Git history affecting this path has
  five commits: `003282512343a08ec88ab547d4b1a8e83ac9369d` (introduced
  `README.rst`), `9e36a72aaec7c6bf4602310aa6f346e5c128e68a` (documented
  Java offline dependencies), `e5a6ceafc8fa373f79ff0a72b8e7ff62c731d84e`
  (added `install_java_dep`), `8a432f7b8d4ed0bb0871f005f650c13bf3250766`
  (added LFS attributes for `*.deb` and `*.jar`), and
  `023e072ad22b70f56b0b174789ea4ea349753ee6` (deleted all except an
  emptied `.gitignore`).
- Direct observation: no `.deb`, `.jar`, database bundle, Gradle archive, LFS
  pointer, or Git submodule gitlink for this path occurs in any object reachable
  from the refs in the supplied clone. The only historical LFS evidence is the
  attribute rule. Consequently there are no published LFS OIDs to retrieve.
- Direct observation: historical root documentation says this was a separate
  Git-LFS dependency repository and `make external` ran `git submodule update
  --init`. However, no matching `.gitmodules` entry, repository URL, or gitlink
  object was published. At `49160800174473502e0bee4c8fa87b7ec75bd6f6`,
  `common/external` is an ordinary tree (`040000 tree`), not mode `160000`.
- Inference: the published tree appears to be a sanitized placeholder for a
  separately maintained dependency checkout. Its identity and pinned revision
  are not reconstructable from published information.
- Direct observation: `023e072` removed only `.gitattributes`, `README.rst`,
  and `install_java_dep`, and emptied `.gitignore`; it did not delete dependency
  binaries from the published parent repository because those binaries were
  never present in its reachable history.

## ETCD/database artifacts

- Direct observation: commit `023e072` first made the Debian build copy
  `ivxv-storage_db_install.sh`, `ivxv-storage_db_uninstall.sh`, and
  `ivxv-storage_db.tar.gz` from `common/external/database/etcd`.
- Direct observation: the same commit removed the package dependency
  `etcd (>= 3.2.26)` and changed maintainer scripts from stopping/masking the
  system ETCD service to invoking the missing install/uninstall scripts.
- Historical external statement in the changelog: IVXV 1.7.2 used Ubuntu
  ETCD `>= 3.2.26`; earlier releases used Debian buster ETCD for a newer gRPC
  build. This does not identify the new archive.
- Inference: the archive is likely a deployment bundle, not demonstrably an
  unmodified upstream ETCD distribution. The custom wrapper scripts and removal
  of the OS package dependency support this inference, but the archive contents
  are unavailable, so its version and modifications remain unresolved.
- External observation: GitHub API path checks on the official mirror and
  selected forks returned HTTP 404. This proves only that the queried paths
  were absent at retrieval time. The official repository and mirror expose no
  GitHub Releases.

## Operating-system build environment

- Direct observation: the fixed commit states Ubuntu 22.04 LTS (Jammy
  Jellyfish) and Debian package architecture `amd64` for service packages
  (`all` for architecture-independent packages). The changelog states Go 1.21,
  Python 3.10, Java 17, and debhelper 13 as the 1.9.0 migration targets.
- Direct observation: `debian/control` lists package names and mostly unbounded
  version relationships. Only `debhelper-compat (= 13)` is exact at the
  compatibility-level declaration; it is not an exact Ubuntu package revision.
- Direct observation: no Dockerfile/Containerfile, CI workflow, build VM/image
  digest, APT sources file, snapshot timestamp, package lock, `buildinfo`,
  source package, or infrastructure-as-code definition fixes the host packages.
- Conclusion: Jammy package archives are public and historical snapshots can
  supply chosen revisions, but the published inputs do not uniquely choose
  them. A bit-for-bit OS/package build environment is therefore not
  reconstructable from the repository alone.

## Related repositories and releases

- External observation: `valimised/ivxv` and `urmas69/ivxv` resolve their
  `published` branch and `v1.10.4-KOV2025` tag to the fixed commit. Their
  advertised refs are captured in the command log.
- External observation: the official organization publishes related
  repositories including `ivotingverification`, `ios-ivotingverification`,
  `ivxv-mixnet-adapter`, `intcheck`, `crypto`, and the archived predecessor
  `evalimine`. None is identified by IVXV as the missing external bundle.
- External observation: the GitHub Releases API returned an empty array for
  the official IVXV repository. Tags provide Git source archives, not external
  caches, Debian packages, SBOMs, checksums, or signed release assets.
- Unresolved: public election-web downloads outside GitHub may contain binaries
  or hashes, but no discovered primary-source publication links them to the
  missing build bundle.

Raw evidence: `evidence/command-logs/30-common-external-etcd-os.txt` and
`evidence/command-logs/31-related-repositories.txt`.
