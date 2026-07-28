# IVXV Election Procedure Documentation Review

**Review date:** 2026-07-28  
**Status:** Independent documentation review  
**Scope:** Official IVXV procedural and technical documentation for the 2025 election cycle  
**Related project:** [IVXV Independent Build and Reproducibility Audit](../README.md)

> **Important limitation:** This report reviews what the documents specify. It does not
> establish what was done in a particular election, whether undocumented controls exist,
> whether votes were manipulated, or whether an election result was incorrect.

## 1. Executive summary

The reviewed IVXV documentation describes a substantial set of procedural and
cryptographic controls. These include digitally signed configurations and data,
mutual TLS between machine interfaces, threshold key management, registration of
received votes, individual vote verification, processing logs, mixing proofs, tally
proofs, backups, monitoring, and crash-recovery procedures.

However, the seven documents do not form a single, internally consistent,
independently repeatable assurance specification. The most important missing link is
an end-to-end, independently verifiable chain from the published source code to the
software actually executed in the election:

```text
published source commit
        ↓
complete, pinned and reproducible build
        ↓
independently produced binary artifacts
        ↓
officially approved release manifest
        ↓
binaries installed and executed in the election
```

The documentation frequently proves integrity relative to a file, signature, package
or hash supplied by the election authority or delivery process. It does not define a
procedure by which an independent party can establish that the supplied executable
files were built from the published source code, or that the exact same files were
installed and executed throughout the election infrastructure.

The documentation is also inconsistent about supported platforms and versions. A
2025 administration manual specifies Ubuntu 20.04 and contains examples using IVXV
1.7.8 packages, while the 2025 configuration guide specifies Java 21 and testing on
Ubuntu 22.04 and Windows 11. The election manual specifies Windows 11 with Java 17
or newer for the key computer. Recovery instructions even tell the operator to
clarify which Ubuntu version is currently in use. Such variation prevents the
documents from defining one authoritative election software baseline.

The review identified several additional assurance gaps:

- mandatory independent audit coverage does not include every critical preparation,
  software-delivery, deployment, snapshot, recovery and transfer step;
- no complete signed election release manifest is defined;
- removable-media and human-mediated file transfers lack a complete documented
  chain of custody;
- snapshot, backup and restoration procedures are incomplete or not independently
  verifiable;
- discrepancy and failure handling is often weaker than the verification mechanism
  itself;
- critical permissions are concentrated in broad administrative roles without a
  documented mandatory two-person rule;
- the reviewed set does not clearly require tamper-evident, independently preserved
  audit logs;
- the collection-service architecture explicitly lacks a certificate-revocation
  procedure for removed service instances;
- voter-application packaging relies on precompiled delivery artifacts and
  delivery-only tools whose source-to-binary provenance is not defined;
- manual edits to `mix.py` are permitted without a mandatory patch, hash and approval
  record.

These findings do not show that the IVXV procedures necessarily produced an
incorrect result. They show that the reviewed documentation does not, by itself,
support complete independent verification of the entire technical and procedural
chain.

## 2. Documents reviewed

| Abbreviation | Document | Version and date |
|---|---|---|
| ÜK | *IVXV elektroonilise hääletamise üldraamistik ja selle kasutamine Eesti riiklikel valimistel* | IVXV-ÜK-1.1, 2025-09-26 |
| KR | *IVXV: E-hääletamise käsiraamat* | IVXV-KR-0.9, 2025-09-23 |
| JSK | *IVXV seadistuste koostamise juhend* | IVXV-JSK-1.10, 2025-09-25 |
| JVP | *IVXV valijarakenduse pakendamine* | IVXV-JVP-1.10, 2025-09-05 |
| JSH | *IVXV kogumisteenuse haldusjuhend* | IVXV-JSH-1.10, 2025-09-25 |
| JHT | *IVXV haldusteenuse kasutusjuhend* | IVXV-JHT-1.10, 2025-09-25 |
| VIS | *VIS3-EHS liidesed* | IVXV-VIS-EHS-1.9.10, 2024-05-14 |

## 3. Method and assessment criteria

The documents were treated as one procedural system. The review checked whether
they collectively define:

1. an authoritative software and configuration baseline;
2. a verifiable source-to-binary-to-deployment chain;
3. clear roles, approvals and separation of duties;
4. complete custody records for data and removable media;
5. repeatable processing, mixing and tallying procedures;
6. explicit handling of failures, discrepancies and invalid proofs;
7. reliable logging, backup, recovery and evidence preservation;
8. consistency across document versions, platforms and examples;
9. sufficient information for independent observers and auditors to repeat or verify
   the procedures.

