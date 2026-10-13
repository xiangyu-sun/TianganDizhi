#!/usr/bin/env python3
"""Check App Store creative assets against Apple's spec before uploading.

    python3 check_assets.py fastlane/creative_assets

Classifies each image by aspect ratio and fails on: wrong size, alpha channel,
wrong format. Specs: developer.apple.com/help/app-store-connect/reference/
app-information/creative-assets-specifications (checked Oct 2026).
"""
import sys
from pathlib import Path

from PIL import Image

RULES = {  # name: (ratio, allowed sizes or (min, max), formats)
    "header 21:9": (21 / 9, [(3840, 1646)], {"PNG", "JPEG"}),
    "universal 16:9": (16 / 9, [(5244, 2950)], {"PNG"}),
    "search 3:2": (3 / 2, ((1920, 1280), (3840, 2560)), {"PNG", "JPEG"}),
}


def check(path: Path) -> list[str]:
    im = Image.open(path)
    w, h = im.size
    problems = []
    if im.mode in ("RGBA", "LA", "PA") or "transparency" in im.info:
        problems.append(f"has alpha ({im.mode}); flatten to RGB")
    kind = min(RULES, key=lambda k: abs(RULES[k][0] - w / h))
    ratio, sizes, formats = RULES[kind]
    if abs(ratio - w / h) > 0.01:
        problems.append(f"ratio {w / h:.3f} matches no placement")
    elif isinstance(sizes, tuple):
        (mnw, mnh), (mxw, mxh) = sizes
        if not (mnw <= w <= mxw and mnh <= h <= mxh):
            problems.append(f"{w}×{h} outside {mnw}×{mnh}–{mxw}×{mxh}")
    elif (w, h) not in sizes:
        problems.append(f"{w}×{h}, expected {sizes[0][0]}×{sizes[0][1]}")
    if im.format not in formats:
        problems.append(f"{im.format} not allowed for {kind} ({', '.join(sorted(formats))})")
    print(f"{'✗' if problems else '✓'} {kind:15} {w}×{h} {path}")
    for p in problems:
        print(f"    {p}")
    return problems


if __name__ == "__main__":
    root = Path(sys.argv[1] if len(sys.argv) > 1 else ".")
    files = [p for p in sorted(root.rglob("*")) if p.suffix.lower() in {".png", ".jpg", ".jpeg"}
             and "contact_sheet" not in p.name]
    bad = sum(bool(check(p)) for p in files)
    print(f"\n{len(files) - bad}/{len(files)} pass")
    sys.exit(1 if bad else 0)
