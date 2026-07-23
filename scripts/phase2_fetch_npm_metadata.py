#!/usr/bin/env python3
"""Fetch npm version metadata and hash its public tarball without installing it."""
import argparse, csv, datetime, hashlib, json, pathlib, urllib.parse, urllib.request


def main():
    p = argparse.ArgumentParser()
    p.add_argument("output_dir", type=pathlib.Path)
    p.add_argument("spec", nargs="+", help="package@exact-version")
    a = p.parse_args()
    a.output_dir.mkdir(parents=True, exist_ok=True)
    rows = []
    for spec in sorted(a.spec):
        name, version = spec.rsplit("@", 1)
        api = "https://registry.npmjs.org/" + urllib.parse.quote(name, safe="@/") + "/" + urllib.parse.quote(version, safe="")
        with urllib.request.urlopen(api, timeout=60) as r:
            body, status, final = r.read(), r.status, r.url
        data = json.loads(body)
        tar_url = data["dist"]["tarball"]
        with urllib.request.urlopen(tar_url, timeout=120) as r:
            tar, tar_status, tar_final = r.read(), r.status, r.url
        safe = name.replace("/", "__")
        (a.output_dir / f"{safe}-{version}.json").write_bytes(body)
        rows.append({
            "name": name, "version": version, "license": data.get("license", ""),
            "metadata_url": api, "metadata_http_status": status, "metadata_final_url": final,
            "metadata_sha256": hashlib.sha256(body).hexdigest(), "tarball_url": tar_url,
            "tarball_http_status": tar_status, "tarball_final_url": tar_final,
            "tarball_size": len(tar), "tarball_sha256": hashlib.sha256(tar).hexdigest(),
            "npm_sha1": data["dist"].get("shasum", ""), "npm_integrity": data["dist"].get("integrity", ""),
        })
    with (a.output_dir / "npm-artifacts.csv").open("w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, list(rows[0])); w.writeheader(); w.writerows(rows)
    (a.output_dir / "retrieval.json").write_text(json.dumps({
        "retrieval_utc": datetime.datetime.now(datetime.timezone.utc).isoformat(),
        "tool": "Python urllib", "python": __import__("sys").version,
        "note": "Tarballs were hashed but neither stored nor executed.",
    }, indent=2, sort_keys=True) + "\n")


if __name__ == "__main__":
    main()
