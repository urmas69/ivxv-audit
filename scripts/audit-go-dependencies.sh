#!/usr/bin/env bash
set -Eeuo pipefail

if [[ $# -ne 2 ]]; then
  echo "usage: $0 IVXV_SOURCE OUTPUT_DIRECTORY" >&2
  exit 64
fi

src=$(realpath "$1")
out=$(realpath -m "$2")
[[ -d "$src/.git" ]] || { echo "not an IVXV Git checkout: $src" >&2; exit 66; }
mkdir -p "$out"
download_dir=$(mktemp -d "${TMPDIR:-/tmp}/ivxv-go-provenance.XXXXXX")
trap 'rm -rf "$download_dir"' EXIT

{
  printf 'retrieved_utc=%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  printf 'script=%s\n' "$(realpath "$0")"
  printf 'source=%s\n' "$src"
  printf 'source_commit=%s\n' "$(git -C "$src" rev-parse HEAD)"
  printf 'curl=%s\n' "$(curl --version | head -1)"
  printf 'git=%s\n' "$(git --version)"
  if command -v go >/dev/null; then go version; else echo 'go=NOT INSTALLED'; fi
} >"$out/environment.txt"

find "$src" -type f \( -name go.mod -o -name go.sum \) -printf '%P\n' |
  LC_ALL=C sort >"$out/published-go-files.txt"

{
  echo -e 'module\tversion\tgo_sum_h1\tgo_mod_h1\tdeclared_in'
  find "$src" -type f -name go.sum -print0 | sort -z |
    xargs -0 awk '
      $2 ~ /\/go.mod$/ {
        v=$2; sub("/go.mod$", "", v); mod[$1 SUBSEP v]=$3; files[$1 SUBSEP v]=files[$1 SUBSEP v] FILENAME ";"
      }
      $2 !~ /\/go.mod$/ {
        zip[$1 SUBSEP $2]=$3; files[$1 SUBSEP $2]=files[$1 SUBSEP $2] FILENAME ";"
      }
      END {
        for (k in files) {
          split(k,a,SUBSEP); f=files[k]; gsub("'"$src"'/","",f); sub(/;$/,"",f)
          print a[1] "\t" a[2] "\t" zip[k] "\t" mod[k] "\t" f
        }
      }' | LC_ALL=C sort -u
} >"$out/modules.tsv"

encode_path() {
  local s=$1 outp='' c i
  for ((i=0; i<${#s}; i++)); do
    c=${s:i:1}
    if [[ $c =~ [A-Z] ]]; then outp+="!${c,,}"; else outp+="$c"; fi
  done
  printf '%s' "$outp"
}

echo -e 'module\tversion\tkind\turl\thttp_status\tfinal_url\tsize\tsha256' >"$out/proxy-artifacts.tsv"
tail -n +2 "$out/modules.tsv" | cut -f1,2 | while IFS=$'\t' read -r module version; do
  encoded=$(encode_path "$module")
  safe=$(printf '%s@%s' "$module" "$version" | sed 's#[/@]#_#g')
  for kind in info mod zip; do
    url="https://proxy.golang.org/${encoded}/@v/${version}.${kind}"
    target="$download_dir/${safe}.${kind}"
    meta=$(curl --silent --show-error --location --max-time 30 --retry 2 \
      --output "$target" \
      --write-out '%{http_code}\t%{url_effective}\t%{size_download}' "$url" || true)
    IFS=$'\t' read -r status final_url size <<<"$meta"
    if [[ $status == 200 ]]; then
      sha=$(sha256sum "$target" | cut -d' ' -f1)
    else
      sha=''
      rm -f "$target"
    fi
    printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
      "$module" "$version" "$kind" "$url" "$status" "$final_url" "$size" "$sha"
  done
done >>"$out/proxy-artifacts.tsv"

# Report proxy-listed tivi.io/core versions independently of the required version.
curl --silent --show-error --location --dump-header "$out/tivi-core-list.headers" \
  --output "$out/tivi-core-list.txt" 'https://proxy.golang.org/tivi.io/core/@v/list' || true
