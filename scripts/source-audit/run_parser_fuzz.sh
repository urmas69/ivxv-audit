#!/usr/bin/env bash
set -Eeuo pipefail
SRC=${1:-/home/audit/audit/ivxv}; OUT=$(realpath -m "${2:-$(pwd)/evidence/source-audit/fuzzing}"); MOD="$SRC/common/collector"; mkdir -p "$OUT"
[ -d "$SRC" ] && [ -f "$MOD/go.mod" ] || { echo "fuzz not started: missing source/module $MOD" >&2; exit 2; }
if ! rg -q '^func Fuzz' "$MOD/zip" --glob '*.go'; then echo 'fuzz not started: no supported Fuzz function in common/collector/zip' > "$OUT/zip-fuzz.log"; printf 'target=common/collector/zip\tmodule=%s\tstatus=4\tstarted=no\treason=no-fuzz-target\n' "$MOD" > "$OUT/results.tsv"; exit 4; fi
start=$(date -u +%FT%TZ); { printf 'start=%s\nworkdir=%s\nsource=%s\n' "$start" "$MOD" "$SRC"; cd "$MOD"; go version; go test ./zip -run '^$' -fuzz '^Fuzz' -fuzztime=10s; } >"$OUT/zip-fuzz.log" 2>&1; s=$?; end=$(date -u +%FT%TZ)
printf 'target=common/collector/zip\tmodule=%s\tstart=%s\tend=%s\tstatus=%s\tstarted=yes\n' "$MOD" "$start" "$end" "$s" >"$OUT/results.tsv"; exit "$s"
