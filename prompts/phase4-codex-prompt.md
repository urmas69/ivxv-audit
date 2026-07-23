# IVXV Audit Phase 4 — Source-Code Security and Correctness Audit

Continue the independent IVXV audit with a comprehensive source-code review of the fixed KOV2025 source tree.

The canonical source commit is:

```text
2785872f84dffb56bbecc41b096a7ee0f2876e64
```

Repository locations:

```text
/home/audit/audit/ivxv
/home/audit/audit/ivxv-audit
/home/audit/audit/ivxv-reconstructed
```

The original `/home/audit/audit/ivxv` checkout is immutable evidence. It must remain at the fixed commit with an empty worktree status. Do not change its files, index, configuration, branches, remotes, or commit.

Phase 3 produced reconstructed research binaries and documented patches. Those artifacts may be used for isolated tests, but they are not proven equivalent to the KOV2025 production software.

## Authorization and operating mode

Work autonomously until the Phase 4 completion criteria are met.

You are authorized to:

- inspect every source, configuration, schema, generated-code definition, Makefile, Gradle file, Go module, Python file, JavaScript file, packaging file, test, and documentation file in the fixed IVXV tree;
- use the user-local toolchains prepared during Phase 3;
- install additional user-local static-analysis or test tools under `/home/audit/tools` when useful;
- create a separate analysis checkout at `/home/audit/audit/ivxv-source-audit`;
- create targeted tests, fuzz harnesses, instrumentation, and minimal reproductions in the analysis checkout;
- run reconstructed IVXV binaries only inside the dedicated audit VM or an isolated local test environment;
- create reports, findings, source maps, call graphs, test results, scripts, patches, and evidence inside `/home/audit/audit/ivxv-audit`;
- commit substantial completed work and push it to `origin/phase-4-source-code-audit`;
- continue after individual tools, tests, or components fail.

Do not ask for routine confirmation or clarification. Make conservative assumptions, record them, and continue.

Do not:

- interact with production election infrastructure;
- scan, probe, authenticate to, or test public or private election services;
- inspect credentials, tokens, private keys, personal voter data, or election secrets;
- create or publish weaponized exploitation code;
- claim election manipulation or an incorrect result without direct evidence;
- treat scanner output, suspicious-looking code, or theoretical possibility as a confirmed vulnerability;
- modify or conceal the immutable evidence checkout.

Potential vulnerabilities affecting a currently deployed system must be documented carefully for responsible disclosure. Reports committed to the public audit repository should contain enough evidence for independent technical review without operational exploitation instructions against a live system.

## Primary objective

Determine whether the published IVXV source implements its election-security and correctness properties consistently and defensively.

The audit must examine at least:

- authentication and authorization;
- voter eligibility and voter-list handling;
- election and choice-list validation;
- ballot construction, acceptance, qualification, storage, and export;
- repeated electronic voting and selection of the last valid vote;
- cancellation and restoration of electronic votes due to paper voting;
- anonymization and removal of voter identity;
- decryption, tallying, and proof generation;
- voter-side and server-side verification;
- cryptographic primitives, parameters, protocols, randomness, and key handling;
- certificate, OCSP, timestamp, signature, and container validation;
- configuration authenticity and trust boundaries;
- database and storage consistency;
- concurrency, ordering, replay, rollback, retry, and partial-failure behavior;
- logging, audit records, error handling, and observability;
- administrative and deployment control paths;
- unsafe parsing, deserialization, command execution, file handling, path handling, and temporary-file use;
- privacy leakage and residual identity information;
- test coverage and security-relevant untested paths.

## Audit principles

For every reviewed security property:

1. identify the intended property from code and documentation;
2. identify the exact trust boundary and attacker or failure model;
3. trace the complete source-code path that enforces the property;
4. identify all inputs, state transitions, persisted data, outputs, and error paths;
5. test material assumptions where practical;
6. distinguish direct observation from inference;
7. record uncertainty explicitly;
8. avoid conclusions that exceed the available evidence.

Do not perform a superficial keyword or scanner-only review. Static-analysis tools may identify leads, but each material lead must be validated manually against the source and, where practical, with an isolated test.

## Analysis checkout

Create or refresh:

```text
/home/audit/audit/ivxv-source-audit
```

The analysis checkout must begin at the fixed commit.

Maintain two conceptual states:

