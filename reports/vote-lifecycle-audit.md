# Vote lifecycle audit

`processor` tools implement check/squash/revoke/restore/anonymize. `RevokeAndAnonymizeTool` calls `BallotBox.revokeDoubleVotes` and then `BallotBox.anonymize`; reporter callbacks retain voter IDs in pre-anonymization logs. Latest-vote selection and revocation are source-reviewed, but malformed timestamp, contradictory-list and count-conservation fixtures were not published. Invariants are recorded in [vote-lifecycle-invariants.tsv](../evidence/source-audit/vote-lifecycle-invariants.tsv). Determinism and identity-erasure require targeted Phase 5 fixtures.
