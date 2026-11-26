#!/usr/bin/env python3
"""Captioned App Store screenshots, composed from raw simulator captures.

    python3 fastlane/marketing_screenshots.py                 # every locale in LOCALES
    python3 fastlane/marketing_screenshots.py es-MX           # only these
    python3 fastlane/marketing_screenshots.py --sheet <png>   # also write a contact sheet

Needs Pillow and macOS (the headline is set in the system font, SF Pro Black).

Input    fastlane/captures/<capture set>/{iphone,ipad,watch}/<shot>.png  (git-ignored)
Output   fastlane/screenshots_marketing/<locale>/<n>_<display type>_<n>.png
         The script replaces the PNGs in each locale folder it builds.

    folder   capture size   display type               device used for the capture
    iphone   1320x2868      APP_IPHONE_67              iPhone 17 Pro Max
    ipad     2064x2752      APP_IPAD_PRO_3GEN_129      iPad Pro 13-inch
    watch    422x514        APP_WATCH_ULTRA            Apple Watch Ultra 3 (49mm)

iPhone and iPad shots get a caption band on top and the whole capture below it (nothing
covered, no device frame). Watch shots are copied without a caption, only flattened to
RGB. Every output is checked for size and for the lack of an alpha channel.

To add a language: put its captions in CAPTIONS and its locales in LOCALES.

Capturing (what makes the shots look right)
  * Use dedicated simulators. Set language and region first, then reboot:
      xcrun simctl spawn <udid> defaults write -g AppleLanguages -array es-ES
      xcrun simctl spawn <udid> defaults write -g AppleLocale es_ES
  * iPad: Settings > Multitasking > Full Screen Apps, or every shot has a window handle
    and the app name in the status bar.
  * Status bar:  xcrun simctl status_bar <udid> override --time 9:41 --batteryState charged
    --batteryLevel 100 --wifiBars 3 --cellularBars 4
    Leave the date alone on iPad: an ISO --time prints the date in English.
  * The app's clock must agree with the status bar (時辰, lunar date). Pick the GMT offset
    that makes it 09:41 now, e.g. GMT+0339, then
      xcrun simctl spawn <udid> launchctl setenv TZ GMT+0339
      SIMCTL_CHILD_TZ=GMT+0339 xcrun simctl launch <udid> com.uriphium.TianganDizhi UITestMode
    UITestMode hides onboarding and the review prompt.
  * Widgets, and the watch (no status bar override), need the whole system on that time:
      SIMCTL_CHILD_TZ=GMT+0339 xcrun simctl boot <udid>
    A simulator booted this way ignores a different per-launch TZ; reboot plainly first.
  * Festival calendar: relaunch with TZ=Europe/Madrid so solar-term dates suit Spain and
    match between devices. Bazi: relaunch with TZ=GMT+0800, so the birth time picked is the
    hour pillar shown, and set a birth date (it starts at "born now").
    Used here: 26 Nov 1990, 09:xx, which has all five elements.
  * Location:  xcrun simctl privacy <udid> grant location <bundle id>, then
    simctl location set with a longitude near offset*15, so sunrise and sunset look
    natural (without it the main screen asks to enable location).
  * In the app group's plist (simctl get_app_container <udid> <bundle id>
    group.uriphium.tiangandizhi) set analyticsEnabled NO with simctl spawn defaults write.
  * Navigation: simctl cannot tap. The Oct 2026 and Nov 2026 captures drove a throwaway
    copy of the project (an XCUITest for iPhone and iPad, launch variables for the watch).
  * Skip screens that cut Spanish or show Chinese prose (as of 2.83.0): month grid, week
    strip, calendar widget; custom holidays (category reads 自訂); seasonal health and
    almanac widgets, Twelve Gods; on the watch, long navigation titles and Five Notes.

Uploading is a separate, manual step that needs the owner's go-ahead. Back up first
(fastlane deliver download_screenshots), and afterwards check sets, counts, delivery
state and order with Spaceship: deliver has failed to reorder a set and to delete old
screenshots while reporting success.
"""
from __future__ import annotations

import argparse
import sys
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont

HERE = Path(__file__).resolve().parent
CAPTURES = HERE / "captures"
OUT = HERE / "screenshots_marketing"

