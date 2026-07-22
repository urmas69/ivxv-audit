# IVXV Build Investigation — Initial Inventory

Recorded: 2026-07-21 14:31:52 UTC  
Commit under review: `2785872f84dffb56bbecc41b096a7ee0f2876e64`  
Source repository: `/home/audit/audit/ivxv`  
Scope: read-only inventory only; no build, download, network access, installation, or system change.

## 1. Initial inventory

### 1.1 Audit host

- Hostname: `ivxv-audit`
- Local/UTC time: `2026-07-21T14:31:52+00:00`
- Operating system: Ubuntu 22.04.5 LTS (Jammy), x86-64
- Kernel: `Linux 6.8.0-134-generic #134~22.04.1-Ubuntu SMP PREEMPT_DYNAMIC Tue Jun 30 14:05:04 UTC`
- Available locally: Python 3.10.12 and Git LFS 3.0.2.
- Not found in `PATH`: `make`, `go`, `java`, `javac`, `gradle`, `pip3`, `dpkg-buildpackage`, `debuild`, `dh`, `docker`, `sphinx-build`, and `plantuml`.
- The hard-coded Go path `/usr/lib/go-1.23/bin/go` is also absent.

### 1.2 Git state and commit identity

- `HEAD` is detached and points exactly to the commit under review.
- The working tree and index were clean and unchanged before and after the investigation.
- Commit author and committer: Sven Heiberg `<sven@ivotingcentre.ee>`; date `2025-10-03 12:55:32 +0000`; subject `KOV2025:`.
- Remotes:
  - `origin`: `https://github.com/urmas69/ivxv.git`
  - `upstream`: `https://github.com/valimised/ivxv.git`
- The locally available tracking refs `origin/published`, `upstream/published`, and `origin/HEAD` all point to the identical commit object `2785872f84dffb56bbecc41b096a7ee0f2876e64`.
- This proves identity only for the **locally stored remote-tracking refs**. It does not assert that the server-side refs still had the same value on the audit date. A network `git fetch` or remote `git ls-remote` required prior approval and was not performed.

### 1.3 Git LFS, attributes, ignore rules, and submodules

- Git LFS is configured system-wide as a required filter. Its endpoints would be the respective `origin` and `upstream` LFS endpoints.
- `git lfs ls-files --all` and a search for the LFS pointer header found no LFS files in the published history or review tree.
- No root `.gitattributes` file exists at the reviewed commit, so no LFS paths are declared there.
- Historically, `common/external/.gitattributes` applied LFS rules to `*.deb` and `*.jar`. That file, along with `README.rst` and `install_java_dep`, was deleted in commit `023e072...` dated 2024-05-30. The reviewed commit retains only an empty `common/external/.gitignore`.
- Root `.gitignore` covers `*.swp`, `*.pyc`, generated Go files, `__pycache__`, `.idea`, root `build`, `dist`, `.pybuild`, and two admin build paths. It does not ignore `common/external` as a whole.
- `.gitmodules` declares only `Documentation/public/liidesed/VIS3-EHS`, URL `https://github.com/e-gov/VIS3-EHS.git`, branch `feature/tervikdokument`.
- The reviewed tree contains **no Gitlinks at all** (mode `160000`). The path declared by `.gitmodules` is absent as well. The `.gitmodules` entry is therefore orphaned.
- `make external` only executes `git submodule update --init`. With no Gitlink present, this target can retrieve neither `VIS3-EHS` nor `common/external`.

### 1.4 `common/external`

- Git object type: ordinary `tree`, object ID `82e3a754b6a0fcb238b03c0e47d05219fbf9cf89`.
- Its only entry is `100644 blob e69de29... common/external/.gitignore`, size 0 bytes.
- `common/external` is **not a submodule/Gitlink**.
- Expected but absent paths:
  - `common/external/go`
  - `common/external/gradle-8.11`
  - `common/external/java`
  - `common/external/python`
  - `common/external/js`
  - `common/external/database`
  - `common/external/schematics`
- All searches for code intended to create or populate these paths found only:
  - the ineffective root `external` and `update-external` targets,
  - auditor documentation for manually downloading Gradle 8.11,
  - a **historically deleted** Gradle 6.4 helper script.
- The reviewed commit contains no script, manifest, lockfile, or hash inventory capable of producing or verifying the complete contents of `common/external`.

