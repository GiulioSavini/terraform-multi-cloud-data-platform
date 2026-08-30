#!/usr/bin/env bash
#
# One version constraint per provider, repository-wide.
#
# This repository once pinned hashicorp/google at "~> 5.0" in seven modules and
# "~> 6.0" in seven others, with azurerm split the same way between 3.x and 4.x.
# No root could resolve both, so every example failed at `terraform init` — the
# clearest possible evidence that the code had never been run.
#
# A drifted pin is invisible in review and fatal at init. This makes it visible
# in CI instead.

set -euo pipefail

python3 - "$@" <<'PY'
import re, sys, pathlib, collections

pins = collections.defaultdict(set)
pattern = re.compile(
    r'source\s*=\s*"([^"]+)"\s*\n\s*version\s*=\s*"([^"]+)"'
)

for path in pathlib.Path(".").rglob("versions.tf"):
    if ".terraform" in path.parts:
        continue
    for source, version in pattern.findall(path.read_text()):
        pins[source].add((version, str(path)))

conflicts = False
for source in sorted(pins):
    versions = {v for v, _ in pins[source]}
    if len(versions) > 1:
        conflicts = True
        print(f"CONFLICT: {source} is pinned {len(versions)} different ways:")
        for version in sorted(versions):
            files = sorted(p for v, p in pins[source] if v == version)
            print(f'    "{version}"  in {len(files)} file(s), e.g. {files[0]}')

if conflicts:
    print("\nPick one constraint per provider and apply it everywhere.", file=sys.stderr)
    sys.exit(1)

print(f"Provider pins agree ({len(pins)} providers).")
PY
