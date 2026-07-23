#!/usr/bin/env python3
"""Fetch and hash direct Maven Central POM/JAR evidence without executing artifacts."""
import argparse, csv, datetime, hashlib, json, pathlib, urllib.request


def main():
    p = argparse.ArgumentParser()
    p.add_argument("output_dir", type=pathlib.Path)
    p.add_argument("coordinate", nargs="+", help="group:artifact:version")
    a = p.parse_args()
    a.output_dir.mkdir(parents=True, exist_ok=True)
    rows = []
    for coordinate in sorted(a.coordinate):
        group, artifact, version = coordinate.split(":")
        base = f"https://repo.maven.apache.org/maven2/{group.replace('.', '/')}/{artifact}/{version}/{artifact}-{version}"
        for kind in ("pom", "jar"):
            url = f"{base}.{kind}"
            try:
                with urllib.request.urlopen(url, timeout=120) as r:
                    body, status, final = r.read(), r.status, r.url
                rows.append({"coordinate": coordinate, "type": kind, "url": url,
                             "http_status": status, "final_url": final, "size": len(body),
                             "sha256": hashlib.sha256(body).hexdigest(), "result": "available"})
            except Exception as e:
                rows.append({"coordinate": coordinate, "type": kind, "url": url,
                             "http_status": "", "final_url": "", "size": "", "sha256": "",
                             "result": f"error:{type(e).__name__}:{e}"})
    with (a.output_dir / "maven-direct-artifacts.csv").open("w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, list(rows[0])); w.writeheader(); w.writerows(rows)
    (a.output_dir / "retrieval.json").write_text(json.dumps({
        "retrieval_utc": datetime.datetime.now(datetime.timezone.utc).isoformat(),
        "tool": "Python urllib", "python": __import__("sys").version,
        "repository": "Maven Central canonical host", "note": "Artifacts were hashed but not stored or executed.",
    }, indent=2, sort_keys=True) + "\n")


if __name__ == "__main__":
    main()