### 1.5 Makefiles and build entry points

Complete Make/include-file inventory from `git ls-tree`:

```text
Documentation/Makefile
Documentation/common-model.mk
Documentation/common.mk
Documentation/common/schema/Makefile
Documentation/en/backendlogs/Makefile
Documentation/et/audiitor/Makefile
Documentation/et/haldusteenus/Makefile
Documentation/et/kasutusmall/Makefile
Documentation/et/kogumisteenuse_haldusjuhend/Makefile
Documentation/et/seadistuste_koostejuhend/Makefile
Documentation/et/votmerakendus/Makefile
Documentation/et/xteeteenus/Makefile
Documentation/et/xteeteenus/model/Makefile
Documentation/public/arhitektuur/Makefile
Documentation/public/arhitektuur/model/Makefile
Documentation/public/liidesed/Makefile
Documentation/public/protokollid/Makefile
Documentation/public/protokollid/model/Makefile
Documentation/public/uldsisukord/Makefile
Makefile
auditor/Makefile
choices/Makefile
collector-admin/Makefile
common/collector/Makefile
common/collector/config/Makefile
common/collector/scripts/Makefile
common/go/common.mk
common/go/govar.mk
common/java/Makefile
common/java/common.mk
common/java/javavar.mk
common/tools/go/Makefile
common/tools/win32/entropy/Makefile
core/Makefile
core/cmd/errorgen/Makefile
core/govar.mk
key/Makefile
mid/Makefile
processor/Makefile
proxy/Makefile
sessionstatus/Makefile
sessionstatus/api/Makefile
smartid/Makefile
storage/Makefile
systemd/Makefile
verification/Makefile
votesorder/Makefile
voting/Makefile
webeid/Makefile
xroad-service/Makefile
```

Important entry points:

- Root: `all`, `java`, `go`, component targets, `test`, `install`, `clean`, `release-doc`, `external`, `update-external`, `version`, and `%-dev`.
- Root `all`: Java directories `common/java key processor auditor`; Go directories `common/collector sessionstatus/api proxy mid smartid choices voting verification storage votesorder webeid sessionstatus`; plus `systemd Documentation`.
- Standard Go path: `go mod tidy`, build the generator, `go generate`, run the custom generator, then `go install`. This is not read-only and can alter generated/tracked files and `go.mod`/`go.sum`.
- Standard Java path: run `common/external/gradle-8.11/bin/gradle build installDist`, using `--offline` by default and cache `common/external/java/`.
- Debian: `debian/rules` invokes `make go`, Pybuild, and the storage database payload during installation.
- `xroad-service` is not included in root `GODIRS`; its own target additionally requires `goreleaser`.
- The root Makefile references `tests` in `test-python`/`clean` and `release` in `clean`; both directories are absent. No root `release` target exists.

### 1.6 Go requirements

- All 15 published `go.mod` files declare `go 1.23`: `choices`, `common/collector`, `common/tools/go`, `core`, `mid`, `proxy`, `sessionstatus/api`, `sessionstatus`, `smartid`, `storage`, `verification`, `votesorder`, `voting`, `webeid`, and `xroad-service`.
- `common/go/govar.mk` and `core/govar.mk` prefer `/usr/lib/go-1.23/bin/go` and accept a fallback Go version only if it is at least 1.23.
- The root README instead claims Go 1.9 and package `golang-1.9-go`; this is obsolete and conflicts with the manifests.
- Offline mode is the default: `GOMODCACHE=common/external/go`, `GOPROXY=file://.../common/external/go/cache/download`, and `GOSUMDB=off`. That cache is entirely absent.
- Setting `ONLINE` suppresses the local `GOPROXY` assignment, allowing module downloads through the external Go configuration, normally a public Go proxy or module origins. `go.sum` fixes content checksums, but the commit does not contain the archives.
- External module namespaces include `github.com/*`, `go.etcd.io/*`, `go.uber.org/*`, `golang.org/x/*`, `google.golang.org/*`, `gopkg.in/yaml.v3`, and `tivi.io/core`.
- Of particular note, `common/collector` and `voting` require an external pseudo-version of `tivi.io/core`, even though source code is also published in root `core/`; there is no `replace` directive pointing to that local source. Root `core` is also absent from `GODIRS`.

