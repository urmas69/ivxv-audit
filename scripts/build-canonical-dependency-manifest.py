#!/usr/bin/env python3
"""Build the canonical, deterministically sorted Phase 2 CSV."""

import csv
import sys
from pathlib import Path

FIELDS = [
    "ecosystem", "name", "version", "required_by", "declared_at",
    "expected_path", "original_source", "verified_source",
    "availability_status", "sha256", "signature", "license", "evidence",
    "notes",
]


def read_csv(path):
    with path.open(newline="", encoding="utf-8") as stream:
        return list(csv.DictReader(stream))


def main():
    root = Path(sys.argv[1] if len(sys.argv) > 1 else ".").resolve()
    manifest_dir = root / "evidence/dependency-manifests"
    rows = []
    for relative in [
        "external-etcd-os.csv",
        "java/maven-direct-dependencies.csv",
        "python/python-dependencies.csv",
        "javascript/javascript-dependencies.csv",
    ]:
        rows.extend(read_csv(manifest_dir / relative))

    proxy = {}
    with (root / "evidence/go/proxy-artifacts.tsv").open(
            newline="", encoding="utf-8") as stream:
        for row in csv.DictReader(stream, delimiter="\t"):
            if row["kind"] == "zip":
                proxy[(row["module"], row["version"])] = row

    with (root / "evidence/go/declared-modules.tsv").open(
            newline="", encoding="utf-8") as stream:
        for item in csv.DictReader(stream, delimiter="\t"):
            module, version = item["module"], item["version"]
            artifact = proxy.get((module, version), {})
            local = module.startswith("ivxv.ee/")
            tivi = module == "tivi.io/core"
            if tivi:
                status = "not-reconstructable-from-published-information"
                verified = "Go proxy returned HTTP 404 on 2026-07-23"
            elif local:
                status = "public-verifiable"
                verified = "fixed IVXV Git tree via relative replace"
            elif artifact.get("http_status") == "200":
                status = "public-verifiable"
                verified = artifact.get("final_url", "")
            else:
                status = "uncertain-origin"
                verified = "not tested in partial proxy run"
            rows.append({
                "ecosystem": "go",
                "name": module,
                "version": version,
                "required_by": item["required_by"],
                "declared_at": item["declared_at"],
                "expected_path": "common/external/go module cache",
                "original_source": (
                    "fixed IVXV Git tree" if local else
                    f"https://proxy.golang.org/{module}/@v/"
                ),
                "verified_source": verified,
                "availability_status": status,
                "sha256": artifact.get("sha256", ""),
                "signature": (
                    "Git commit identity" if local else
                    "Go checksum/SumDB model; no detached archive signature"
                ),
                "license": "unknown",
                "evidence": (
                    "evidence/go/declared-modules.tsv;"
                    " evidence/go/proxy-artifacts.tsv"
                ),
                "notes": (
                    f"go.sum ZIP hash {item['go_sum_h1'] or 'absent'}; "
                    f"go.mod hash {item['go_mod_h1'] or 'absent'}; "
                    f"indirect={item['indirect']}; "
                    f"verification={item['verification_status']}"
                ),
            })

    graph_seen = set()
    graph_path = manifest_dir / "java/graphs/maven-resolved-graphs.csv"
    for item in read_csv(graph_path):
        key = (item["name"], item["version"])
        if item["relation"] == "SELF" or key in graph_seen:
            continue
        graph_seen.add(key)
        rows.append({
            "ecosystem": "maven-transitive",
            "name": item["name"],
            "version": item["version"],
            "required_by": item["root"],
            "declared_at": "transitive graph reconstructed through deps.dev",
            "expected_path": "common/external/java Gradle user home cache",
            "original_source": "Maven Central project metadata",
            "verified_source": item["graph_url"],
            "availability_status": "public-verifiable",
            "sha256": "",
            "signature": "not evaluated",
            "license": "not exhaustively evaluated",
            "evidence": (
                "evidence/dependency-manifests/java/graphs/"
                "maven-resolved-graphs.csv"
            ),
            "notes": (
                "Secondary graph evidence; does not prove the contents of the "
                "absent original Gradle cache."
            ),
        })

    rows.extend([
        {
            "ecosystem": "gradle",
            "name": "Gradle binary distribution",
            "version": "8.11",
            "required_by": "common/java",
            "declared_at": "common/java/javavar.mk",
            "expected_path": "common/external/gradle-8.11",
            "original_source": "https://services.gradle.org/distributions/gradle-8.11-bin.zip",
            "verified_source": "official Gradle distribution and checksum",
            "availability_status": "public-verifiable",
            "sha256": "57dafb5c2622c6cc08b993c85b7c06956a2f53536432a30ead46166dbca0f1e9",
            "signature": "no adjacent detached ZIP signature established",
            "license": "Apache-2.0",
            "evidence": "evidence/hashes/gradle/gradle-8.11-bin.txt",
            "notes": "IVXV publishes the version but not the checksum or wrapper.",
        },
        {
            "ecosystem": "python-transitive",
            "name": "hash-pinned wheel closure",
            "version": "unknown",
            "required_by": "ivxv-admin",
            "declared_at": "debian/rules references absent requirements.txt",
            "expected_path": "common/external/python/{requirements.txt,wheels/}",
            "original_source": "PyPI and possibly OS-specific wheels",
            "verified_source": "none",
            "availability_status": "not-reconstructable-from-published-information",
            "sha256": "",
            "signature": "unknown",
            "license": "multiple",
            "evidence": "evidence/dependency-manifests/jvm-python-javascript-findings.md",
            "notes": "Missing requirements file prevents unique wheel and transitive version selection.",
        },
        {
            "ecosystem": "javascript-bundle",
            "name": "unpacked vendor tree",
            "version": "unknown composition",
            "required_by": "ivxv-admin web UI",
            "declared_at": "debian packaging and HTML paths",
            "expected_path": "common/external/js",
            "original_source": "multiple upstream distributions",
            "verified_source": "none",
            "availability_status": "not-reconstructable-from-published-information",
            "sha256": "",
            "signature": "unknown",
            "license": "multiple",
            "evidence": "evidence/dependency-manifests/jvm-python-javascript-findings.md",
            "notes": "No lock/manifest identifies copied, rebuilt, minified, font, theme, or plugin files.",
        },
    ])

    normalized = [{field: row.get(field, "") for field in FIELDS}
                  for row in rows]
    normalized.sort(key=lambda row: tuple(
        row[field].casefold()
        for field in ("ecosystem", "name", "version", "required_by")
    ))
    output = manifest_dir / "dependency-provenance.csv"
    with output.open("w", newline="", encoding="utf-8") as stream:
        writer = csv.DictWriter(stream, fieldnames=FIELDS, lineterminator="\n")
        writer.writeheader()
        writer.writerows(normalized)
    print(f"{output}: wrote {len(normalized)} rows")


if __name__ == "__main__":
    main()
