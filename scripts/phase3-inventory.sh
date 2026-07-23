#!/usr/bin/env bash
set -Eeuo pipefail

if [[ $# -ne 2 ]]; then
  echo "usage: $0 SOURCE OUTPUT" >&2
  exit 64
fi
source=$(realpath "$1")
output=$(realpath -m "$2")
mkdir -p "$output"
{
  date -u +%Y-%m-%dT%H:%M:%SZ
  printf 'source=%s\n' "$source"
  printf 'commit=%s\n' "$(git -C "$source" rev-parse HEAD)"
  printf 'status=%q\n' "$(git -C "$source" status --porcelain=v1)"
  uname -a
  locale 2>&1 || true
  for tool in bash make git python3 go java javac gradle gcc dpkg-buildpackage debuild; do
    if command -v "$tool" >/dev/null 2>&1; then
      printf '\n[%s]\n' "$tool"
      command -v "$tool"
      "$tool" --version 2>&1 | head -n 3 || true
    else
      printf '\n[%s] NOT_INSTALLED\n' "$tool"
    fi
  done
  printf '\n[packages]\n'
  dpkg-query -W -f='${Package}\t${Version}\n' 2>&1 | LC_ALL=C sort || true
} > "$output/environment.txt"
git -C "$source" ls-tree -r --name-only HEAD | LC_ALL=C sort > "$output/tracked-files.txt"
git -C "$source" ls-tree -r HEAD -- '*.mk' 'Makefile' 'debian/rules' 'setup.py' > "$output/build-files.txt"
