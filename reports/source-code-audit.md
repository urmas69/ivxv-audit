# IVXV Phase 4 source-code security and correctness audit

## Executive conclusion

The fixed commit was reviewed across collector, voting, processing, anonymization, cryptography, verification, auditor, storage, administration, configuration, logging and parser paths. Three findings are recorded: two confirmed reproducibility/robustness/documentation issues concerning the external etcd dependency and one uncertain PyYAML safety lead. No confirmed ballot-integrity, cryptographic-bypass, or voter-privacy vulnerability was established by this review.

This report separates fixed-source observations from Phase 3 reconstruction behavior and audit-added inventories. Reconstruction binaries are not evidence of KOV2025 production equivalence. The immutable source checkout remained at the specified commit and clean.

## Method and coverage

Manual source tracing was combined with deterministic inventories and Phase 3 test logs. Component status is in [review-coverage.tsv](../evidence/source-audit/review-coverage.tsv); entry points, trust boundaries and data flows are linked from [architecture-and-trust-boundaries.md](architecture-and-trust-boundaries.md). Findings are canonicalized in [source-code-findings.csv](../findings/source-code-findings.csv) and JSON.

## Findings

* IVXV-SRC-001 (confirmed, Medium): storage hard-codes `/usr/bin/etcd`.
* IVXV-SRC-002 (uncertain, Medium): command-file parsing invokes PyYAML `Loader`; reachability depends on signed-container trust.
* IVXV-SRC-003 (confirmed, Medium): published source does not uniquely provide the external etcd deployment artifact.

Unresolved leads remain separate and are not findings. No production service was contacted and no exploitation code was produced.

## Lifecycle and verification

The source path is authenticated voter/container → collector → identified storage → processor check/squash/revoke/restore → anonymous ballot box → auditor decrypt/proof/tally. Exact source responsibilities and invariants are documented in the detailed lifecycle reports. Verification proves protocol-specific statements, not source-to-binary authenticity or complete tally correctness.

## Tests and limitations

Phase 3 reconstruction Go tests and Java Gradle tasks were used only as reconstruction evidence; Java tasks were `NO-SOURCE`/`SKIPPED`, and trust-store/election fixtures were unavailable. Audit-added dynamic tests and fuzzing were therefore limited to source inventories and safe manual review. Phase 5 must supply isolated signed-container, revocation, anonymization, malformed-proof, retry/concurrency and certificate fixtures.

## Conclusion

The published source is sufficiently traceable for independent review, but reproducibility and deployment provenance remain incomplete. The findings and unresolved questions should be carried into isolated deployment testing; this phase does not assert behavior of deployed KOV2025 binaries.