### 1.7 Java and Gradle

- Actual Java source compatibility: Java 21 (`JavaVersion.VERSION_21`).
- The root README and auditor installation documentation specify Java/OpenJDK 11, conflicting with the current Gradle configuration.
- Required Gradle distribution: 8.11 at `common/external/gradle-8.11/bin/gradle`.
- Documented source: `https://services.gradle.org/distributions/gradle-8.11-bin.zip`.
- The repository contains neither a wrapper (`gradlew`, `gradle-wrapper.properties`, wrapper JAR) nor a checksum/signature for this ZIP.
- Maven source: `mavenCentral()`. Offline cache: unpublished `common/external/java/`.
- Direct Java dependencies are versioned in `common/java/build.gradle`, including Jackson 2.18.1, PDFBox 3.0.3, BouncyCastle 1.70, digidoc4j 5.3.1, Logback 1.5.12, SnakeYAML 2.3, JAXB 4.0.5, JUnit 4.13.2, and Mockito 5.14.2. No Gradle lockfile or published complete transitive cache/hash inventory exists.

### 1.8 Python

- `setup.py` requires, without version constraints: `bottle`, `docopt`, `jinja2`, `jsonschema`, `pyopenssl`, `fasteners`, `python-crontab`, `python-dateutil`, `python-debian`, `pyyaml`, and `setuptools`.
- The Debian package path instead expects a complete offline hashed wheel set at `common/external/python/wheels` plus `common/external/python/requirements.txt`; both are absent.
- `debian/python3-ivxv-common.postinst` invokes `pip3 --no-index --require-hash` against that cache.
- `collector-admin/Makefile` additionally expects `pylint3` and `common/external/schematics`; the latter is absent.
- `Documentation/podl/requirements.txt` says it was generated with Python 3.10/pip-compile and pins its own documentation tools, but contains no hashes.

### 1.9 Debian packaging and release

- `debian/control` build dependencies: `debhelper-compat (=13)`, `dh-exec`, `dh-python`, `python3-all`, `python3-debian`, and `python3-setuptools`.
- Binary/runtime packages: `ivxv-common`, `python3-ivxv-common`, `ivxv-admin`, `ivxv-proxy`, `ivxv-choices`, `ivxv-verification`, `ivxv-voting`, `ivxv-storage`, `ivxv-mid`, `ivxv-smartid`, `ivxv-webeid`, `ivxv-log`, `ivxv-backup`, `ivxv-votesorder`, and `ivxv-sessionstatus`.
- Present: `debian/rules`, `control`, `changelog`, `.install` files, systemd, cron, lintian, and numerous `postinst`/`postrm`/`prerm` scripts.
- Packaging references missing external content:
  - Python wheels and requirements,
  - JavaScript: SB Admin 2, Bootstrap, DataTables, Font Awesome, JQuery,
  - storage: `common/external/database/etcd/{ivxv-storage_db_install.sh,ivxv-storage_db_uninstall.sh,ivxv-storage_db.tar.gz}`.
- The root README mentions `dpkg-buildpackage`/`debuild`; neither is installed locally. Active Ubuntu sources are moving Jammy, updates, backports, and security suites from `de.archive.ubuntu.com` and `security.ubuntu.com`, without a snapshot date. Even after installing tools, the package environment would not be bit-reproducible.
- The README names `make release`, but both the target and referenced `release/` directory are absent.

### 1.10 CI configuration

- No conventional CI configuration was found: no `.github/workflows`, `.gitlab-ci.yml`, Travis, CircleCI, Jenkins, Azure Pipelines, or Buildkite files.
- The published commit therefore provides no machine-readable reference environment authoritatively defining toolchains, acquisition, or build order.

### 1.11 External network and package sources

Build-relevant or explicitly documented sources:

