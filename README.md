# IVXV Independent Build and Reproducibility Audit

> **Independent project:** This is not an official audit and is not affiliated
> with, commissioned by, or endorsed by the Estonian State Electoral Office,
> the Estonian Information System Authority, the IVXV developers, or the
> official election auditors.

This repository documents an independent technical investigation of the
publicly available source code of Estonia’s IVXV internet-voting system.

The investigation focuses on a basic but essential question:

> Can an independent third party obtain the published source code, reconstruct
> the required build environment, build the complete published system, and
> verify that the resulting binaries correspond to the software actually used
> in elections?

This is an AI-assisted audit. Commands, inputs, outputs, assumptions, findings,
and limitations are documented so that the work can be independently reviewed
and repeated.

## Repository under review

Official upstream repository:

<https://github.com/valimised/ivxv>

Commit under review:

```text
2785872f84dffb56bbecc41b096a7ee0f2876e64
```

Commit subject:

```text
KOV2025:
```

The investigation is performed against a fixed commit. Moving branches such as
`master` or `published` are not treated as authoritative build inputs unless
their exact commit IDs are recorded separately.

## Audit goals

The investigation aims to determine:

1. whether the published repository contains all source code and build inputs
   required for the IVXV system;
2. whether all external dependencies can be identified and independently
   obtained;
3. whether dependency versions, origins, and hashes are sufficiently pinned and
   verifiable;
4. whether the system can be built in a clean environment;
5. whether two independent builds produce identical or explainably equivalent
   artifacts;
6. whether the resulting binaries can be compared with the binaries actually
   deployed for an election;
7. whether the complete source-to-binary chain is independently verifiable.

The intended verification chain is:

```text
published source code
        ↓
documented and reproducible build
        ↓
independently produced binaries
        ↓
cryptographic comparison
        ↓
binaries deployed in the election
```

## Scope and limitations

This project is not an official audit commissioned by the Estonian National
Electoral Service or the Estonian Information System Authority.

It does not currently claim to prove:

- election manipulation;
- modification of votes;
- the presence of malicious code;
- or an incorrect election result.

The present investigation examines:

- source-code availability;
- build-system completeness;
- dependency provenance;
- software-supply-chain transparency;
- reproducibility;
- source-to-binary traceability.

A successful audit of election procedures does not by itself prove that the
deployed binaries were built from the published source code. That requires an
independently verifiable source, build, and binary chain.

## Current status

| Phase | Status |
|---|---|
| Phase 1 — read-only repository inventory | Completed |
| Phase 2 — dependency provenance investigation | Completed |
| Phase 3 — clean-room build and controlled reconstruction | Completed |
| Build A — controlled reference build | Pending |
| Build B — independent verification build | Pending |
| Artifact comparison and `diffoscope` analysis | Pending |
| Final report | Pending |

## Phase 1 — read-only repository inventory

Phase 1 was performed as a strictly read-only investigation.

During Phase 1:

- no builds were executed;
- no tests were executed;
- no packages were installed;
- no files were downloaded;
- no external network access was used;
- no repository files were modified;
- no operating-system configuration was changed.

Full report:

[Phase 1: IVXV Build Investigation](reports/build-investigation-en.md)

Phase 2 report:

[Phase 2: Dependency Provenance](reports/dependency-provenance.md)

Phase 3 reports:

- [Strict clean-room build](reports/clean-room-build.md)
- [Controlled reconstruction](reports/reconstructed-build.md)
- [Test execution](reports/test-execution.md)

### Main findings

The reviewed commit cannot be completely or reproducibly built from the
published repository alone.

The build system expects substantial unpublished or missing content under:

```text
common/external/go
common/external/gradle-8.11
common/external/java
common/external/python
common/external/js
common/external/database
common/external/schematics
```

At the reviewed commit, `common/external` is an ordinary Git tree containing
only an empty `.gitignore`.

It is not:

- a Git submodule;
- a Gitlink;
- or a Git LFS delivery containing the required artifacts.

