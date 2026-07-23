#!/usr/bin/env bash
set -Eeuo pipefail

if [[ $# -ne 2 ]]; then
  echo "usage: $0 BUILD_ROOT OUTPUT" >&2
  exit 64
fi
root=$(realpath "$1")
output=$(realpath -m "$2")
mkdir -p "$(dirname "$output")"
find "$root" -type f \( -name '*.jar' -o -name '*.zip' -o -name '*.tar' \
  -o -name '*.tar.gz' -o -path '*/bin/*' \) -printf '%P\t%s\n' |
  LC_ALL=C sort > "$output"
