#!/usr/bin/env bash
set -Eeuo pipefail
SRC=${1:-/home/audit/audit/ivxv}; OUT=${2:-$(pwd)/evidence/source-audit/fuzzing}; mkdir -p "$OUT"
set +e
(cd "$SRC" && go test ./common/collector/zip -run '^$' -fuzz '^Fuzz' -fuzztime=10s) >"$OUT/zip-fuzz.log" 2>&1; s=$?
set -e
printf 'target=common/collector/zip\tstatus=%s\tduration=10s\n' "$s" >"$OUT/results.tsv"
exit 0
