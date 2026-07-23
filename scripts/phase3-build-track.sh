#!/usr/bin/env bash
set -Eeuo pipefail

if [[ $# -ne 3 ]]; then
  echo "usage: $0 SOURCE OUTPUT_PREFIX TRACK" >&2
  exit 64
fi
source=$(realpath "$1")
prefix=$(realpath -m "$2")
track=$3
mkdir -p "$(dirname "$prefix")"
log="${prefix}-${track}.log"
{
  date -u +%Y-%m-%dT%H:%M:%SZ
  printf 'track=%s\nsource=%s\ncommit=%s\n' "$track" "$source" "$(git -C "$source" rev-parse HEAD)"
  printf 'command=make clean && make && make test\n'
  set +e
  (cd "$source" && make clean && make && make test)
  status=$?
  set -e
  printf 'exit_status=%s\n' "$status"
  exit "$status"
} > "$log" 2>&1