The documented command:

```bash
make external
```

only executes:

```bash
git submodule update --init
```

The reviewed commit contains no corresponding Gitlinks, so this command cannot
retrieve the missing `common/external` content.

### Documentation and build-system conflicts

The published README and the actual build system contradict each other in
several important places.

Examples:

```text
README: Go 1.9
Actual build system: Go 1.23

README: Java 11
Actual Gradle configuration: Java 21

README: common/external is an LFS submodule
Actual repository: ordinary tree with one empty file

README: make external retrieves external dependencies
Actual command: ineffective because no matching submodule exists

README: make release
Actual repository: no release target and no release directory
```

### Missing build inputs

Missing inputs include, among other things:

- the complete Go module proxy cache;
- Gradle 8.11;
- the Maven/Gradle offline cache;
- Python wheels;
- hashed Python requirements;
- JavaScript vendor libraries;
- the ETCD database package;
- `common/external/schematics`;
- pinned Ubuntu or Debian package sources;
- a reference CI configuration;
- a documented build image;
- a complete machine-readable artifact manifest;
- source locations, versions, and SHA-256 hashes for all build inputs.

### Additional observations

All published `go.mod` files require Go 1.23.

The Java build configuration requires Java 21 and Gradle 8.11.

The repository includes neither a Gradle wrapper nor a checksum for the required
Gradle distribution.

Java dependencies are not fully locked through a published dependency lock or
complete artifact manifest.

Python dependencies in `setup.py` are not pinned, while the Debian packaging
expects an absent offline wheel repository and hashed requirements.

Ubuntu package sources are not pinned to a historical snapshot and therefore do
not define a bit-reproducible operating-system package environment.

The modules `common/collector` and `voting` require an external pseudo-version
of:

```text
tivi.io/core
```

even though a separate local `core/` directory exists in the repository. No Go
`replace` directive points to the local source.

No conventional CI configuration was found that defines an authoritative build
environment, toolchain, dependency-acquisition process, or build sequence.

### Phase 1 conclusion

> The IVXV repository publishes source code, but it does not publish a complete
> and reproducible build state of the system. Essential build dependencies and
> artifacts are missing, and the documented dependency-acquisition method does
> not work for the reviewed commit.

This finding does not establish that the missing artifacts are unavailable
internally.

It establishes that they are not available through the reviewed public
repository in a form that permits an independent complete and reproducible
build.

In a conventional professional software project, these findings would normally
be treated as release, acceptance, and audit blockers until:

- all build inputs are identified;
- all dependencies are available;
- versions and origins are pinned;
- hashes are published;
- the documentation matches the actual build system;
- the complete system builds in a clean environment;
- and the resulting binaries can be traced to the deployed release.

## Phase 2 — dependency provenance

Phase 2 uses limited read-only network access to investigate the provenance and
public availability of the missing build inputs.

Phase 2 includes:

- verification of the current upstream and mirror references;
- investigation of the history of `common/external`;
- analysis of the 2024 removal of historical external-dependency files;
- verification of the public availability of all required Go modules;
- investigation of the origin and availability of `tivi.io/core`;
- verification of the authoritative Gradle 8.11 checksum;
- inventory of direct and transitive Maven dependencies;
- reconstruction of historical Python versions, wheel names, requirements, and
  hashes;
- identification of JavaScript library versions and sources;
- investigation of the origin of the ETCD database package;
- search for an official Debian or Ubuntu build environment;
- search for related repositories and published release artifacts;
- classification of dependencies as public, uncertain, internal, unavailable,
  or no longer reconstructable.

The Phase 2 report will be published as:

[Phase 2: Dependency Provenance](reports/dependency-provenance.md)

## Planned reproducibility test

After the required dependencies and build procedure have been identified, two
separate build environments will be used.

### Build A

Build A will be a controlled reference build with:

