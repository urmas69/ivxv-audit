# Authentication and verification audit

Verification components bind requests to configured election/session data and report protocol-level checks. The Go verification service entry points are under `verification/service` and `verification/internal`; the fixed tree’s tests are enumerated in `evidence/source-audit/entry-points.tsv`. The Java auditor’s decryption path checks proof/ciphertext membership in `auditor/src/main/java/ee/ivxv/audit/tools/DecryptTool.java:107-179`, while `IntegrityTool.java:218-223` derives related log paths from supplied filenames. These checks establish recorded/proof consistency only; they do not prove source-to-binary authenticity or that an external manifest is authentic.

Stale, cross-election and unavailable-service behavior requires signed verification fixtures. Missing trust stores and election containers prevented executable protocol testing; this is an explicit blocked test, not a pass.