1. **canonical source state** — exact fixed commit, used for all findings and line references;
2. **instrumented research state** — optional targeted tests or instrumentation, represented by explicit patches.

Store every source modification or added test as a reviewable patch under:

```text
patches/source-audit/
```

For every patch record:

- purpose;
- affected files;
- whether behavior is changed or merely observed;
- relationship to the canonical source;
- whether the resulting test remains representative of the original code.

Do not silently reuse Phase 3 reconstruction patches. Record exactly which Phase 3 patch or substitution is applied for each executable test.

## Workstream 4.0 — Architecture and trust-boundary map

Before reporting vulnerabilities, create a source-grounded map of:

- major components and executables;
- data stores and persistent state;
- network interfaces and protocols;
- configuration and signed-container inputs;
- election data exchanged with external systems;
- key material and certificate flows;
- voter identity and ballot identity transitions;
- online and offline trust boundaries;
- administrative roles and privileged operations;
- transition from identified ballot to anonymized ballot to tally.

Produce at least:

```text
reports/architecture-and-trust-boundaries.md
evidence/source-audit/component-inventory.tsv
evidence/source-audit/entry-points.tsv
evidence/source-audit/trust-boundaries.tsv
evidence/source-audit/data-flow-inventory.tsv
```

The architecture report must cite concrete source paths, symbols, schemas, configuration examples, and documentation sections.

## Workstream 4.1 — Collector, voting, authentication, and ballot acceptance

Audit the online vote-collection path end to end.

Examine at least:

- voter authentication mechanisms;
- session establishment, binding, expiration, reuse, and revocation;
- authorization decisions;
- voter-list and choice-list selection;
- election identifier and time-window checks;
- ballot and signed-container parsing;
- voter signature verification;
- OCSP and timestamp qualification;
- duplicate request and replay handling;
- ballot replacement and revoting behavior;
- storage acknowledgement and consistency;
- behavior on network interruption, retry, timeout, partial write, and concurrent requests;
- trust in headers, proxy information, client-provided metadata, and external identity services;
- rate limits and resource exhaustion where security relevant;
- information returned to the voter or verification application.

Trace all relevant services, including Go applications and shared collector code. Do not assume that a component name proves its deployed role; establish the role from code and configuration.

Produce:

```text
reports/collector-and-voting-audit.md
```

## Workstream 4.2 — Vote lifecycle, duplicate removal, revocation, and anonymization

Audit the complete offline processing sequence:

```text
check → squash → revoke/restore → anonymize → decrypt/tally
```

Verify from source:

- what constitutes a valid ballot;
- how ballots are associated with a voter before anonymization;
- exactly how the latest valid electronic ballot is selected;
- which timestamp or ordering value controls selection;
- how ties, missing timestamps, malformed timestamps, or inconsistent registration data are handled;
- whether input ordering can affect the result;
- how paper-vote cancellation and restoration lists are validated and applied;
- behavior for duplicate, contradictory, repeated, or reordered revocation entries;
- whether cancellation can affect the wrong election, voter, or ballot;
- whether all identity-bearing fields are removed during anonymization;
- whether logs, filenames, ordering, indexes, exceptions, rejected-ballot outputs, or auxiliary reports retain linkable identity information;
- whether count conservation and transformation invariants hold across every processing stage;
- whether rejected or invalid ballots can re-enter later stages;
- whether processing is deterministic for identical inputs.

Create source-grounded invariants, for example:

```text
input accepted ballots
  = retained latest ballots
  + superseded ballots
  + invalid/rejected ballots

retained electronic ballots
  = ballots before revocation
  - valid cancellations
  + valid restorations

anonymized ballots
  contain no voter identifier or reversible linkage metadata
```

Test these invariants with synthetic local data where practical.

Produce:

```text
reports/vote-lifecycle-audit.md
reports/processor-and-anonymization-audit.md
evidence/source-audit/vote-lifecycle-invariants.tsv
```

## Workstream 4.3 — Cryptography and key management

Audit all cryptographic operations and protocols, including:

