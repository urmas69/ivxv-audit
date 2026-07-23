#!/usr/bin/env bash
set -Eeuo pipefail

if [[ $# -ne 3 ]]; then
  echo "usage: $0 SOURCE BEFORE AFTER" >&2
  exit 64
fi
source=$(realpath "$1")
before=$(realpath "$2")
after=$(realpath "$3")
mkdir -p "$before" "$after"
(cd "$source" && find . -xdev -type f -printf '%P\t%s\t%T@\n' | LC_ALL=C sort) > "$before/files.tsv"
(cd "$source" && find . -xdev -type f -printf '%P\t%s\t%T@\n' | LC_ALL=C sort) > "$after/files.tsv"
comm -3 "$before/files.tsv" "$after/files.tsv" > "$after/delta.tsv" || true