- Git remotes: GitHub `urmas69/ivxv` and `valimised/ivxv`.
- Orphaned submodule: `https://github.com/e-gov/VIS3-EHS.git`.
- Gradle distribution: `https://services.gradle.org/distributions/gradle-8.11-bin.zip`, without a repository-published hash.
- Java artifacts: Maven Central through Gradle.
- Go artifacts: only the absent local proxy cache in offline mode; external Go proxies/module origins for the namespaces above in online mode.
- Python: only absent local wheels in the intended Debian path. Reconstruction would require an external Python index or other artifact source not specified by the commit.
- Ubuntu packages: `http://de.archive.ubuntu.com/ubuntu/` and `http://security.ubuntu.com/ubuntu/`, moving Jammy suites without a snapshot.
- Auditor/mixnet documentation also names GitHub downloads/clones for `vvk-ehk/intcheck`, `vvk-ehk/ivxv`, `vvk-ehk/ivxv-mixnet-adapter`, `verificatum/verificatum-gmpmee`, `verificatum/vmgj`, `verificatum/vcr`, and `verificatum/vmn`. These are not part of the root collector build, but are external steps in the published audit/mixnet instructions and sometimes use the moving `master` branch rather than a commit.

**No external network access or download occurred during this inventory.**

### 1.12 Conflicts between the README and the actual build system

1. README: Go 1.9; Makefiles and every `go.mod`: Go >= 1.23.
2. README: Java 11; Gradle configuration: Java source compatibility 21.
3. README: `common/external` is a Git LFS submodule; in fact it is an ordinary tree containing one empty file, with no LFS pointer and no `.gitmodules` entry.
4. README: `make external` downloads the external dependency repository; it actually runs only a no-op submodule command because there are no Gitlinks.
5. README: an offline copy contains external dependencies; the published commit does not.
6. README: `make release`; this target and directory are absent.
7. Root Makefile expects `tests` and `release`; both are absent.
8. Historical External documentation expected Go sources under `gopath/src`; the current build expects a module proxy cache under `common/external/go/cache/download`.

## 2. Missing prerequisites

### On the local audit host

- GNU Make
- Go >= 1.23, preferably `/usr/lib/go-1.23/bin/go`
- JDK 21
- Gradle 8.11 or its complete distribution
- `pip3` and Debian build tooling (`dpkg-buildpackage`, `debhelper`/`dh`, `dh-exec`, `dh-python`, `python3-all`, `python3-debian`, `python3-setuptools`)
- Depending on the target: `goreleaser`, `golangci-lint`, Sphinx/LaTeX/PlantUML, and other documentation tools

### In the published repository or a defined artifact delivery

- complete Go module proxy cache `common/external/go`
- Gradle 8.11 with a verifiable vendor checksum
- complete Gradle/Maven offline cache `common/external/java`
- hashed Python requirements and every wheel
- JavaScript vendor trees
- ETCD storage installation scripts and database archive
- `common/external/schematics`
- a Gitlink/commit for declared `VIS3-EHS`, or removal/correction of the orphaned declaration
- missing `tests/` and `release/` content, or corrected Make/README targets
- machine-readable artifact manifest containing sources, versions, hashes, and licenses
- fixed OS/package sources (snapshot) and a documented build image

## 3. External or unpublished dependencies

1. All content under `common/external/{go,gradle-8.11,java,python,js,database,schematics}`.
2. Go modules from GitHub, Go, Google, Uber, ETCD, gopkg, and `tivi.io` namespaces; especially externally fetched `tivi.io/core` despite the separately published and unused root `core/`.
3. Maven Central artifacts, including transitive dependencies.
4. Unpinned Python dependencies declared in `setup.py`; all Debian-intended wheels are absent.
5. Gradle 8.11 distribution without a checksum anchored in the commit.
6. JavaScript vendor libraries and ETCD storage payload.
7. OS/build packages from non-snapshotted Ubuntu repositories.
8. GitHub-hosted documentation/audit side projects, some referenced only by `master`.

## 4. Reproducibility assessment

**Conclusion: this commit cannot be reproducibly built from the published repository alone.**

Even a functional offline build is impossible because the explicitly required offline caches and binary/vendor artifacts are missing. `make external` cannot retrieve them. An online build might retrieve part of the Go and Maven dependency sets, but without a complete hashed artifact manifest, Python/JavaScript/database sources, a Gradle checksum, an OS snapshot, and a defined toolchain, it would be neither complete nor reproducible. Published instructions and Make targets are also stale or reference absent paths.

The existing `go.sum` files improve Go-module integrity checking, but do not solve offline availability, the external `tivi.io/core` pseudo-version, the other ecosystems, or the build environment. Java has no dependency locking, and Python requirements in `setup.py` are unpinned. Therefore, even improvised online acquisition would not be expected to produce a bit-identical build.

