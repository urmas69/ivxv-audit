#!/usr/bin/env bash
set -Eeuo pipefail

if [[ $# -ne 3 ]]; then
  echo "usage: $0 LOG_DIRECTORY PREFIX OUTPUT" >&2
  exit 64
fi
directory=$(realpath "$1")
prefix=$2
output=$(realpath -m "$3")
mkdir -p "$(dirname "$output")"
printf 'track\tmodule\texit_status\tfirst_failure\tlog\n' > "$output"
for log in "$directory"/${prefix}-*.txt; do
  [[ -f "$log" ]] || continue
  module=${log##*${prefix}-}
  module=${module%.txt}
  status=$(awk -F': ' '/^Exit status:/ {print $2; exit}' "$log")
  failure=$(rg -m1 '^(FAIL|--- FAIL|.*error:|.*undefined:|.*unrecognized import path)' "$log" || true)
  printf '%s\t%s\t%s\t%s\t%s\n' "$prefix" "$module" "$status" "$failure" "${log##*/}" >> "$output"
done