The finding priority reflects the potential effect on independent assurance, not a
claim that a vulnerability was exploited.

## 4. Positive controls described by the documentation

The following controls are meaningful and should be retained.

### 4.1 Digitally signed configurations and election data

The system uses signed ASiC-E or BDOC containers for trust roots,
configurations, permissions and multiple election data sets. Applications verify
configuration signatures when starting. This supports signer identification and
detection of changes after signing. [JSK §§3.2–3.3; JSH §4.4; JHT §2.4]

### 4.2 Separate registration of received votes

The framework assigns an independent registration service the task of registering
each received vote hash and returning a time assertion. Processing later compares
the collector's ballot box with registration data. This is an important mechanism
for detecting missing or added records. [ÜK §7.4; KR §3.1]

### 4.3 Threshold key management

The decryption key is divided between multiple key holders, and a threshold of key
shares is required for decryption. Key generation, testing and use are described in
detail, and key-related procedures are subject to auditor supervision. [ÜK §7.1;
KR §2.3; JSK §§4.1–4.6]

### 4.4 Proof-based verification

Mixing and tallying can produce cryptographic proofs. The audit application checks
conversion, mixing and tally proofs, and Verificatum can also verify the mixing
proof. The mixed and initially unmixed tally results are required to be identical.
[ÜK §§7.6–8.4; KR §§4.3–4.6; JSK §6]

### 4.5 Individual vote verification

A voter can use a separate device and the verification application to check that the
collector stored a vote corresponding to the voter’s intended selection. This does
not prove the complete election result, but it is a useful individual verification
control. [ÜK §§3, 7.5]

### 4.6 Monitoring, redundancy and recovery planning

The collector documentation includes technical monitoring, log collection,
internal and external backup, redundancy assumptions and extensive crash-recovery
instructions. These are operationally valuable, even though the assurance and
versioning gaps described below remain. [JSH §§4.3, 5.12, 6, 8]

## 5. Findings

### F-01 — No independently verifiable source-to-deployed-binary chain

**Priority: Critical**

The election manual says that the “latest software version” is deployed to the
collection service. It does not identify an exact source commit, package set,
release number or signed hash manifest. The Java applications are delivered as
ZIP files named with a delivery number, and the voter applications and packaging
utilities are supplied in an “IVXV delivery package”. Collection-service updates
are performed by copying `.deb` packages into `/etc/ivxv/debs` and installing them.
None of these procedures establishes that the delivered files were built from a
specified public source commit. [KR §2.1; JSK §3.1; JVP §§1.2–1.3; JSH §§4.7,
5.11]

The publication of application hashes proves that a downloaded or transferred file
matches the authority's reference file. It does not prove where that reference file
came from. Code signing similarly proves who signed a file and whether it was
modified after signing; it does not prove that the file corresponds to the published
source.

The missing assurance chain is:

```text
public source
→ independent reproducible build
→ identical binary
→ officially approved binary
→ binary actually deployed and executed
```

**Required control:** For every election, publish a signed release manifest
containing the exact source commit, complete build instructions, pinned dependency
set, build-image identity, artifact names, artifact hashes and the hashes measured
on every deployed host. The build must be independently reproducible.

### F-02 — No single immutable election software and configuration baseline

**Priority: Critical**

The documents define many individual configurations, packages, certificates and
data files, but do not define one immutable election baseline that binds them
together. A complete baseline would include at least:

- all application and `.deb` package names, versions and hashes;
- voter, verification, key, processor, auditor and mixing application hashes;
- the source commit and build metadata for every application;
- operating-system image and package versions;
- Java, OpenSSL, Python and other runtime versions;
- final trust roots, certificates and key identifiers;
- final signed configurations and list versions;
- snapshot identifiers and hashes;
- authorized signers and approvals;
- the time at which the election configuration was frozen.

Some processor and auditor configurations may be created immediately before
processing or auditing, and the signer of all application configuration files is not
strictly determined. This makes it difficult to prove that a single pre-approved
configuration set governed the entire process. [KR §2.2]

**Required control:** Create and sign a complete election manifest before the
election. Every later change must create a new manifest version with a reason,
approvals, timestamps and an immutable audit trail.

### F-03 — Mandatory audit coverage excludes critical preparation steps

**Priority: Critical**