## 5. Minimal installation and build plan — not executed

Separate explicit approval is required before every download, installation, or system change.

1. Request from the publisher the complete `common/external` delivery corresponding to this commit and a signed/hashed artifact manifest; verify the source and SHA-256 of each artifact. Without that delivery, the intended offline build path cannot be reconstructed.
2. After approval, verify current remote state read-only with `git ls-remote`/`git fetch` and record commit/ref identity. Do not accept moving branches as build inputs.
3. Define an isolated, pinned Ubuntu 22.04 build environment using snapshot package sources. Install at minimum Make, Go 1.23, JDK 21, Debian tooling, and only the documentation tools required for selected targets.
4. Supply Gradle 8.11 only after checking an authoritative SHA-256. Import Maven, Go, and Python artifacts into controlled offline caches and archive a complete inventory.
5. In a separate working copy that does not alter the reviewed sources, first perform manifest completeness checks, `go mod verify`, offline resolution for Go/Maven/Python, Make dry runs, and determine whether `go mod tidy` creates diffs.
6. Obtain publisher-confirmed build instructions resolving the missing or stale `tests`, `release`, `external`, orphaned submodule, and `core` behavior before a full build.
7. Only after further explicit approval, run component builds in isolated build directories and record all commands, environment variables, inputs, outputs, hashes, and exit codes. Do not use `ivxv-build-a` or `ivxv-build-b` unless the explicit prohibition is lifted.

## 6. Continuous command log

All commands below ran in `/home/audit/audit/ivxv`. Semicolon-combined queries are reproduced as the complete shell commands actually executed. If a combined command contained an expected partial failure, this is stated explicitly; the overall shell exit status may be 0 because of its last command.

### P01 — System information

**Command**

```sh
date --iso-8601=seconds; date -u --iso-8601=seconds; hostname; uname -a; if [ -r /etc/os-release ]; then cat /etc/os-release; fi
```

**Output**

```text
2026-07-21T14:31:52+00:00
2026-07-21T14:31:52+00:00
ivxv-audit
Linux ivxv-audit 6.8.0-134-generic #134~22.04.1-Ubuntu SMP PREEMPT_DYNAMIC Tue Jun 30 14:05:04 UTC x86_64 x86_64 x86_64 GNU/Linux
PRETTY_NAME="Ubuntu 22.04.5 LTS"
NAME="Ubuntu"
VERSION_ID="22.04"
VERSION="22.04.5 LTS (Jammy Jellyfish)"
VERSION_CODENAME=jammy
ID=ubuntu
ID_LIKE=debian
UBUNTU_CODENAME=jammy
```

**Exit code:** 0.  
**Technical conclusion:** Time, host, kernel, architecture, and OS are recorded.

### P02 — Commit, status, and remotes

**Command**

```sh
git rev-parse HEAD; git rev-parse 2785872f84dffb56bbecc41b096a7ee0f2876e64^{commit}; git show -s --format=fuller 2785872f84dffb56bbecc41b096a7ee0f2876e64; git status --short --branch; git remote -v
```

**Output**

```text
2785872f84dffb56bbecc41b096a7ee0f2876e64
2785872f84dffb56bbecc41b096a7ee0f2876e64
commit 2785872f84dffb56bbecc41b096a7ee0f2876e64
Author:     Sven Heiberg <sven@ivotingcentre.ee>
AuthorDate: Fri Oct 3 12:55:32 2025 +0000
Commit:     Sven Heiberg <sven@ivotingcentre.ee>
CommitDate: Fri Oct 3 12:55:32 2025 +0000

    KOV2025:
## HEAD (no branch)
origin   https://github.com/urmas69/ivxv.git (fetch)
origin   https://github.com/urmas69/ivxv.git (push)
upstream https://github.com/valimised/ivxv.git (fetch)
upstream https://github.com/valimised/ivxv.git (push)
```

**Exit code:** 0.  
**Technical conclusion:** Detached HEAD exactly matches the reviewed commit; no changes are reported.

### P03 — Locally stored remote refs

**Command**

```sh
git for-each-ref --format='%(refname) %(objectname)' refs/remotes/origin refs/remotes/upstream; git branch -r --contains 2785872f84dffb56bbecc41b096a7ee0f2876e64; git ls-remote --get-url origin; git ls-remote --get-url upstream
```