- ballot encryption and ciphertext validation;
- signature creation and verification;
- hash and message-digest use;
- random-number generation and entropy mixing;
- group and curve selection;
- parameter validation;
- key generation and key-share handling;
- threshold or distributed-key assumptions;
- smart-card interactions;
- key reconstruction in memory;
- decryption and proof generation;
- verification of decryption or shuffle proofs;
- TLS configuration where implemented in source;
- certificate-chain construction and validation;
- OCSP, CRL, and timestamp handling;
- algorithm selection from configuration;
- downgrade or algorithm-confusion opportunities;
- domain separation, encoding, canonicalization, and serialization;
- sensitive-data lifetime, logging, temporary files, and memory handling;
- error handling around cryptographic failures.

Check implementation use against authoritative standards and upstream library documentation where required. Record external sources and retrieval dates. Do not report a weakness solely because an algorithm is unfamiliar or old; establish the concrete security property and deployment context.

Produce:

```text
reports/cryptography-and-key-management-audit.md
evidence/source-audit/cryptographic-operations.tsv
evidence/source-audit/algorithm-and-parameter-inventory.tsv
```

## Workstream 4.4 — Verification and auditability

Audit voter verification and independent audit functions.

Determine:

- what the verification application or verification service actually proves;
- what data it receives and trusts;
- whether it verifies ballot inclusion, ballot contents, server response, or only a limited protocol statement;
- time and attempt limitations;
- how revoting interacts with verification;
- how QR or session material is bound to a ballot and election;
- whether stale, replayed, or cross-election verification data can be accepted;
- what the auditor application verifies;
- which integrity properties depend on externally supplied manifests, hashes, logs, or configuration;
- whether verification failures are distinguishable from unavailable infrastructure;
- whether the code supports independent reproduction of claimed checks.

Clearly distinguish:

- cast-as-intended;
- recorded-as-cast;
- tallied-as-recorded;
- process evidence;
- source-to-binary authenticity.

Produce:

```text
reports/authentication-and-verification-audit.md
reports/auditor-tool-audit.md
```

## Workstream 4.5 — Storage, administration, configuration, and logging

Audit:

- storage service APIs and database consistency assumptions;
- atomicity and transaction boundaries;
- key construction, indexes, ordering, and uniqueness;
- concurrent writes and reads;
- rollback, retry, recovery, and migration behavior;
- deletion and retention behavior;
- ETCD-related assumptions visible in source despite the missing deployment bundle;
- management-daemon privileges and command execution;
- subprocess invocation and shell usage;
- archive extraction, path traversal, symlink, and permission handling;
- temporary files and predictable paths;
- signed configuration validation;
- configuration versioning and election binding;
- update and deployment workflows;
- log integrity, log injection, missing events, secret leakage, and correlation identifiers;
- whether logs allow independent reconstruction of security-relevant state transitions;
- whether errors are ignored, downgraded, retried indefinitely, or converted into success.

Produce:

```text
reports/storage-admin-configuration-and-logging-audit.md
```

## Workstream 4.6 — Defensive coding and parser review

Systematically examine all externally reachable or security-sensitive parsers and interfaces for:

- unsafe deserialization;
- ambiguous JSON, YAML, XML, ASN.1, ZIP, BDOC, PEM, DER, and container parsing;
- duplicate keys and canonicalization differences;
- integer overflow, truncation, sign conversion, and unbounded allocation;
- panic, uncaught exception, and denial-of-service paths;
- path traversal and archive extraction issues;
- command or argument injection;
- regular-expression denial of service;
- unbounded recursion or attacker-controlled loops;
- race conditions and shared mutable state;
- TOCTOU behavior;
- insecure defaults;
- fail-open validation;
- ignored return values and partial errors;
- inconsistent validation between Go, Java, Python, and JavaScript implementations.

Use targeted fuzzing where feasible. Fuzz only isolated local code. Preserve seeds and minimized failure inputs, but do not commit personal, secret, or large binary data.

Produce:

```text
reports/parser-and-defensive-coding-audit.md
evidence/source-audit/fuzz-targets.tsv
evidence/source-audit/fuzz-results.tsv
```

## Workstream 4.7 — Tests and assurance gaps

Map tests to security properties and production components.

Record:

- unit, integration, feature, and end-to-end tests present in the repository;
- tests actually executable with the reconstructed environment;
- security properties covered;
- critical paths with no tests;
- fixtures or trust stores missing from the publication;
- tests declared but skipped or `NO-SOURCE`;
- flaky, environment-dependent, or nondeterministic tests;
- tests that validate implementation details but not security outcomes;
- negative tests and malformed-input coverage;
- whether test expectations match current code and documentation.

