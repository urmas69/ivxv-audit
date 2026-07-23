#!/usr/bin/env bash
set -Eeuo pipefail
trap 'status=$?; printf "\nexit_status=%s\n" "$status"' EXIT

src=${1:-/home/audit/audit/ivxv}
commit=${2:-2785872f84dffb56bbecc41b096a7ee0f2876e64}

if [[ ! -d "$src/.git" ]]; then
    printf 'ERROR: not a Git repository: %s\n' "$src" >&2
    exit 2
fi
if ! git -C "$src" cat-file -e "${commit}^{commit}"; then
    printf 'ERROR: commit is not available: %s\n' "$commit" >&2
    exit 2
fi

printf 'timestamp_utc=%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
printf 'cwd=%s\n' "$PWD"
printf 'command=%q %q %q\n' "$0" "$src" "$commit"
printf 'source=%s\ncommit=%s\n' "$src" "$commit"
printf 'git_version=%s\n' "$(git --version)"
printf 'source_head=%s\n' "$(git -C "$src" rev-parse HEAD)"
printf 'source_status_begin\n'
git -C "$src" status --porcelain=v1
printf 'source_status_end\n'

printf '\n[common/external commits]\n'
git -C "$src" log --all --full-history --date=iso-strict \
    --format='%H%x09%ad%x09%an%x09%s' -- common/external

printf '\n[common/external name-status history]\n'
git -C "$src" log --all --full-history --name-status \
    --format='commit %H %ad %s' --date=iso-strict -- common/external

printf '\n[common/external objects across all refs]\n'
git -C "$src" rev-list --objects --all |
    awk '$2 == "common/external" || $2 ~ /^common\/external\// { print }' |
    LC_ALL=C sort -k2,2 -k1,1

printf '\n[fixed tree]\n'
git -C "$src" ls-tree -r -l "$commit" common/external

printf '\n[submodule metadata history]\n'
git -C "$src" log --all --full-history --date=iso-strict \
    --format='%H%x09%ad%x09%s' -- .gitmodules
git -C "$src" show "${commit}:.gitmodules"

printf '\n[historical file contents]\n'
for spec in \
    003282512343a08ec88ab547d4b1a8e83ac9369d:common/external/README.rst \
    9e36a72aaec7c6bf4602310aa6f346e5c128e68a:common/external/README.rst \
    8a432f7b8d4ed0bb0871f005f650c13bf3250766:common/external/.gitattributes \
    8a432f7b8d4ed0bb0871f005f650c13bf3250766:common/external/.gitignore \
    e5a6ceafc8fa373f79ff0a72b8e7ff62c731d84e:common/external/install_java_dep
do
    printf '%s\n' "--- $spec"
    git -C "$src" show "$spec"
done

printf '\n[ETCD bundle declarations at fixed commit]\n'
for path in storage/Makefile debian/ivxv-storage.install \
    debian/ivxv-storage.postinst debian/ivxv-storage.postrm debian/control
do
    printf '%s\n' "--- $path"
    git -C "$src" show "${commit}:${path}"
done

printf '\n[ETCD bundle introduction]\n'
git -C "$src" log --all -S'ivxv-storage_db.tar.gz' \
    --format='%H%x09%ad%x09%s' --date=iso-strict --all

printf '\n[OS declarations]\n'
git -C "$src" show "${commit}:debian/changelog" |
    sed -n '1,170p'
git -C "$src" show \
    "${commit}:Documentation/public/arhitektuur/kogumisteenus.rst" |
    sed -n '35,60p'

printf '\n[expected-negative build-environment file search]\n'
mapfile -t environment_files < <(
    git -C "$src" ls-tree -r --name-only "$commit" |
        awk 'BEGIN { IGNORECASE=1 }
            /(^|\/)(Dockerfile|Containerfile)(\.|$)/ ||
            /(^|\/)\.github\/workflows\// ||
            /(^|\/)(Jenkinsfile|\.gitlab-ci\.yml)$/ ||
            /(buildinfo|sources\.list|packer|vagrant|terraform)/ { print }' |
        LC_ALL=C sort
)
if ((${#environment_files[@]})); then
    printf '%s\n' "${environment_files[@]}"
else
    printf 'EXPECTED_NEGATIVE: no matching build-environment files\n'
fi

printf '\n[source state after read-only inspection]\n'
printf 'source_head=%s\n' "$(git -C "$src" rev-parse HEAD)"
printf 'source_status_begin\n'
git -C "$src" status --porcelain=v1
printf 'source_status_end\n'