**Output**

```text
refs/remotes/origin/HEAD 2785872f84dffb56bbecc41b096a7ee0f2876e64
refs/remotes/origin/published 2785872f84dffb56bbecc41b096a7ee0f2876e64
refs/remotes/upstream/published 2785872f84dffb56bbecc41b096a7ee0f2876e64
  origin/HEAD -> origin/published
  origin/published
  upstream/published
https://github.com/urmas69/ivxv.git
https://github.com/valimised/ivxv.git
```

**Exit code:** 0.  
**Technical conclusion:** Both locally stored `published` refs are identical. `--get-url` reads configuration only and made no network request.

### P04 — LFS configuration and references

**Commands**

```sh
git lfs version; git lfs env; git config --show-origin --get-regexp '^(lfs\.|filter\.lfs\.)'
git lfs ls-files --all; git grep -Il '^version https://git-lfs.github.com/spec/v1$' 2785872f84dffb56bbecc41b096a7ee0f2876e64 -- .
```

**Output — complete material values**

```text
git-lfs/3.0.2 (GitHub; linux amd64; go 1.18.1)
Endpoint=https://github.com/urmas69/ivxv.git/info/lfs (auth=none)
Endpoint (upstream)=https://github.com/valimised/ivxv.git/info/lfs (auth=none)
LocalMediaDir=/home/audit/audit/ivxv/.git/lfs/objects
AccessDownload=none
AccessUpload=none
filter.lfs.clean=git-lfs clean -- %f
filter.lfs.smudge=git-lfs smudge -- %f
filter.lfs.process=git-lfs filter-process
filter.lfs.required=true
[second command: no output]
```

**Exit codes:** first command 0; second combined command 1 because no matches were found.  
**Technical conclusion:** LFS is configured, but there are no published LFS references.

### P05 — `.gitmodules`, Gitlinks, and `common/external`

**Commands**

```sh
git show 2785872f84dffb56bbecc41b096a7ee0f2876e64:.gitmodules; git ls-tree -r 2785872f84dffb56bbecc41b096a7ee0f2876e64 | awk '$1 == "160000" {print}'
git ls-tree 2785872f84dffb56bbecc41b096a7ee0f2876e64 common/external; git cat-file -t 2785872f84dffb56bbecc41b096a7ee0f2876e64:common/external; git cat-file -p 2785872f84dffb56bbecc41b096a7ee0f2876e64:common/external
```

**Output**

```text
[submodule "Documentation/public/liidesed/VIS3-EHS"]
  path = Documentation/public/liidesed/VIS3-EHS
  url = https://github.com/e-gov/VIS3-EHS.git
  branch = feature/tervikdokument
[no Gitlink lines]
040000 tree 82e3a754b6a0fcb238b03c0e47d05219fbf9cf89 common/external
tree
100644 blob e69de29bb2d1d6434b8b29ae775ad8c2e48c5391 .gitignore
```

**Exit codes:** 0 and 0.  
**Technical conclusion:** There are no Gitlinks; External is an ordinary tree containing exactly one empty file.

### P06 — Attributes and ignore rules

**Commands**

```sh
git cat-file -e 2785872f84dffb56bbecc41b096a7ee0f2876e64:.gitattributes
git show 2785872f84dffb56bbecc41b096a7ee0f2876e64:.gitignore
git check-attr -a -- . common/external/.gitignore
```

**Output**

```text
fatal: Not a valid object name 2785872f84dffb56bbecc41b096a7ee0f2876e64:.gitattributes
*.swp
*.pyc
gen_types.go
gen_types_test.go
gen_import.go
gen_import_dev.go
__pycache__
.idea

# ivxv-admin
/build
/dist
/.pybuild
/collector-admin/IVXVCollectorAdminDaemon.egg-info
[git check-attr: no output]
```

**Exit codes:** 128, 0, 0.  
**Technical conclusion:** There are no root attributes/LFS rules; ignore rules do not account for the missing External content.

### P07 — Build file and CI inventory

**Commands**

```sh
git ls-tree -r --name-only 2785872f84dffb56bbecc41b096a7ee0f2876e64 | rg '(^|/)(GNUmakefile|[Mm]akefile([^/]*)?|[^/]*\.mk)$'
git ls-tree -r --name-only 2785872f84dffb56bbecc41b096a7ee0f2876e64 | rg '(^|/)(\.github|\.gitlab|\.circleci|ci|CI)(/|$)|(^|/)(Jenkinsfile|\.travis\.yml|azure-pipelines\.yml|buildkite\.yml)$'
```

