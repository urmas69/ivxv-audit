#!/usr/bin/env bash
set -Eeuo pipefail
SRC=${1:-/home/audit/audit/ivxv}; OUT=${2:-$(pwd)/evidence/source-audit/test-results}; mkdir -p "$OUT"
set +e
(cd "$SRC" && go test ./common/collector/zip ./common/collector/safereader) >"$OUT/go-collector-tests.log" 2>&1; s=$?
set -e; printf 'suite=collector parsers\tstatus=%s\tlog=%s\n' "$s" "$OUT/go-collector-tests.log"; exit 0
