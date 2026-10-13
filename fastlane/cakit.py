"""Shared helpers for App Store creative assets (fall 2026 Asset Library).

Copy this file and render_text.swift next to the project's creative_assets.py
(usually fastlane/). It has no project knowledge; the project script owns copy,
colors and layout.

Specs (developer.apple.com/help/app-store-connect/reference/app-information/
creative-assets-specifications, checked Oct 2026):
  header  21:9  3840×1646                  PNG/JPEG, no alpha
  search  3:2   1920×1280 – 3840×2560      PNG/JPEG, no alpha
"""
from __future__ import annotations

import json
import math
import subprocess
import tempfile
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter

KIT = Path(__file__).resolve().parent
HEADER_SIZE = (3840, 1646)
SEARCH_SIZE = (3840, 2560)
RTL_LANGS = {"ar", "he", "fa", "ur"}


def is_rtl(locale: str) -> bool:
    return locale.split("-")[0] in RTL_LANGS


def text_lang(locale: str) -> str:
    """Language tag for CoreText: keep the script for zh, drop the region otherwise."""
    return locale if locale.startswith("zh") else locale.split("-")[0]


# MARK: - Backgrounds

def linear_gradient(size, top, bottom) -> Image.Image:
    w, h = size
    col = Image.new("RGB", (1, h))
    for y in range(h):
        t = y / max(h - 1, 1)
        col.putpixel((0, y), tuple(round(a + (b - a) * t) for a, b in zip(top, bottom)))
    return col.resize(size)


def radial_gradient(size, inner, outer, center=(0.5, 0.45), falloff=1.4) -> Image.Image:
    """Soft glow; rendered small and upscaled because it's smooth."""
    w, h = size
    sw, sh = 384, max(1, round(384 * h / w))
    img = Image.new("RGB", (sw, sh))
    cx, cy = center[0] * sw, center[1] * sh
    maxd = math.hypot(max(cx, sw - cx), max(cy, sh - cy))
    px = img.load()
    for y in range(sh):
        for x in range(sw):
            t = min(1.0, math.hypot(x - cx, y - cy) / maxd) ** falloff
            px[x, y] = tuple(round(inner[i] + (outer[i] - inner[i]) * t) for i in range(3))
    return img.resize(size, Image.BICUBIC)


# MARK: - Compositing

def rounded(img: Image.Image, radius: int) -> Image.Image:
    img = img.convert("RGBA")
    mask = Image.new("L", img.size, 0)
    ImageDraw.Draw(mask).rounded_rectangle((0, 0, *img.size), radius, fill=255)
    img.putalpha(Image.composite(mask, Image.new("L", img.size, 0), img.getchannel("A")))
    return img


def paste_with_shadow(canvas, img, xy, blur=40, offset=None, alpha=150):
    offset = blur // 2 if offset is None else offset
    pad = blur * 3
    sh = Image.new("RGBA", (img.width + 2 * pad, img.height + 2 * pad), (0, 0, 0, 0))
    sh.paste((0, 0, 0, alpha), (pad, pad), img.getchannel("A"))
    sh = sh.filter(ImageFilter.GaussianBlur(blur))
    canvas.alpha_composite(sh, (int(xy[0] - pad), int(xy[1] - pad + offset)))
    canvas.alpha_composite(img, (int(xy[0]), int(xy[1])))


def fit_height(img, height):
    return img.resize((round(img.width * height / img.height), height), Image.LANCZOS)


def fit_width(img, width):
    return img.resize((width, round(img.height * width / img.width)), Image.LANCZOS)


def cover(img: Image.Image, size) -> Image.Image:
    """Scale and centre-crop to fill `size` (like CSS object-fit: cover)."""
    img = img.convert("RGB")
    s = max(size[0] / img.width, size[1] / img.height)
    img = img.resize((math.ceil(img.width * s), math.ceil(img.height * s)), Image.LANCZOS)
    x, y = (img.width - size[0]) // 2, (img.height - size[1]) // 2
    return img.crop((x, y, x + size[0], y + size[1]))


# MARK: - Device mockups (simple, generic; no Apple product imagery)

