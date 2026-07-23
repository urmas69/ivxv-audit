#!/usr/bin/env bash
set -Eeuo pipefail
SRC=${1:-/home/audit/audit/ivxv}; OUT=${2:-$(pwd)/evidence/source-audit/static-analysis}; mkdir -p "$OUT"
set +e
(cd "$SRC" && go version && go vet ./common/collector/zip ./common/collector/safereader) >"$OUT/go-vet.log" 2>&1; s=$?
set -e; printf 'tool=go vet\tstatus=%s\tlog=%s\n' "$s" "$OUT/go-vet.log"; exit 0
