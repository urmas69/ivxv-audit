# Phase 3 Track 1 — strict published clean-room build

## Scope and evidence

Track 1 used a separate checkout at `/tmp/ivxv-phase3-strict-1784814341`,
detached at `2785872f84dffb56bbecc41b096a7ee0f2876e64`. The immutable evidence
checkout was not modified. Commands and exit statuses are recorded under
`evidence/command-logs/phase3-strict-*.txt`; environment inventory is
`evidence/build-a/environment.txt`.

## Supported entry points observed

The root `Makefile` defines `make`, `make all`, `make go`, `make java`,
`make test`, `make clean`, `make install`, and component-specific targets. It
also defines `make external`, which only runs `git submodule update --init`.
The root clean target delegates to component clean targets and references a
missing `release/` directory. Debian packaging is invoked by the conventional
`dpkg-buildpackage`; `debian/rules` provides the package rules. No root
`package` or `release` target was found.

## Initial attempt and results

The host inventory recorded Linux x86_64, Python 3.10.12, and Git 2.34.1, but
no `make`, Go, Java/Javac, Gradle, compiler, `dpkg-buildpackage`, or `debuild`.
The documented entry points were nevertheless attempted:

| command | result |
|---|---|
| `make help` | exit 127, `make` unavailable |
| `make clean` | exit 127, `make` unavailable |
| `make` | exit 127, `make` unavailable |
| `make go` | exit 127, `make` unavailable |
| `make java` | exit 127, `make` unavailable |
| `make test` | exit 127, `make` unavailable |
| `dpkg-buildpackage -us -uc -b` | exit 127, unavailable |

An authorized non-interactive installation attempt using `sudo -n` failed
because the VM requires a password. No packages were installed. Python's
metadata-only commands did run: `python3 setup.py --name` returned
`IVXVCollectorAdminDaemon` and `python3 setup.py --version` returned `1.10.3`.

The initial strict track produced no binaries or Debian packages. Its source
tree remained unchanged; before/after file inventories and hashes are under
`evidence/build-a/`.

## User-local toolchain continuation

At the Phase 3 continuation, official distributions and Ubuntu package
archives were downloaded to `/tmp/ivxv-tools-download` and extracted without
root into `/home/audit/tools`. The captured environment provides GNU Make 4.3,
Go 1.23.12, OpenJDK 21.0.11, Gradle 8.11, GCC 11, dpkg-dev/debhelper tooling,
and fakeroot support. URLs, package versions, sizes, and SHA-256 values are
recorded in `evidence/toolchains/` and the download command log.

The strict checkout was then tested with the real toolchain. `make` with no
target correctly printed the help target and exited 0; the actual aggregate
command is `make all`. `make clean`, `make all`, `make go ONLINE=1`, and
`make java ONLINE=1` were executed separately. Java stopped because the fixed
tree expects the absent path
`common/external/gradle-8.11/bin/gradle`. Go reached real module resolution
and generation, then failed on the inaccessible `tivi.io/core` vanity import.
`make Documentation` reached documentation cleanup and failed because the
repository references absent documentation/build support. `git submodule
update --init` exited 0 but had no published gitlink to initialize.

To test independently buildable Go modules beyond the root Makefile, each
published module was run with Go 1.23.12, public `GOPROXY`, and a temporary
module cache. The core generator was also executed after normalizing the
non-executable `gentmpl.sh` mode in the temporary checkout. Results:

- `common/tools/go` passed;
- `mid`, `proxy`, `smartid`, `storage`, `verification`, `votesorder`, and
  `webeid` reached compilation but were blocked by generated error definitions
  until the core generator was run; subsequent tests were not attributable to
  the strict published state;
- `common/collector` and `voting` remained blocked by `tivi.io/core`;
- `choices`, `sessionstatus`, and `sessionstatus/api` reached the linker but
  required the extracted libc development archive; with `CGO_ENABLED=0`,
  strict tests passed for those modules;
- generated-code execution and source-tree changes remain confined to the
  temporary strict checkout. No strict binaries are asserted as production
  outputs.

All strict command logs are named `phase3-toolchain-strict-*` or
`phase3-strict-gotest*`. The strict track never used the reconstruction patch.

## Build-system observations

The Makefiles invoke Go formatting/tools and Java/Gradle builds, and the
packaging rules expect missing `common/external` content. `make external` does
not download a URL itself and has no matching published gitlink. The root
clean target references `tests/` and `release/`, which are absent from the
fixed tree. These are direct source observations; whether an election build
used an unrecorded external checkout remains unresolved.

## Strict conclusion

The strict track now reached actual Go compilation and generator execution, but
the published state cannot complete because of project-specific missing inputs
(`common/external` Gradle/cache content and `tivi.io/core`) and missing source
support for some generated/package paths. The strict state produced no
complete Go or Java distribution and no Debian package. These are strict
published-state results and must not be conflated with reconstruction results.