# Store locale -> capture set (and caption language). es-MX reuses the es-ES set.
LOCALES = {
    "es-ES": "es-ES",
    "es-MX": "es-ES",
}

# Shot order is the order on the store page: hook, then depth. Captions lead with the
# benefit, in about five words, and "\n" fixes the line break.
SHOTS = ["clock", "widgets", "bazi", "festivals", "gua", "elements"]
CAPTIONS = {
    "es-ES": {
        "clock": "La hora china,\nde un vistazo",
        "widgets": "Siempre en tu\npantalla de inicio",
        "bazi": "Descubre tus\nCuatro Pilares",
        "festivals": "No te pierdas\nninguna fiesta",
        "gua": "Sigue el I Ching\nmes a mes",
        "elements": "Entiende los\nCinco Elementos",
    },
}
WATCH_SHOTS = ["clock", "pigua", "bagua", "knowledge", "gua", "chart"]

# folder: (display type, pixel size, headline size)
DEVICES = {
    "iphone": ("APP_IPHONE_67", (1320, 2868), 104),
    "ipad": ("APP_IPAD_PRO_3GEN_129", (2064, 2752), 120),
    "watch": ("APP_WATCH_ULTRA", (422, 514), None),
}

BAND = (28, 16, 10)  # warm charcoal, #1C100A
ACCENT = (240, 138, 36)
PAPER_TOP, PAPER_BOTTOM = (246, 241, 230), (226, 215, 192)  # as in creative_assets.py
BAND_RATIO = 0.18

SF = "/System/Library/Fonts/SFNS.ttf"


def headline_font(size: int) -> ImageFont.FreeTypeFont:
    font = ImageFont.truetype(SF, size)
    # Axes in file order: width, optical size, grade, weight.
    font.set_variation_by_axes([100, 96, 400, 900])
    return font


def rounded_mask(size: tuple[int, int], radius: int) -> Image.Image:
    """Anti-aliased rounded-rectangle mask."""
    scale = 4
    big = Image.new("L", (size[0] * scale, size[1] * scale), 0)
    ImageDraw.Draw(big).rounded_rectangle(
        (0, 0, big.width - 1, big.height - 1), radius * scale, fill=255)
    return big.resize(size, Image.LANCZOS)


def vertical_gradient(size, top, bottom) -> Image.Image:
    ramp = Image.linear_gradient("L").resize(size)
    return Image.composite(Image.new("RGB", size, bottom), Image.new("RGB", size, top), ramp)


