#!/usr/bin/env bash
set -Eeuo pipefail
SRC=${1:-/home/audit/audit/ivxv}; OUT=$(realpath -m "${2:-$(pwd)/evidence/source-audit/static-analysis}"); MOD="$SRC/common/collector"; mkdir -p "$OUT"
[ -d "$SRC" ] && [ -f "$MOD/go.mod" ] || { echo "analysis not started: missing source/module $MOD" >&2; exit 2; }
start=$(date -u +%FT%TZ); set +e; (printf 'start=%s\nworkdir=%s\nsource=%s\n' "$start" "$MOD" "$SRC"; cd "$MOD"; go version; go vet ./zip) >"$OUT/go-vet-zip.log" 2>&1; z=$?; (cd "$MOD"; go vet ./safereader) >"$OUT/go-vet-safereader.log" 2>&1; q=$?; set -e; end=$(date -u +%FT%TZ)
printf 'tool\tpackage\tmodule\tstart\tend\tstatus\tstarted\n go-vet\tzip\t%s\t%s\t%s\t%s\tyes\n go-vet\tsafereader\t%s\t%s\t%s\t%s\tyes\n' "$MOD" "$start" "$end" "$z" "$MOD" "$start" "$end" "$q" > "$OUT/go-vet-result.tsv"; [ "$z" -eq 0 ] && [ "$q" -eq 0 ]