- a fixed source commit;
- pinned operating-system package sources;
- recorded toolchain versions;
- frozen dependencies;
- complete command logs;
- SHA-256 hashes of all inputs and outputs.

### Build B

Build B will be an independent verification build using the same frozen inputs,
preferably without network access.

Artifacts from both builds will be compared using:

```text
SHA-256
binary comparison
archive-content comparison
diffoscope
```

Differences will be documented and classified as:

- deterministic;
- timestamp-related;
- environment-dependent;
- toolchain-dependent;
- or unexplained.

## Relation to official election audits

The available KOV2025 procurement documents define the official election audit
primarily as a process and data audit.

The official auditor observes or verifies activities such as:

- key generation;
- configuration and digital signatures;
- application checksums;
- election-box closure and transfer;
- log integrity;
- vote processing;
- duplicate-vote removal;
- anonymisation;
- cryptographic mixing;
- tallying;
- verification proofs;
- destruction of election data and key material.

The procurement requires the auditor to build or otherwise provide an
application for verifying the mixing and tallying results.

It does not require:

- an independent build of the complete IVXV production system;
- a complete audit of all published IVXV source code;
- verification of every external dependency;
- a reproducible build of the complete release;
- or comparison of independently built binaries with the binaries deployed in
  the election.

The official software authenticity check is based on hashes supplied to the
auditor by the election authority.

This verifies a chain of the following form:

```text
hash supplied by the election authority
        ↕
binary delivered to the production environment
```

It does not independently verify:

```text
published source code
        ↓
independent complete build
        ↓
independently produced binary
        ↓
comparison with deployed binary
```

This repository therefore addresses a separate question not covered by the
documented official process and data audit:

> Do the publicly available sources and dependencies permit an independent
> reconstruction and verification of the complete deployed software?

## Evidence and reproducibility

The planned repository structure is:

```text
ivxv-audit/
├── README.md
├── reports/
│   ├── build-investigation-en.md
│   ├── dependency-provenance.md
│   └── final-report.md
├── evidence/
│   ├── command-logs/
│   ├── dependency-manifests/
│   ├── hashes/
│   └── build-comparisons/
└── scripts/
```

Reports should distinguish clearly between:

- directly observed facts;
- command output;
- information stated in project documentation;
- information obtained from external sources;
- technical inference;
- and unresolved questions.

## Contributions and corrections

Technical corrections, missing documentation, dependency sources, historical
artifacts, build instructions, and independently reproducible results are
welcome.

Useful submissions should include verifiable evidence such as:

- exact commit IDs;
- archived source locations;
- artifact hashes;
- signed manifests;
- build logs;
- package versions;
- reproducible scripts;
- links to published audit reports.

Claims without verifiable supporting material may be recorded as leads but will
not be treated as established findings.

## Responsible publication

Potential security vulnerabilities affecting a currently deployed system should
be handled with appropriate consideration for responsible disclosure.

Build-system, dependency, documentation, provenance, and reproducibility
findings may be published directly where they do not disclose an operational
exploit.

## Legal and licensing notice

This repository contains independently authored audit documentation, command
logs, metadata, hashes, and scripts.

It does not contain or redistribute the IVXV source code or IVXV election
software binaries.

The IVXV source code is copyright of the Estonian State Electoral Office
(Vabariigi Valimisteenistus) and is subject to the licence stated in the
official IVXV repository:

<https://github.com/valimised/ivxv>

References to IVXV:

- file names;
- repository paths;
- commit identifiers;
- technical behaviour;
- build configuration;
- and limited excerpts required to document specific findings

are provided solely for identification, technical analysis, criticism, and
reproducibility of the audit findings.

No affiliation with, sponsorship by, or endorsement from the Estonian State
Electoral Office, the Estonian Information System Authority, the IVXV
developers, or official election auditors is claimed.

Third-party materials remain subject to their respective copyright and licence
terms.

Unless explicitly stated otherwise, no licence is granted for the original
audit reports, documentation, evidence, or scripts contained in this
repository.
