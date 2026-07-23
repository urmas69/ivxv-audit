# Phase 2 scripts

All scripts operate non-interactively. They write only to paths supplied by the
caller or to standard output. Run them from the audit repository unless a
script states otherwise.

- `capture-command.sh OUTPUT COMMAND [ARG ...]` records a command, timestamp,
  working directory, relevant environment, status, and combined output.
- `validate-phase2-manifest.py [CSV]` checks the canonical column order,
  classification vocabulary, mandatory identity fields, and deterministic row
  ordering.

Ecosystem-specific scripts document their own arguments in `--help` output or
usage messages. Use `/tmp/ivxv-phase2` for downloaded or generated material;
do not point output parameters into the read-only IVXV source repository.