The election manual makes auditor supervision mandatory for mixing and operations
involving the decryption key. Other procedures are checked by the State Electoral
Office and task-force leader “as needed”; observer supervision is merely
recommended. [KR §1.2]

The preparation stage for tallying is explicitly labelled “non-audited”. During this
stage, the configuration is checked and signed, and the key application and other
necessary programs are written to external media. The later tallying operation is
audited, but the preparation that determines which software and configuration will
be executed is not. [KR §4.1]

The framework further states that the trustworthiness of the audit application is
the auditor's responsibility, but does not define an independent build, validation or
approval procedure for that application. [ÜK §8.4]

**Implication:** An auditor may correctly observe a procedure performed by an
application whose provenance was not independently established. This is a different
question from verifying the mathematical relationship between inputs and outputs.

**Required control:** Mandatory audit coverage should begin with release receipt,
artifact verification and preparation of media, and continue through installation,
configuration, snapshot creation, restoration, processing, mixing, tallying and
evidence preservation. The audit tool itself must have an independently verifiable
build and artifact identity.

### F-04 — Platform and version specifications are internally inconsistent

**Priority: High**

The 2025 documents do not define one authoritative runtime baseline:

- JSH 1.10 states that the collection service runs on Ubuntu 20.04 LTS.
- JSK 1.10 states that Java applications use Java 21 and were tested on Windows 11
  and Ubuntu 22.04.
- KR 0.9 specifies Windows 11 and Java 17 or newer for the key computer.
- JSH installation examples use IVXV 1.7.8 packages and Ubuntu 20.04-era package
  versions.
- JSH recovery examples refer to an `ivxv-choices_1.9.12~dev_amd64.deb` package.
- One recovery instruction tells the operator to clarify which Ubuntu version is
  currently used.
- JSK’s Verificatum installation section says Ubuntu 20.04 “Bionic Beaver”, even
  though Ubuntu 20.04 is Focal Fossa.

JSH 1.10 also refers to the older framework document ÜK-0.95, while the reviewed
current framework is ÜK-1.1. [JSH §§2.2, 4.1, 4.7, 8.1; JSK §§3.1, 10.1; KR §2.3]

**Implication:** Different competent operators can follow the documentation and
construct different environments. Exact incident reconstruction and independent
repetition become unreliable.

**Required control:** Publish one versioned compatibility matrix and a machine-
readable build/deployment image definition. Replace historical command output with
clearly marked examples or current tested commands.

### F-05 — Voter-application packaging does not establish artifact provenance

**Priority: High**

The voter-application guide starts from precompiled, unconfigured binaries delivered
in the IVXV delivery package. `Seadistaja.exe` injects election-specific resources into
the Windows, Linux and macOS executables. The packaging tools, macOS resources and
entitlements are also supplied in the delivery package. [JVP §§1–3]

The guide does not define:

- the source commit for the precompiled binaries or tools;
- hashes and signatures of all delivery-package inputs;
- an independent build process for `Seadistaja.exe` and packaging scripts;
- a before-and-after manifest for resource injection;
- reproducible output requirements.

JVP states that signing after resource injection is optional, while KR requires
Windows and macOS applications to be signed and the Linux application to remain
unsigned. [JVP §3; KR §2.4]

The test procedure is functional: conduct a test vote, decrypt it and compare the
result with the recorded choice. This checks an important use case but cannot prove
that the binary contains only the intended source code. [JVP §5]

**Required control:** Publish and sign all pre-configuration and post-configuration
artifact hashes, source commits, build records, resource files, packaging-tool hashes,
signing identities and test evidence. Resolve the optional/mandatory signing
contradiction.

### F-06 — Removable-media and manual-transfer custody is under-specified

**Priority: High**

Applications, configurations, ballot boxes, registration data, logs, results and
proofs are repeatedly moved using external media. In some processing steps, an
output hash is moved to an internet-connected computer for signing and then returned
to the offline processing computer. VIS3–EHS also relies on multiple human-mediated
download, external-signing, handover, extraction and upload procedures. [KR §§2.3,
3, 4; VIS §§1.1, 3.1, 4.1, 8.1]

The reviewed set does not define a complete custody record containing:

- unique media identifier and serial number;
- sender, recipient, time and location of each handover;
- complete file inventory and hash for every file;
- write-protection status;
- seal number and seal inspection;
- malware inspection;
- two-person confirmation;
- immutable receipt and reconciliation record.

