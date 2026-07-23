#!/usr/bin/env python3
"""Validate the canonical Phase 2 dependency provenance CSV."""

import csv
import sys
from pathlib import Path

REQUIRED = [
    "ecosystem",
    "name",
    "version",
    "required_by",
    "declared_at",
    "expected_path",
    "original_source",
    "verified_source",
    "availability_status",
    "sha256",
    "signature",
    "license",
    "evidence",
    "notes",
]
STATUSES = {
    "public-verifiable",
    "public-unpinned",
    "public-historical-only",
    "uncertain-origin",
    "apparently-internal",
    "unavailable",
    "not-reconstructable-from-published-information",
}


def main() -> int:
    path = Path(sys.argv[1] if len(sys.argv) > 1 else
                "evidence/dependency-manifests/dependency-provenance.csv")
    with path.open(newline="", encoding="utf-8") as stream:
        reader = csv.DictReader(stream)
        if reader.fieldnames != REQUIRED:
            print(f"{path}: invalid columns: {reader.fieldnames}", file=sys.stderr)
            return 1
        rows = list(reader)

    errors = 0
    for line, row in enumerate(rows, 2):
        if not row["ecosystem"] or not row["name"]:
            print(f"{path}:{line}: ecosystem and name are required", file=sys.stderr)
            errors += 1
        if row["availability_status"] not in STATUSES:
            print(
                f"{path}:{line}: invalid classification "
                f"{row['availability_status']!r}",
                file=sys.stderr,
            )
            errors += 1

    keys = [(r["ecosystem"], r["name"], r["version"], r["required_by"])
            for r in rows]
    if keys != sorted(keys, key=lambda value: tuple(x.casefold() for x in value)):
        print(f"{path}: rows are not deterministically sorted", file=sys.stderr)
        errors += 1

    if errors:
        return 1
    print(f"{path}: {len(rows)} rows valid")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
