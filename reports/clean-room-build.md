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

## Attempts and results

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

The strict track produced no binaries or Debian packages. Its source tree
remained unchanged; before/after file inventories and hashes are under
`evidence/build-a/`.

## Build-system observations

The Makefiles invoke Go formatting/tools and Java/Gradle builds, and the
packaging rules expect missing `common/external` content. `make external` does
not download a URL itself and has no matching published gitlink. The root
clean target references `tests/` and `release/`, which are absent from the
fixed tree. These are direct source observations; whether an election build
used an unrecorded external checkout remains unresolved.

## Strict conclusion

No component reached compilation or packaging in this environment. The strict
result is therefore an infrastructure and published-input failure, not a
source compilation result. It must not be conflated with the controlled
reconstruction track.
