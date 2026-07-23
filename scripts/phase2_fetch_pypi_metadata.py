#!/usr/bin/env python3
"""Record immutable PyPI release-file metadata without installing packages."""
import argparse
import csv
import datetime
import hashlib
import json
import pathlib
import urllib.request


def main():
    p = argparse.ArgumentParser()
    p.add_argument("output_dir", type=pathlib.Path)
    p.add_argument("spec", nargs="+", help="distribution==version")
    args = p.parse_args()
    args.output_dir.mkdir(parents=True, exist_ok=True)
    rows = []
    for spec in sorted(args.spec, key=str.lower):
        name, version = spec.rsplit("==", 1)
        api = f"https://pypi.org/pypi/{name}/{version}/json"
        with urllib.request.urlopen(api, timeout=60) as response:
            body = response.read()
            status = response.status
            final_url = response.url
        (args.output_dir / f"{name}-{version}.json").write_bytes(body)
        data = json.loads(body)
        for item in sorted(data["urls"], key=lambda x: x["filename"]):
            rows.append({
                "name": name, "version": version, "filename": item["filename"],
                "packagetype": item["packagetype"], "python_version": item["python_version"],
                "requires_python": item.get("requires_python") or "",
                "url": item["url"], "size": item["size"],
                "sha256": item["digests"]["sha256"], "upload_time_iso_8601": item["upload_time_iso_8601"],
                "yanked": item["yanked"], "metadata_api": api,
                "metadata_http_status": status, "metadata_final_url": final_url,
                "metadata_sha256": hashlib.sha256(body).hexdigest(),
            })
    fields = list(rows[0]) if rows else []
    with (args.output_dir / "pypi-release-files.csv").open("w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fields)
        w.writeheader()
        w.writerows(rows)
    record = {
        "retrieval_utc": datetime.datetime.now(datetime.timezone.utc).isoformat(),
        "tool": "Python urllib", "python": __import__("sys").version,
        "note": "Hashes are registry-published SHA-256 values; this script does not execute artifacts.",
    }
    (args.output_dir / "retrieval.json").write_text(json.dumps(record, indent=2, sort_keys=True) + "\n")


if __name__ == "__main__":
    main()
