#!/usr/bin/env bash
set -Eeuo pipefail

if [[ $# -ne 2 ]]; then
  echo "usage: $0 SOURCE OUTPUT" >&2
  exit 64
fi
source=$(realpath "$1")
output=$(realpath -m "$2")
mkdir -p "$output"
find "$source" -type f \( -name '*_test.go' -o -name '*Test.java' -o -name 'test_*.py' \) \
  -printf '%P\n' | LC_ALL=C sort > "$output/discovered-tests.txt"
{
  date -u +%Y-%m-%dT%H:%M:%SZ
  printf 'source=%s\ncommit=%s\n' "$source" "$(git -C "$source" rev-parse HEAD)"
  if command -v go >/dev/null 2>&1; then
    (cd "$source" && go test ./...)
  else
    echo 'go test: NOT EXECUTED (go unavailable)'
  fi
  if [[ -d "$source/tests" ]]; then
    (cd "$source" && python3 -m unittest discover -v)
  else
    echo 'python tests: NOT EXECUTED (tests directory absent)'
  fi
} > "$output/execution.log" 2>&1 || true