def draw_band(canvas: Image.Image, caption: str, font_size: int) -> int:
    width, height = canvas.size
    band_h = round(height * BAND_RATIO)
    radius = round(width * 0.045)

    # Extend the rectangle above the canvas so only the bottom corners are rounded.
    mask = rounded_mask((width, band_h + radius), radius).crop((0, radius, width, band_h + radius))
    canvas.paste(Image.new("RGB", (width, band_h), BAND), (0, 0), mask)

    draw = ImageDraw.Draw(canvas)
    lines = caption.split("\n")
    pill_w, pill_h = round(font_size * 0.67), round(font_size * 0.155)
    gap = round(font_size * 0.42)
    while True:
        font = headline_font(font_size)
        widest = max(draw.textlength(line, font=font) for line in lines)
        line_h = round(font_size * 1.14)
        block_h = pill_h + gap + line_h * len(lines)
        if widest <= width * 0.9 and block_h <= band_h * 0.86:
            break
        font_size -= 2

    y = (band_h - block_h) // 2
    draw.rounded_rectangle(
        ((width - pill_w) // 2, y, (width + pill_w) // 2, y + pill_h), pill_h // 2, fill=ACCENT)
    y += pill_h + gap
    for line in lines:
        draw.text((width / 2, y + line_h / 2), line, font=font, fill="white", anchor="mm")
        y += line_h
    return band_h


def compose(capture: Image.Image, caption: str, font_size: int) -> Image.Image:
    width, height = capture.size
    canvas = vertical_gradient((width, height), PAPER_TOP, PAPER_BOTTOM)
    band_h = draw_band(canvas, caption, font_size)

    margin = round(height * 0.022)
    shot_h = height - band_h - 2 * margin
    shot_w = round(shot_h * width / height)
    shot = capture.resize((shot_w, shot_h), Image.LANCZOS)
    x, y = (width - shot_w) // 2, band_h + margin
    radius = round(shot_w * (0.085 if height / width > 1.8 else 0.035))
    mask = rounded_mask(shot.size, radius)

    shadow = Image.new("L", canvas.size, 0)
    shadow.paste(mask.point(lambda a: a * 90 // 255), (x, y + round(height * 0.004)))
    shadow = shadow.filter(ImageFilter.GaussianBlur(width * 0.016))
    canvas.paste(Image.new("RGB", canvas.size, BAND), (0, 0), shadow)

    canvas.paste(shot, (x, y), mask)
    # A hairline keeps a light screen apart from the paper background.
    ImageDraw.Draw(canvas).rounded_rectangle(
        (x - 1, y - 1, x + shot_w, y + shot_h), radius + 1,
        outline=(188, 176, 154), width=max(2, width // 600))
    return canvas


def build(locale: str) -> tuple[list[Path], list[str]]:
    source = LOCALES[locale]
    out_dir = OUT / locale
    out_dir.mkdir(parents=True, exist_ok=True)
    for old in out_dir.glob("*.png"):
        old.unlink()

    written, missing = [], []
    for folder, (display_type, size, font_size) in DEVICES.items():
        names = WATCH_SHOTS if folder == "watch" else SHOTS
        index = 0
        for name in names:
            path = CAPTURES / source / folder / f"{name}.png"
            if not path.exists():
                missing.append(str(path.relative_to(HERE.parent)))
                continue
            capture = Image.open(path).convert("RGB")
            if capture.size != size:
                sys.exit(f"{path}: {capture.size}, expected {size} for {display_type}")
            image = capture if font_size is None else compose(capture, CAPTIONS[source][name], font_size)
            target = out_dir / f"{index}_{display_type}_{index}.png"
            image.save(target, optimize=True)
            written.append(target)
            index += 1
    return written, missing


def verify(paths: list[Path]) -> None:
    sizes = {display_type: size for display_type, size, _ in DEVICES.values()}
    for path in paths:
        display_type = path.stem.split("_", 1)[1].rsplit("_", 1)[0]
        with Image.open(path) as image:
            if image.size != sizes[display_type] or image.mode != "RGB":
                sys.exit(f"{path}: {image.size} {image.mode}, expected {sizes[display_type]} RGB")
            print(f"{path.relative_to(HERE.parent)}  {image.width}x{image.height}  {image.mode}")


def contact_sheet(paths: list[Path], out: Path, cell_h: int = 600) -> None:
    """One row per display type, for checking captions at thumbnail size."""
    rows: dict[str, list[Image.Image]] = {}
    for path in paths:
        with Image.open(path) as image:
            thumb = image.resize((round(image.width * cell_h / image.height), cell_h), Image.LANCZOS)
        rows.setdefault(path.stem.split("_", 1)[1].rsplit("_", 1)[0], []).append(thumb)
    gap = 16
    sheet_w = max(sum(t.width + gap for t in row) for row in rows.values()) + gap
    sheet = Image.new("RGB", (sheet_w, len(rows) * (cell_h + gap) + gap), (110, 110, 110))
    for r, row in enumerate(rows.values()):
        x = gap
        for thumb in row:
            sheet.paste(thumb, (x, gap + r * (cell_h + gap)))
            x += thumb.width + gap
    sheet.save(out)


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    parser.add_argument("locales", nargs="*", choices=[[], *LOCALES], default=[])
    parser.add_argument("--sheet", type=Path, help="write a contact sheet of the first locale")
    args = parser.parse_args()

    locales = args.locales or list(LOCALES)
    for locale in locales:
        written, missing = build(locale)
        verify(written)
        for path in missing:
            print(f"missing capture: {path}", file=sys.stderr)
        if not written:
            sys.exit(f"{locale}: no captures found under {CAPTURES / LOCALES[locale]}")
        if args.sheet and locale == locales[0]:
            contact_sheet(written, args.sheet)
            print(f"contact sheet: {args.sheet}")


if __name__ == "__main__":
    main()
