#!/usr/bin/env python3
"""Build deterministic Phase 2 ecosystem manifests from fixed-commit declarations."""
import csv, pathlib

ROOT = pathlib.Path(__file__).resolve().parents[1]
EVID = ROOT / "evidence"


def write(path, rows):
    path.parent.mkdir(parents=True, exist_ok=True)
    fields = ["ecosystem", "name", "version", "required_by", "declared_at", "expected_path",
              "original_source", "verified_source", "availability_status", "sha256",
              "signature", "license", "evidence", "notes"]
    with path.open("w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fields); w.writeheader()
        w.writerows(sorted(rows, key=lambda r: (r["name"].lower(), r["version"])))


def artifact_hash(path, name, version, field):
    with path.open(encoding="utf-8") as f:
        for r in csv.DictReader(f):
            if r["name"].lower() == name.lower() and r["version"] == version:
                if "filename" not in r or r.get("packagetype") == "sdist":
                    return r[field]
    return ""


def main():
    doc = "Documentation/public/arhitektuur/tehnoloogiad.rst"
    pyhash = EVID / "hashes/python/pypi-release-files.csv"
    py = [
        ("bottle","0.13.2","MIT"), ("docopt","0.6.2","MIT"), ("Jinja2","3.1.4","BSD-3-Clause"),
        ("jsonschema","4.23.0","MIT"), ("pyOpenSSL","24.2.1","Apache-2.0"),
        ("fasteners","0.19","Apache-2.0"), ("python-crontab","3.3.0","LGPL-3.0-only"),
        ("python-dateutil","2.9.0","BSD-3-Clause"), ("python-debian","0.1.49","GPL-2.0-or-later"),
        ("PyYAML","6.0.2","MIT"), ("schematics","2.1.1","BSD-3-Clause"),
    ]
    rows = []
    for n,v,lic in py:
        rows.append(dict(ecosystem="python", name=n, version=v, required_by="ivxv-admin",
            declared_at=("setup.py (name only); " if n.lower() != "schematics" else
                         "Python imports; omitted from setup.py; ") + doc,
            expected_path="common/external/python/wheels and common/external/python/requirements.txt",
            original_source=f"https://pypi.org/project/{n}/{v}/",
            verified_source=f"https://pypi.org/pypi/{n}/{v}/json",
            availability_status="public-verifiable", sha256=artifact_hash(pyhash,n,v,"sha256"),
            signature="No PyPI release signature established", license=lic,
            evidence="evidence/hashes/python/pypi-release-files.csv",
            notes="SHA-256 is for the sdist. Exact version is documented, but setup.py does not pin it; missing wheel/requirements tree prevents proof of the originally selected wheel set."))
    rows.append(dict(ecosystem="python", name="setuptools", version="UNKNOWN", required_by="ivxv-admin",
        declared_at="setup.py", expected_path="common/external/python/wheels and requirements.txt",
        original_source="https://pypi.org/project/setuptools/", verified_source="",
        availability_status="not-reconstructable-from-published-information", sha256="", signature="",
        license="MIT", evidence="setup.py; debian/python3-ivxv-common.install",
        notes="Unpinned and absent from the architecture version table; no deleted requirements file is tracked."))
    write(EVID / "dependency-manifests/python/python-dependencies.csv", rows)

    npm = EVID / "hashes/javascript/npm-artifacts.csv"
    js = [
        ("bootstrap","3.4.1","bootstrap","MIT"),
        ("jquery","3.7.1","jquery","MIT"),
        ("DataTables","2.3.2","datatables.net","MIT"),
        ("Font Awesome","6.7.2","@fortawesome/fontawesome-free","CC-BY-4.0 AND MIT AND OFL-1.1"),
        ("metisMenu","1.1.3","metismenu","MIT"),
        ("SB Admin 2","3.3.7+1","startbootstrap-sb-admin-2","MIT"),
    ]
    rows = []
    for n,v,pkg,lic in js:
        npm_v = "3.3.7" if n == "SB Admin 2" else v
        rows.append(dict(ecosystem="javascript", name=n, version=v, required_by="ivxv-admin web UI",
            declared_at=doc, expected_path="common/external/js/" + {
                "bootstrap":"bootstrap","jquery":"jquery","DataTables":"datatables",
                "Font Awesome":"font-awesome","metisMenu":"startbootstrap-sb-admin-2/vendor",
                "SB Admin 2":"startbootstrap-sb-admin-2"}[n],
            original_source={"SB Admin 2":"https://github.com/StartBootstrap/startbootstrap-sb-admin-2",
                             "DataTables":"https://github.com/DataTables/DataTablesSrc"}.get(n, f"https://www.npmjs.com/package/{pkg}"),
            verified_source=f"https://registry.npmjs.org/{pkg}/{npm_v}",
            availability_status="public-verifiable" if n != "SB Admin 2" else "public-historical-only",
            sha256=artifact_hash(npm,pkg,npm_v,"tarball_sha256"), signature="npm integrity and SHA-1 recorded; no detached signature",
            license=lic, evidence="evidence/hashes/javascript/npm-artifacts.csv",
            notes=("Documented +1 maps to the historical WebJar release; npm tarball is upstream 3.3.7 and is not asserted byte-identical to the absent expected tree."
                   if n == "SB Admin 2" else "Registry tarball hash does not prove byte identity of the absent, unpacked IVXV external tree.")))
    write(EVID / "dependency-manifests/javascript/javascript-dependencies.csv", rows)

    maven = EVID / "hashes/java/maven-direct-artifacts.csv"
    direct = []
    with maven.open(encoding="utf-8") as f:
        for r in csv.DictReader(f):
            if r["type"] == "jar":
                g,a,v=r["coordinate"].split(":")
                direct.append(dict(ecosystem="maven", name=f"{g}:{a}", version=v,
                    required_by="common/java (runtime or tests)", declared_at="common/java/build.gradle",
                    expected_path="common/external/java Gradle user home cache",
                    original_source="https://central.sonatype.com/artifact/"+g+"/"+a+"/"+v,
                    verified_source=r["url"], availability_status="public-verifiable" if r["result"]=="available" else "unavailable",
                    sha256=r["sha256"], signature="Maven Central sidecar signatures not evaluated",
                    license="See upstream POM", evidence="evidence/hashes/java/maven-direct-artifacts.csv",
                    notes="Direct declaration. Gradle lockfiles and dependency-verification metadata are absent."))
    write(EVID / "dependency-manifests/java/maven-direct-dependencies.csv", direct)


if __name__ == "__main__":
    main()
