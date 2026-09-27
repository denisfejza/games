#!/usr/bin/env python3
"""Adds or updates strings in both ARB files.

Usage (from app/):  python3 tool/add_strings.py strings.json
strings.json: {"key": ["English", "Shqip"], "key2": ["{n} min", "{n} min", {"n": {"type": "int"}}]}
Then run: dart run tool/gen_lookup.dart && flutter gen-l10n
Albanian text needs native-speaker review before release.
"""
import json, sys

def main(path, rename=None):
    new = json.load(open(path, encoding="utf-8"))
    for locale, idx in (("en", 0), ("sq", 1)):
        p = f"lib/l10n/app_{locale}.arb"
        arb = json.load(open(p, encoding="utf-8"))
        for old, newk in (rename or {}).items():
            if old in arb:
                arb[newk] = arb.pop(old)
            if f"@{old}" in arb:
                arb[f"@{newk}"] = arb.pop(f"@{old}")
        for key, vals in new.items():
            arb[key] = vals[idx]
            if locale == "en" and len(vals) > 2:
                arb[f"@{key}"] = {"placeholders": vals[2]}
        json.dump(arb, open(p, "w", encoding="utf-8"), ensure_ascii=False, indent=2)
        open(p, "a").write("\n")

if __name__ == "__main__":
    rename = json.loads(sys.argv[2]) if len(sys.argv) > 2 else None
    main(sys.argv[1], rename)