A signed hash of one output protects that output after signing. It does not document
the identity and custody of every application, input, script and other file present on
the medium.

**Required control:** Use a signed media manifest and formal two-person handover
record at every boundary. Verify the full manifest before and after each transfer.

### F-07 — Snapshot, backup and restoration assurance is incomplete

**Priority: High**

After test voting, the manual requires two collector snapshots and later restoration
from one of them depending on whether the candidate list changes. It does not define
a mandatory signed snapshot identifier, snapshot hash, complete content manifest,
independent approval or proof that the selected approved snapshot was restored.
[KR §2.5]

JSH covers backups of management configuration, the ballot box and logs. However,
it explicitly states that no procedure is provided for restoring the management-
configuration backup, and no procedure is provided for restoring log backups. It
recommends a virtual-machine snapshot dump for management-service recovery. [JSH
§5.12]

Recovery procedures frequently require rebuilding hosts and applying configurations
and packages. Without an immutable software baseline and signed restore manifest,
a restored system may be operationally functional while differing from the original
approved state.

**Required control:** Define backup hashes, signed manifests, retention, encryption,
offline/immutable copies, periodic restore tests and post-restore state attestation.
Every snapshot restoration must be independently verified against the approved
election manifest.

### F-08 — Verification failures and result discrepancies lack a complete decision procedure

**Priority: High**

The documentation defines strong checks but often does not define the mandatory
response to failure.

Examples include:

- invalid tally proofs are written to a configured file, but KR does not define the
  decision, escalation and publication procedure;
- mixed and unmixed tally results “must be identical” and are compared with `FC`,
  but the reviewed procedure does not define what happens if they differ;
- the first unmixed tally may be produced without a tally proof, followed on the
  next day by a mixed tally with proof;
- the documents do not provide one decision table for invalid signatures, missing
  votes, inconsistent registration data, failed conversion, invalid mix proofs,
  invalid tally proofs or conflicting results;
- VIS machine-interface errors are generally handled by retrying, while
  human-interface mistakes may be deleted and replaced.

[KR §§4.1, 4.5–5; VIS §§1.4–1.5]

**Required control:** Publish an incident and discrepancy matrix specifying who
stops the process, what evidence is frozen, who investigates, which results may be
published, how the public is notified, and who authorizes continuation or
cancellation.

### F-09 — Critical permissions are broad and mandatory dual control is not defined

**Priority: High**

The role matrix grants the `admin` role the ability to apply election and technical
configurations, download the ballot box, manage users and view logs. The
`election-conf-manager` can apply election configurations and download the ballot
box. Users may hold multiple roles, and permissions accumulate. [JSK §7.6]

The documents do not define a mandatory two-person rule, dual authorization or
independent approval for every critical operation such as:

- applying the technical or election configuration;
- changing user permissions;
- downloading the final ballot box;
- updating software packages;
- restoring snapshots or replacing service instances;
- preparing processing and tallying media.

This is a documentation finding. Actual organizational procedures may impose
additional controls, but they are not established by this reviewed set.

**Required control:** Define incompatible roles and require two-person approval for
critical commands. Log both approvals cryptographically.

### F-10 — The reviewed logging model is not explicitly tamper-evident

**Priority: High**

JHT exposes management events with time, service identifier, severity, event type
and description. JSH describes log collectors, log monitoring and backups. These are
useful controls. [JHT §10; JSH §§4.3, 5.12]

The reviewed documents do not clearly require:

- append-only or cryptographically chained logs;
- periodic signed log checkpoints;
- independent real-time log replication outside the administrator's control;
- trusted-time evidence for every log source;
- immutable retention and deletion policy;
- a signed complete log export manifest for the auditor.

Ordinary centralized logs and backups can support investigation, but without
tamper-evidence their evidentiary value depends strongly on administrator and system
trust.

**Required control:** Cryptographically chain or sign logs, replicate them to
independent custody in real time, and publish a signed election log manifest.

### F-11 — Removed service instances have no certificate-revocation mechanism

**Priority: High**

JSH explicitly states that service instances trust certificates issued by a common CA
but do not use a corresponding method to revoke the trust of a removed instance,
because implementing such a procedure was considered too complex. The operator
must therefore ensure that the removed instance is completely eliminated; otherwise
it may continue operating and disrupt the collection service. [JSH §5.9]

This is an acknowledged architectural and operational risk. It relies on complete
physical or administrative elimination rather than cryptographic revocation.