**Output:** the first command produced the complete list in section 1.5; the second produced no output.  
**Exit codes:** 0 and 1.  
**Technical conclusion:** Make inventory is complete; no CI configuration was found.

### P08 — Go versions and offline configuration

**Command**

```sh
git show 2785872f84dffb56bbecc41b096a7ee0f2876e64:common/go/govar.mk; git show 2785872f84dffb56bbecc41b096a7ee0f2876e64:core/govar.mk; for f in $(git ls-tree -r --name-only 2785872f84dffb56bbecc41b096a7ee0f2876e64 | rg '(^|/)go\.mod$'); do printf '\nFILE %s\n' "$f"; git show "2785872f84dffb56bbecc41b096a7ee0f2876e64:$f" | sed -n '1,4p'; done
```

**Output — common material statements**

```text
GO := /usr/lib/go-1.23/bin/go
GOPATHLOCAL := $(ROOTDIR)common/external/go
... fallback only for go >= 1.23 ...
export GOMODCACHE=$(GOPATHLOCAL)
ifndef ONLINE
export GOPROXY=file://$(GOPATHLOCAL)/cache/download
export GOSUMDB=off
endif
[every listed go.mod: go 1.23]
```

**Exit code:** 0.  
**Technical conclusion:** Go 1.23 is consistent; the local offline cache is absent.

### P09 — Java/Gradle requirements

**Command**

```sh
for f in common/java/javavar.mk common/java/common.mk common/java/Makefile common/java/build.gradle common/java/common-build.gradle common/java/common-buildscript.gradle common/java/settings.gradle auditor/build.gradle auditor/settings.gradle key/build.gradle key/settings.gradle processor/build.gradle processor/settings.gradle; do printf '\nFILE %s\n' "$f"; git show "2785872f84dffb56bbecc41b096a7ee0f2876e64:$f"; done
```

**Output — lines material to the conclusion**

```text
G := $(ROOTDIR)common/external/gradle-8.11/bin/gradle
G_CACHE := $(ROOTDIR)common/external/java/
GFLAGS := -g=$(G_CACHE)
ifndef ONLINE
GFLAGS += --offline
endif
$(G) build installDist ... $(GFLAGS)
sourceCompatibility = JavaVersion.VERSION_21
repositories { mavenCentral() }
```

Direct Maven coordinates are in `common/java/build.gradle` and summarized in section 1.7.  
**Exit code:** 0.  
**Technical conclusion:** JDK 21, Gradle 8.11, and an absent Maven offline cache are actual requirements.

### P10 — Python and Debian paths

**Commands**

```sh
git show 2785872f84dffb56bbecc41b096a7ee0f2876e64:setup.py; git show 2785872f84dffb56bbecc41b096a7ee0f2876e64:debian/python3-ivxv-common.install; git show 2785872f84dffb56bbecc41b096a7ee0f2876e64:debian/python3-ivxv-common.postinst; git show 2785872f84dffb56bbecc41b096a7ee0f2876e64:debian/ivxv-admin.install
git show 2785872f84dffb56bbecc41b096a7ee0f2876e64:debian/control; git show 2785872f84dffb56bbecc41b096a7ee0f2876e64:debian/rules
```

**Output — material lines**

```text
install_requires=[bottle, docopt, jinja2, jsonschema, pyopenssl, fasteners,
python-crontab, python-dateutil, python-debian, pyyaml, setuptools]
common/external/python/wheels /usr/lib/python3.10/.cache/pip/
common/external/python/requirements.txt /usr/lib/python3.10/.cache/pip/
pip3 install --no-index --find-links ... --requirement ... --require-hash ...
common/external/js/startbootstrap-sb-admin-2/...
common/external/js/bootstrap ...
common/external/js/datatables ...
common/external/js/font-awesome ...
common/external/js/jquery/dist/jquery.min.js ...
Build-Depends: debhelper-compat (= 13), dh-exec, dh-python, python3-all,
python3-debian, python3-setuptools
override_dh_auto_build: $(MAKE) version; $(MAKE) go; dh_auto_build ...
override_dh_auto_install: $(MAKE) -C storage ivxv_storage_db; ...
```