Add targeted audit tests for high-value invariants where practical. Keep audit-added tests separate from original project tests and represent them as patches.

Produce:

```text
reports/source-test-and-assurance-gap-analysis.md
evidence/source-audit/security-property-test-map.tsv
```

## Static and dynamic analysis

Use appropriate tools where useful, for example:

- Go compiler and tests;
- `go vet`;
- race detection where CGo and environment permit;
- focused fuzzing;
- Gradle compilation and test tasks;
- Java compiler warnings;
- dependency and bytecode inspection;
- Python syntax, import, lint, and security checks;
- shell-script analysis;
- targeted semantic or data-flow scanning.

Install tools user-locally and record:

- name;
- version;
- source URL;
- SHA-256 where downloaded as an artifact;
- command line;
- configuration;
- limitations.

Scanner output is evidence for triage, not a finding. Validate every reported issue against exact source paths and code behavior.

## Finding standard

Assign source-audit finding IDs sequentially:

```text
IVXV-SRC-001
IVXV-SRC-002
...
```

Every finding must contain:

- ID;
- concise title;
- status: `confirmed`, `likely`, `uncertain`, `not-reproducible`, or `informational`;
- category: security, correctness, privacy, auditability, robustness, test gap, documentation mismatch, or maintainability;
- severity: Critical, High, Medium, Low, or Informational;
- confidence: High, Medium, or Low;
- affected component and executable;
- exact fixed commit;
- exact source paths, symbols, and line ranges;
- security or correctness property;
- trust boundary and attacker/failure model;
- preconditions;
- direct observation;
- technical reasoning;
- practical impact;
- local reproduction or test, when safe and feasible;
- expected versus actual behavior;
- evidence paths;
- limitations and alternative explanations;
- remediation guidance;
- regression-test recommendation;
- responsible-disclosure consideration.

Severity must reflect realistic impact and required preconditions. Do not inflate severity because the system is election-related.

Keep leads that are not validated in a separate lead register. Do not present them as findings.

Create canonical machine-readable files:

```text
findings/source-code-findings.csv
findings/source-code-findings.json
evidence/source-audit/unresolved-leads.tsv
```

The CSV and JSON must describe the same finding set and be deterministically ordered by ID.

## Evidence and logging

Create:

```text
evidence/source-audit/
evidence/source-audit/command-logs/
evidence/source-audit/test-results/
evidence/source-audit/static-analysis/
evidence/source-audit/fuzzing/
evidence/source-audit/code-maps/
```

Raw command logs must include:

- UTC timestamp;
- working directory;
- exact shell-escaped command;
- relevant environment;
- tool version;
- exit status;
- stdout and stderr.

Keep interpretation in reports, not hidden inside raw logs.

Do not commit:

- large build caches;
- dependency caches;
- downloaded repositories;
- full build trees;
- credentials or secrets;
- real voter data;
- private keys;
- large fuzz corpora;
- temporary VM or container images.

## Scripts

Create reproducible scripts under:

```text
scripts/source-audit/
```

All Bash scripts must begin with:

```bash
set -Eeuo pipefail
```

At minimum provide scripts for:

- source-state verification;
- component and entry-point inventory;
- security-sensitive symbol inventory;
- static-analysis execution;
- source test execution;
- audit-added test execution;
- artifact and evidence hashing;
- deterministic generation of the findings CSV and JSON;
- report evidence-link validation.

Scripts must use deterministic ordering, explicit paths, useful exit codes, and parameters where practical.

## Required reports

Create and maintain:

```text
reports/source-code-audit.md
reports/architecture-and-trust-boundaries.md
reports/collector-and-voting-audit.md
reports/vote-lifecycle-audit.md
reports/processor-and-anonymization-audit.md
reports/cryptography-and-key-management-audit.md
reports/authentication-and-verification-audit.md
reports/auditor-tool-audit.md
reports/storage-admin-configuration-and-logging-audit.md
reports/parser-and-defensive-coding-audit.md
reports/source-test-and-assurance-gap-analysis.md
```

`reports/source-code-audit.md` is the consolidated Phase 4 report. It must summarize scope, methodology, reviewed components, confirmed findings, unresolved questions, test coverage, limitations, and conclusions, while linking to the detailed reports and machine-readable findings.

All reports must distinguish clearly between:

