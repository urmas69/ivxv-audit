# Phase 2 scripts

All scripts operate non-interactively. They write only to paths supplied by the
caller or to standard output. Run them from the audit repository unless a
script states otherwise.

- `capture-command.sh OUTPUT COMMAND [ARG ...]` records a command, timestamp,
  working directory, relevant environment, status, and combined output.
- `audit-go-dependencies.sh IVXV_SOURCE OUTPUT_DIRECTORY` enumerates published
  Go files and checks module proxy objects using temporary storage.
- `build-canonical-dependency-manifest.py [AUDIT_ROOT]` combines the
  ecosystem-specific evidence into the canonical CSV.
- `phase2-external-etcd-os-evidence.sh` and
  `phase2-related-repositories.sh` reproduce history and public-repository
  queries; see each script's usage check.
- `validate-phase2-manifest.py [CSV]` checks the canonical column order,
  classification vocabulary, mandatory identity fields, and deterministic row
  ordering.

Ecosystem-specific scripts document their own arguments in `--help` output or
usage messages. Use `/tmp/ivxv-phase2` for downloaded or generated material;
do not point output parameters into the read-only IVXV source repository.