**Required control:** Introduce short-lived per-instance credentials or a documented
revocation mechanism, and require positive verification that removed credentials are
rejected by all active services.

### F-12 — Late configuration creation and signer-authority ambiguity weaken change control

**Priority: High**

KR allows decryption, processor and auditor configuration files to be prepared after
or immediately before their respective stages. It also states that the signer of all
application configuration files is not strictly determined; the application merely
shows the signer's name and personal identifier. [KR §2.2]

A valid signature proves the signer and file integrity. It does not prove that the
signer was authorized for that exact action or that the contents were independently
approved.

**Required control:** Define authorized roles per configuration type, require
independent review, freeze configurations before the relevant stage, and bind them
to the signed election manifest.

### F-13 — Human-mediated VIS3–EHS transfers need stronger end-to-end records

**Priority: Medium–High**

The VIS3–EHS specification uses mutual TLS for machine interfaces and sequence
numbers for voter-list changes. These are positive controls. [VIS §§1.3, 5.2]

Several critical objects nevertheless use a human-machine procedure. An operator
downloads a JSON file, signs it outside the source system, hands it to another
operator, and the recipient uploads it. For results, the VIS operator uploads the JSON
extracted from the signed container. Correct but mistakenly uploaded data may be
deleted and replaced. [VIS §§1.1, 1.5, 3.1, 4.1, 8.1]

The reviewed passages do not define an immutable correction history that binds:

- the source-system export event;
- the exported file hash;
- the signing container;
- the extracted JSON uploaded to the destination;
- the receiving-system import receipt;
- any deletion and replacement.

**Required control:** Preserve the signed container, source receipt, destination
receipt and correction history as one immutable transaction record.

### F-14 — Test and production application separation is based mainly on a runtime warning

**Priority: Medium**

JSK states that both production and test versions exist. Test versions may behave
differently and are unsuitable for real elections; they display a large warning and
must be recompiled for production mode. [JSK §3.3]

The documentation does not define a mandatory machine-enforced release policy that
rejects test-mode applications based on a signed manifest or binary identity.

**Required control:** Give production and test artifacts distinct signed identities,
package names and release channels. Deployment must automatically reject any
artifact not listed in the election release manifest.

### F-15 — Key generation depends critically on the exact application and environment

**Priority: Medium–High**

The threshold design and key-share testing are strengths. At the same time, the
Desmedt procedure creates the key in the key application's memory and distributes
shares to cards. This makes the exact key-application binary and execution
environment part of the trusted computing base. [JSK §4.2]

KR documents default card PIN/PUK values and makes assignment of card PINs
optional. Physical controls may mitigate this, but the documentation should explain
the security rationale and define mandatory access controls for production
elections. [KR §2.3]

**Required control:** Independently verify the key-application binary before
execution, bind it to the election manifest, require production card access controls,
and record the card identities, custodians, tests and destruction evidence.

### F-16 — Verification is not always independent of the production environment

**Priority: Medium**

KR recommends performing mixing, conversion checking and mixing verification as a
single procedure on the same computer, although verification must use a different
directory. [KR §§4.2–4.4, 5]

Using a separate directory prevents some accidental overlap but does not provide
independence from the same operating system, hardware, runtime, compromised
environment or shared preparation chain.

**Required control:** Perform at least one verification on an independently prepared
system using independently obtained and verified software.

### F-17 — Normative quality and document-version control are insufficient

**Priority: Medium**

The reviewed set mixes normative requirements, recommendations, examples,
historical command output and open-ended statements. Examples include:

- “latest software version” instead of an immutable identifier;
- “as needed”, “recommended”, “if desired” and “may be prepared immediately
  before” for security-relevant steps;
- outdated package and document references;
- inconsistent platform names and versions;
- a manual edit to `mix.py` to change logging;
- a step-number jump from 2 to 4 in the cryptogram-check procedure;
- typographical variants such as `Chack`;
- the “counting without mixing” section accepting either mixed or unmixed input;
- changing Apple notarization steps described only as current at writing time.

[KR §§1.2, 4.2, 4.7; JSH §§2.2, 4.7, 8; JSK §10.1; JVP §4]

These defects do not prove an incorrect procedure, but they reduce repeatability and
make it harder to determine which text is binding.

**Required control:** Publish the documents as one versioned, cross-referenced
normative set. Every command and example should state the tested software version.
Security requirements should use clearly defined mandatory language.

## 6. Cross-document inconsistencies