- fixed-source observations;
- reconstructed-build behavior;
- audit-added instrumentation behavior;
- documentation statements;
- external-source facts;
- technical inference;
- unresolved questions;
- conclusions that cannot be attributed to KOV2025 production binaries.

## Review coverage tracking

Maintain a deterministic coverage register:

```text
evidence/source-audit/review-coverage.tsv
```

For every security-relevant package or component record:

- component;
- language;
- primary executable or library;
- security role;
- files or directories reviewed;
- relevant tests;
- audit status: not-started, in-progress, reviewed, or blocked;
- reviewer notes;
- linked findings;
- linked unresolved leads.

Do not mark Phase 4 complete while critical components remain merely `not-started` or `in-progress`.

## Progress and Git workflow

Work only on branch:

```text
phase-4-source-code-audit
```

Maintain:

```text
evidence/source-audit/phase4-progress.md
```

Update it after every major workstream with:

- completed work;
- current work;
- remaining work;
- blockers;
- reports and evidence created;
- findings and leads added;
- tests executed;
- last successful commit.

Commit after substantial completed workstreams with clear messages. Push successful commits to `origin/phase-4-source-code-audit`.

Never:

- force-push;
- rewrite published history;
- merge into `main`;
- modify the immutable evidence repository;
- hide negative or inconclusive results;
- delete evidence merely because a suspected issue was disproved.

Disproved leads should be retained concisely as resolved leads where useful to avoid repeated work.

## README update

At the beginning of Phase 4, update the README status table to include:

```text
Phase 4 — source-code security and correctness audit | In progress
Phase 5 — isolated deployment and end-to-end testing | Pending
Phase 6 — independent rebuild and artifact comparison | Pending
Phase 7 — production artifact and configuration comparison | Pending
```

At completion, mark Phase 4 `Completed` only when the completion criteria below are met.

## Required conclusions

The consolidated report must clearly answer:

1. What are the security-critical components and trust boundaries in the published IVXV source?
2. How does a ballot move from authenticated voter to stored identified ballot, latest-vote selection, revocation, anonymization, decryption, and tally?
3. Which exact source paths enforce voter eligibility, ballot validity, revoting, paper-vote cancellation, and anonymization?
4. Are those properties consistently enforced on success, error, retry, concurrency, and malformed-input paths?
5. What does voter verification prove and what does it not prove?
6. What does the auditor application independently verify and what external assumptions remain?
7. Are cryptographic algorithms, parameters, randomness, key handling, certificate validation, and proof verification used correctly within the reviewed threat model?
8. Are there confirmed security, correctness, privacy, auditability, or robustness findings?
9. Which findings were reproduced with targeted local tests?
10. Which security-critical paths lack meaningful tests?
11. Which conclusions apply only to the reconstructed research build rather than the unchanged source or KOV2025 production system?
12. What must be tested in Phase 5 through isolated deployment and end-to-end election scenarios?

## Completion criteria

Phase 4 is complete only when:

- the architecture, components, entry points, data flows, and trust boundaries are documented from source;
- every security-critical component is marked `reviewed` or explicitly `blocked` with a justified reason in the coverage register;
- collector, voting, processing, anonymization, cryptography, verification, auditor, storage, administration, configuration, logging, and parser paths have been reviewed;
- all material static-analysis leads have been manually triaged;
- targeted tests or fuzzing have been run for the highest-risk and highest-uncertainty properties where feasible;
- confirmed findings meet the complete finding standard;
- unconfirmed issues remain clearly separated as leads;
- machine-readable findings and evidence exist and are internally consistent;
- all required reports and scripts exist;
- fixed-source, reconstructed-build, and audit-instrumented results are never conflated;
- the original IVXV evidence checkout remains clean at the fixed commit;
- the README status is accurate;
- all completed work is committed and pushed;
- remaining unknowns and Phase 5 test requirements are explicit.

Do not claim that Phase 4 proves the deployed KOV2025 binaries matched the published source. This phase audits the published source code and locally reconstructed research behavior only.

At completion, print a concise summary containing:

- reviewed components;
- principal confirmed findings;
- important disproved leads;
- tests and fuzzing executed;
- coverage status;
- reports and evidence created;
- unresolved blockers;
- source-state verification;
- commits;
- push status.

Begin now and continue autonomously until the Phase 4 completion criteria are met.