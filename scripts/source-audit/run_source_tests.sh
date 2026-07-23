#!/usr/bin/env bash
set -Eeuo pipefail
SRC=${1:-/home/audit/audit/ivxv}; OUT=$(realpath -m "${2:-$(pwd)/evidence/source-audit/test-results}"); MOD="$SRC/common/collector"; mkdir -p "$OUT"
[ -d "$SRC" ] && [ -f "$MOD/go.mod" ] || { echo "tests not started: missing source/module $MOD" >&2; exit 2; }
start=$(date -u +%FT%TZ); set +e; (printf 'start=%s\nworkdir=%s\nsource=%s\n' "$start" "$MOD" "$SRC"; cd "$MOD"; go version; go test ./zip) >"$OUT/go-zip-tests.log" 2>&1; z=$?; (cd "$MOD"; go test ./safereader) >"$OUT/go-safereader-tests.log" 2>&1; q=$?; set -e; end=$(date -u +%FT%TZ)
printf 'suite\tpackage\tmodule\tstart\tend\tstatus\tstarted\n go-test\tzip\t%s\t%s\t%s\t%s\tyes\n go-test\tsafereader\t%s\t%s\t%s\t%s\tyes\n' "$MOD" "$start" "$end" "$z" "$MOD" "$start" "$end" "$q" > "$OUT/go-collector-tests-result.tsv"; [ "$z" -eq 0 ] && [ "$q" -eq 0 ]