| Subject | Document A | Document B | Assurance effect |
|---|---|---|---|
| Collector platform | JSH: Ubuntu 20.04 | JSK: apps tested on Ubuntu 22.04 | No single runtime baseline |
| Java | KR: Java 17 or newer | JSK: Java 21 | Java 17 may not execute Java 21 artifacts |
| Package version | JSH examples: IVXV 1.7.8 | JSH recovery example: 1.9.12 development package; docs labelled 1.10 | Unclear authoritative release |
| Voter-app signing | JVP: signing after configuration is optional | KR: Windows/macOS signing required, Linux unsigned | Contradictory normative requirement |
| Framework reference | JSH references ÜK-0.95 | Current reviewed framework is ÜK-1.1 | Stale cross-reference |
| Mixing platform | JSK says Ubuntu 20.04 “Bionic Beaver” | Ubuntu 20.04 is elsewhere named Focal Fossa | Technical/documentary error |
| Software identity | KR: “latest software version” | JSK/JSH use delivery/package numbers and historical examples | No immutable identifier |
| Audit scope | ÜK process audits focus on key operations | KR makes only mixing/key supervision mandatory | Critical preparation is not universally audited |

## 7. Minimum evidence package required for each election

A complete independent assurance package should include:

1. **Source manifest**
   - exact commit for every repository;
   - source archive hashes;
   - submodule and dependency commits.

2. **Build manifest**
   - reproducible build instructions;
   - build-image hash;
   - compiler/runtime versions;
   - dependency names, versions, origins and hashes;
   - complete build logs.

3. **Release manifest**
   - every binary, script, package, archive and configuration filename;
   - SHA-256 for every artifact;
   - signer and approval records;
   - explicit production/test classification.

4. **Deployment attestation**
   - host inventory;
   - operating-system image and package baseline;
   - measured hashes of installed files;
   - service configuration and certificate identities;
   - installation and update logs.

5. **Procedure evidence**
   - signed media-transfer manifests;
   - two-person approvals;
   - snapshot and backup identifiers;
   - command transcripts and exit codes;
   - complete input/output hashes.

6. **Verification evidence**
   - processor reconciliation results;
   - mix and tally proofs;
   - independent verifier output;
   - invalid-proof and discrepancy files;
   - signed decision records.

7. **Final deployment comparison**

```text
hash(independent build)
=
hash(official release)
=
hash(installed and executed artifact)
```

Without the final equality, reproducible building alone does not prove what ran in
the election.

## 8. Recommended remediation priorities

### Immediate

1. Publish a complete signed KOV2025 software and configuration manifest.
2. Identify the exact source commit and build provenance for every deployed artifact.
3. Publish hashes of artifacts measured on all production systems.
4. Resolve the Ubuntu, Java and package-version contradictions.
5. Define mandatory handling for failed proofs and differing tally results.
6. Prohibit undocumented modification of executable scripts such as `mix.py`.

### Before the next election

1. Establish reproducible builds for the complete release.
2. Require independent rebuild and comparison with production artifacts.
3. Expand mandatory audit coverage to software receipt, media preparation,
   deployment, snapshot restoration and recovery.
4. Introduce signed chain-of-custody manifests and two-person control.
5. Make logs tamper-evident and independently preserved.
6. Add cryptographic revocation or short-lived credentials for service instances.
7. Define tested backup restoration and state-attestation procedures.
8. Publish the complete document set as one coherent version.

## 9. Conclusion

The IVXV documents contain multiple serious and technically valuable controls. The
cryptographic verification of processing, mixing and tallying is materially stronger
than a procedure based only on visual observation. Signed configurations,
registration records, threshold keys and verification proofs are important parts of a
sound election system.

The central assurance problem is that these controls are not connected by a complete
and independently verifiable software and procedure chain. The documents do not
establish that:

```text
the reviewed public source
=
the source used for the official build
=
the delivered binary artifacts
=
the software installed and executed in the election
```

They also do not define one fully consistent platform baseline, one immutable
election manifest, complete custody evidence, complete restoration assurance, or a
mandatory decision procedure for every failed verification.

The appropriate conclusion is therefore limited but significant:

> The reviewed documentation supports verification of several data transformations,
> signatures and cryptographic proofs, but it does not by itself support complete
> independent verification of the full IVXV source, build, deployment, operation and
> result-production chain.

This is not evidence that manipulation occurred. It is evidence that the
documentation does not provide the evidence chain required to rule out undocumented
software or procedural divergence by independent reconstruction.