**Exit codes:** 0 and 0.  
**Technical conclusion:** Package building requires unpublished Python, JavaScript, and storage artifacts.

### P11 — Missing paths

**Command**

```sh
for p in tests release common/external/go common/external/gradle-8.11 common/external/java common/external/python common/external/js common/external/database common/external/schematics; do git cat-file -e "2785872f84dffb56bbecc41b096a7ee0f2876e64:$p" 2>/dev/null; ec=$?; printf '%s exit=%s\n' "$p" "$ec"; done
```

**Output**

```text
tests exit=128
release exit=128
common/external/go exit=128
common/external/gradle-8.11 exit=128
common/external/java exit=128
common/external/python exit=128
common/external/js exit=128
common/external/database exit=128
common/external/schematics exit=128
```

**Overall shell exit:** 0; individual exits were printed intentionally.  
**Technical conclusion:** Every checked prerequisite is absent from the commit object.

### P12 — External acquisition references and history

**Commands**

```sh
git grep -nEI '(common/external|gradle-8\.11)' 2785872f84dffb56bbecc41b096a7ee0f2876e64 -- .
git log --all --raw --format='commit %H %ad %s' --date=iso-strict -- common/external | head -160
```

**Output — relevant matches grouped completely**

```text
Makefile: make external/update-external -> git submodule update ...
Documentation/et/audiitor/audit.rst: wget Gradle 8.11; unzip
Documentation/et/audiitor/history.txt: same manual procedure
common/go/govar.mk: common/external/go
common/java/javavar.mk: gradle-8.11 and java cache
collector-admin/Makefile: common/external/schematics
storage/Makefile: common/external/database/etcd/...
debian/ivxv-admin.install: common/external/js/...
debian/python3-ivxv-common.install: common/external/python/...
023e072...: deleted .gitattributes, README.rst, install_java_dep;
               reduced .gitignore to an empty file
```

**Exit codes:** 0 and 0.  
**Technical conclusion:** No current complete acquisition mechanism exists; previous helper files were removed in 2024.

### P13 — Local tool availability

**Command**

```sh
for c in make go /usr/lib/go-1.23/bin/go java javac gradle python3 pip3 dpkg-buildpackage debuild dh git-lfs docker sphinx-build plantuml; do command -v "$c"; done
```

**Output**

```text
/usr/bin/python3
/usr/bin/git-lfs
```

**Exit code:** 1 because the last tool was absent. Supplemental versions: Python `3.10.12`, Git LFS `3.0.2`.  
**Technical conclusion:** The principal toolchain is absent; nothing was installed.

### P14 — Ubuntu package sources

**Command**

```sh
for f in /etc/apt/sources.list /etc/apt/sources.list.d/*; do if [ -f "$f" ]; then printf '\nFILE %s\n' "$f"; sed -n '1,240p' "$f"; fi; done
```

**Output — active entries**

```text
deb http://de.archive.ubuntu.com/ubuntu/ jammy main restricted
deb http://de.archive.ubuntu.com/ubuntu/ jammy-updates main restricted
deb http://de.archive.ubuntu.com/ubuntu/ jammy universe
deb http://de.archive.ubuntu.com/ubuntu/ jammy-updates universe
deb http://de.archive.ubuntu.com/ubuntu/ jammy multiverse
deb http://de.archive.ubuntu.com/ubuntu/ jammy-updates multiverse
deb http://de.archive.ubuntu.com/ubuntu/ jammy-backports main restricted universe multiverse
deb http://security.ubuntu.com/ubuntu/ jammy-security main restricted
deb http://security.ubuntu.com/ubuntu/ jammy-security universe
deb http://security.ubuntu.com/ubuntu/ jammy-security multiverse
```

**Exit code:** 0.  
**Technical conclusion:** Package sources are not pinned to a snapshot.

### P15 — Final source-repository check

**Command**

```sh
git status --short --branch; git diff --exit-code; git diff --cached --exit-code
```

**Output**

```text
## HEAD (no branch)
```

**Exit code:** 0.  
**Technical conclusion:** The investigation changed no tracked file in the IVXV repository.

---

**Stop point:** The initial task is complete. No installation, download, external network access, system change, or build was performed.
