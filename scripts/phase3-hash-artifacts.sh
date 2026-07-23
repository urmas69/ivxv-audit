#!/usr/bin/env bash
set -Eeuo pipefail

if [[ $# -ne 2 ]]; then
  echo "usage: $0 ROOT OUTPUT" >&2
  exit 64
fi
root=$(realpath "$1")
output=$(realpath -m "$2")
mkdir -p "$output"
find "$root" -type f -size -100M -print0 | LC_ALL=C sort -z | while IFS= read -r -d '' file; do
  sha256sum "$file"
done > "$output/sha256sums.txt"
