#!/usr/bin/env python3
"""Fetch deps.dev resolved Maven graphs for exact direct coordinates."""
import argparse, csv, datetime, hashlib, json, pathlib, urllib.parse, urllib.request


def main():
    p = argparse.ArgumentParser()
    p.add_argument("output_dir", type=pathlib.Path)
    p.add_argument("coordinate", nargs="+")
    a = p.parse_args(); a.output_dir.mkdir(parents=True, exist_ok=True)
    rows = []
    for coordinate in sorted(a.coordinate):
        group, artifact, version = coordinate.split(":")
        package = urllib.parse.quote(f"{group}:{artifact}", safe="")
        url = f"https://api.deps.dev/v3/systems/maven/packages/{package}/versions/{urllib.parse.quote(version, safe='')}:dependencies"
        with urllib.request.urlopen(url, timeout=120) as r:
            body, status, final = r.read(), r.status, r.url
        data = json.loads(body)
        (a.output_dir / f"{group}.{artifact}-{version}.depsdev.json").write_bytes(body)
        for node in data.get("nodes", []):
            key = node["versionKey"]
            rows.append({"root": coordinate, "name": key["name"], "version": key["version"],
                         "relation": node.get("relation", ""), "bundled": node.get("bundled", False),
                         "errors": json.dumps(node.get("errors", []), sort_keys=True),
                         "graph_url": url, "graph_http_status": status, "graph_final_url": final,
                         "graph_sha256": hashlib.sha256(body).hexdigest()})
    rows.sort(key=lambda x: (x["root"], x["name"], x["version"]))
    with (a.output_dir / "maven-resolved-graphs.csv").open("w", newline="", encoding="utf-8") as f:
        w=csv.DictWriter(f, list(rows[0])); w.writeheader(); w.writerows(rows)
    (a.output_dir / "retrieval.json").write_text(json.dumps({
        "retrieval_utc": datetime.datetime.now(datetime.timezone.utc).isoformat(),
        "source": "deps.dev API (secondary resolved-graph evidence)",
        "python": __import__("sys").version,
    }, indent=2, sort_keys=True) + "\n")


if __name__ == "__main__":
    main()
