# Processor and anonymization audit

The Java processor separates identified and anonymous ballot-box models. Revoke and restore operations emit operator/report records before anonymization. The final anonymous box is produced by `BallotBox.anonymize`; source inspection did not establish a reversible voter mapping in that output, but no independent fixture proved absence of linkage fields. This is an unresolved lead, not a confirmed privacy defect.