def tv_set(screen: Image.Image, width: int, stand=True) -> Image.Image:
    """A flat-panel TV showing `screen` (16:9): thin black bezel, optional small stand."""
    bezel = max(6, width // 90)
    inner_w = width - 2 * bezel
    inner_h = round(inner_w * 9 / 16)
    panel_h = inner_h + 2 * bezel
    stand_h = max(10, width // 30) if stand else 0
    tv = Image.new("RGBA", (width, panel_h + stand_h), (0, 0, 0, 0))
    d = ImageDraw.Draw(tv)
    d.rounded_rectangle((0, 0, width, panel_h), bezel * 2, fill=(10, 10, 12, 255))
    tv.alpha_composite(screen.convert("RGBA").resize((inner_w, inner_h), Image.LANCZOS), (bezel, bezel))
    if stand:
        foot = width // 4
        d.rounded_rectangle(((width - foot) // 2, panel_h, (width + foot) // 2, panel_h + stand_h),
                            stand_h // 3, fill=(24, 24, 28, 255))
    return tv


def phone(screen: Image.Image, height: int, bezel_color=(14, 14, 16)) -> Image.Image:
    """A generic phone: black rounded body around `screen` (scaled to fill, ~9:19.5)."""
    bezel = max(4, height // 60)
    inner_h = height - 2 * bezel
    inner_w = round(inner_h * 9 / 19.5)
    body = Image.new("RGBA", (inner_w + 2 * bezel, height), (0, 0, 0, 0))
    radius = round(body.width * 0.16)
    ImageDraw.Draw(body).rounded_rectangle((0, 0, body.width - 1, height - 1), radius, fill=(*bezel_color, 255))
    inner = rounded(cover(screen, (inner_w, inner_h)), radius - bezel)
    body.alpha_composite(inner, (bezel, bezel))
    return body


def screenshot_card(capture: Image.Image, height: int, radius_frac=0.06) -> Image.Image:
    """A real app capture with rounded corners, the way store screenshots show it."""
    shot = fit_height(capture.convert("RGB"), height)
    return rounded(shot, round(shot.width * radius_frac))


# MARK: - Decoration

def dotted_arc(canvas, p0, p1, bulge, color, dots=9, r0=8, r1=18, ss=2, alpha=(90, 255)):
    """Dots along a quadratic curve from p0 to p1, growing and brightening towards p1.
    `bulge` lifts the control point perpendicular to the chord (negative = other side)."""
    layer = Image.new("RGBA", (canvas.width * ss, canvas.height * ss))
    d = ImageDraw.Draw(layer)
    (x0, y0), (x1, y1) = p0, p1
    mx, my = (x0 + x1) / 2, (y0 + y1) / 2
    length = math.hypot(x1 - x0, y1 - y0) or 1
    nx, ny = -(y1 - y0) / length, (x1 - x0) / length
    cx, cy = mx + nx * bulge, my + ny * bulge
    for i in range(dots):
        t = i / (dots - 1)
        x = (1 - t) ** 2 * x0 + 2 * (1 - t) * t * cx + t ** 2 * x1
        y = (1 - t) ** 2 * y0 + 2 * (1 - t) * t * cy + t ** 2 * y1
        r = (r0 + (r1 - r0) * t) * ss
        a = round(alpha[0] + (alpha[1] - alpha[0]) * t)
        d.ellipse((x * ss - r, y * ss - r, x * ss + r, y * ss + r), fill=(*color, a))
    canvas.alpha_composite(layer.resize(canvas.size, Image.LANCZOS))


def glow(canvas, center, radius, color, alpha=120):
    layer = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
    x, y = center
    ImageDraw.Draw(layer).ellipse((x - radius, y - radius, x + radius, y + radius), fill=(*color, alpha))
    canvas.alpha_composite(layer.filter(ImageFilter.GaussianBlur(radius // 2)))


def pill(text_img: Image.Image, pad_x: int, pad_y: int, fill) -> Image.Image:
    """A rounded chip behind an already-rendered text image (crop the text to its ink first)."""
    w, h = text_img.width + 2 * pad_x, text_img.height + 2 * pad_y
    chip = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    ImageDraw.Draw(chip).rounded_rectangle((0, 0, w - 1, h - 1), h // 2, fill=fill)
    chip.alpha_composite(text_img, (pad_x, pad_y))
    return chip


# MARK: - Text

def render_texts(jobs: list[dict]) -> list[Image.Image]:
    """Render every job in one swift call (each call costs ~1s of compile time).
    Each job: text, lang, size, width, maxLines, plus optional align/weight/color/lineHeight.
    Returns the images in order, each exactly `width` wide."""
    if not jobs:
        return []
    work = Path(tempfile.mkdtemp())
    for i, job in enumerate(jobs):
        job.setdefault("out", str(work / f"{i}.png"))
        job["size"], job["width"] = float(job["size"]), float(round(job["width"]))
    spec = work / "jobs.json"
    spec.write_text(json.dumps(jobs, ensure_ascii=False))
    subprocess.run(["swift", str(KIT / "render_text.swift"), str(spec)], check=True)
    return [Image.open(j["out"]).convert("RGBA") for j in jobs]


def ink(img: Image.Image) -> Image.Image:
    """Crop a rendered text image to its visible pixels."""
    box = img.getchannel("A").getbbox()
    return img.crop(box) if box else img


# MARK: - Output

def save(img: Image.Image, path: Path, expected=None) -> Path:
    """Flatten to RGB (the App Store rejects alpha) and check the size."""
    path.parent.mkdir(parents=True, exist_ok=True)
    rgb = img.convert("RGB")
    if expected and rgb.size != tuple(expected):
        raise ValueError(f"{path.name}: {rgb.size}, expected {expected}")
    if path.suffix.lower() in (".jpg", ".jpeg"):
        # Photographic assets: JPEG keeps files near 1 MB (PNG is accepted too).
        rgb.save(path, quality=90, subsampling=0, optimize=True, progressive=False)
    else:
        rgb.save(path, optimize=True)
    return path


def contact_sheet(paths: list[Path], out: Path, cols=3, thumb_w=960, label=True) -> Path:
    """One image of every output, for a single visual check."""
    from PIL import ImageFont
    thumbs = [fit_width(Image.open(p).convert("RGB"), thumb_w) for p in paths]
    th = max(t.height for t in thumbs)
    lab = 44 if label else 0
    rows = math.ceil(len(thumbs) / cols)
    sheet = Image.new("RGB", (cols * (thumb_w + 20) + 20, rows * (th + lab + 20) + 20), (240, 240, 240))
    d = ImageDraw.Draw(sheet)
    try:
        f = ImageFont.truetype("/System/Library/Fonts/SFNS.ttf", 28)
    except OSError:
        f = None
    for i, (p, t) in enumerate(zip(paths, thumbs)):
        x = 20 + (i % cols) * (thumb_w + 20)
        y = 20 + (i // cols) * (th + lab + 20)
        if label:
            d.text((x, y), f"{p.parent.name}/{p.name}", fill=(40, 40, 40), font=f)
        sheet.paste(t, (x, y + lab))
    sheet.save(out)
    return out
