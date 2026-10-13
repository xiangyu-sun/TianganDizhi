#!/usr/bin/env python3
"""App Store creative assets (fall 2026): product page header and search result images.

    python3 fastlane/creative_assets.py            # every locale in COPY
    python3 fastlane/creative_assets.py en-US ja   # only these

Output (upload by hand in App Store Connect → Asset Library; deliver can't push these):
  fastlane/creative_assets/header_21x9_3840x1646.png          one header for all locales
                                                              (PNG: the header well rejects .jpg)
  fastlane/creative_assets/<locale>/search_3x2_3840x2560.jpg  one search image per locale
  fastlane/creative_assets/contact_sheet.png                  everything at a glance

Header: no text on purpose. The App Store draws the name, icon and Get button over it,
and a text-free header needs no localizing. It shows the whole app as one picture: the
時辰 clock in the middle, the Home Screen and Lock Screen widgets beside it and the
Watch app at the ends, over a faint ring echoing the clock's dial.

Search: states the obvious with real UI. The headline is the outcome (the Chinese hour
at a glance, on your Home Screen); the chips answer "where does it show up / what does
it cover". Apple's asset rules forbid prices, so nothing about cost goes here.

Inputs: the real captures in fastlane/screenshots/zh-Hant (the app UI is Chinese in every
locale, so one set serves all). Shared helpers: cakit.py + render_text.swift, from the
app-store-creative-assets skill.
"""
from __future__ import annotations

import sys
from pathlib import Path

from PIL import Image, ImageDraw

import cakit as ck

HERE = Path(__file__).resolve().parent
SHOTS = HERE / "screenshots" / "zh-Hant"
OUT = HERE / "creative_assets"

# Brand: the app's rice-paper background, ink, and a seal-red accent.
PAPER_LIGHT, PAPER_DARK = (246, 241, 230), (226, 215, 192)
INK = (34, 30, 26)
SEAL = (176, 48, 36)
INK_SOFT = "#4A423A"
CHIP_FILL = (34, 30, 26, 22)

# Headline = outcome + where it shows up; chips = the "what do I get" objections.
# Every claim is a shipping feature: widgets on Home + Lock Screen, the watch app,
# lunar date / solar terms / daily almanac (宜忌).
COPY = {
    "en-US": ("The Chinese hour, right on your Home Screen",
              ["Home & Lock Screen widgets", "Lunar dates & solar terms", "Apple Watch app"]),
    "es-ES": ("La hora china en tu pantalla de\u00a0inicio",
              ["Widgets de inicio y bloqueo", "Calendario lunar y términos solares", "App para Apple Watch"]),
    "fr-FR": ("L’heure chinoise sur votre écran d’accueil",
              ["Widgets d’accueil et verrouillage", "Calendrier lunaire et termes solaires", "App Apple Watch"]),
    "id": ("Jam Tiongkok langsung di Layar Utama",
           ["Widget Layar Utama & Kunci", "Kalender lunar & musim matahari", "Aplikasi Apple Watch"]),
    "ms": ("Waktu Cina terus di Skrin Utama",
           ["Widget Skrin Utama & Kunci", "Kalendar lunar & terma suria", "Apl Apple Watch"]),
    "ru": ("Китайский час прямо на экране «Домой»",
           ["Виджеты «Домой» и блокировки", "Лунный календарь и цзеци", "Приложение для Apple Watch"]),
    "th": ("ยามจีน\nบนหน้าจอโฮมของคุณ",
           ["วิดเจ็ตหน้าจอโฮมและหน้าจอล็อค", "ปฏิทินจันทรคติและสารทจีน", "แอป Apple Watch"]),
    "vi": ("Giờ can chi ngay\ntrên Màn hình chính",
           ["Tiện ích Màn hình chính & khóa", "Âm lịch & tiết khí", "Ứng dụng Apple Watch"]),
    "ja": ("時辰と節気を\nホーム画面に",
           ["ホーム・ロック画面ウィジェット", "旧暦・二十四節気・暦注", "Apple Watch対応"]),
    "ko": ("시진과 절기를\n홈 화면에서",
           ["홈·잠금 화면 위젯", "음력·절기·일진", "Apple Watch 앱"]),
    "zh-Hans": ("时辰节气，\n主屏幕一眼可见",
                ["主屏幕与锁屏小组件", "农历・节气・每日宜忌", "支持 Apple Watch"]),
    "zh-Hant": ("時辰節氣，\n主畫面一眼可見",
                ["主畫面與鎖定畫面小工具", "農曆・節氣・每日宜忌", "支援 Apple Watch"]),
}

SEARCH_COL_W = 1640   # text column width on the search image
SEARCH_MARGIN = 230


def shot(name: str) -> Image.Image:
    path = SHOTS / name
    if not path.exists():
        sys.exit(f"Missing capture {path}. Run the screenshots lane first.")
    return Image.open(path).convert("RGB")


# Real captures used everywhere.
def home_widgets(): return shot("0_APP_IPHONE_65_0.png")    # Home Screen widgets
def lock_screen(): return shot("2_APP_IPHONE_65_2.png")     # Lock Screen widgets
def clock_app(): return shot("4_APP_IPHONE_65_4.png")       # 時辰 clock, the main screen
def dial_home(): return shot("8_APP_IPHONE_65_8.png")       # large dial widget
def watch_dial(): return shot("2_APP_WATCH_ULTRA_2.png")
def watch_branch(): return shot("6_APP_WATCH_ULTRA_6.png")


def watch(screen: Image.Image, height: int) -> Image.Image:
    """A generic watch: black rounded case around the screen, short band stubs."""
    bezel = height // 16
    band_h = height // 7
    case_h = height - 2 * band_h
    inner_h = case_h - 2 * bezel
    inner_w = round(inner_h * screen.width / screen.height)
    case_w = inner_w + 2 * bezel
    body = Image.new("RGBA", (case_w, height), (0, 0, 0, 0))
    d = ImageDraw.Draw(body)
    band_w = round(case_w * 0.72)
    bx = (case_w - band_w) // 2
    d.rounded_rectangle((bx, 0, bx + band_w, height - 1), band_w // 6, fill=(52, 48, 44, 255))
    radius = round(case_w * 0.24)
    d.rounded_rectangle((0, band_h, case_w - 1, band_h + case_h - 1), radius, fill=(14, 14, 16, 255))
    inner = ck.rounded(ck.cover(screen, (inner_w, inner_h)), radius - bezel)
    body.alpha_composite(inner, (bezel, band_h + bezel))
    return body


def paper(size, center=(0.5, 0.42)) -> Image.Image:
    return ck.radial_gradient(size, PAPER_LIGHT, PAPER_DARK, center=center, falloff=1.2).convert("RGBA")


def make_header() -> Image.Image:
    """21:9, no text. Symmetric so Apple's per-device crops stay safe; calm bottom band."""
    W, H = ck.HEADER_SIZE
    canvas = paper((W, H))
    ck.glow(canvas, (W // 2, round(H * 0.45)), 760, (255, 250, 238), alpha=150)
    # Faint double ring (the clock's dial, echoed) — only its arcs show between the phones.
    ring = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    d = ImageDraw.Draw(ring)
    cx, cy = W // 2, round(H * 0.47)
    for r, w in ((800, 6), (850, 3)):
        d.ellipse((cx - r, cy - r, cx + r, cy + r), outline=(*SEAL, 52), width=w)
    canvas.alpha_composite(ring)

    top = 150
    centre = ck.phone(clock_app(), 1260)
    side_h = 1080
    left = ck.phone(home_widgets(), side_h).rotate(4, expand=True, resample=Image.BICUBIC)
    right = ck.phone(lock_screen(), side_h).rotate(-4, expand=True, resample=Image.BICUBIC)
    w_left = watch(watch_dial(), 560).rotate(6, expand=True, resample=Image.BICUBIC)
    w_right = watch(watch_branch(), 560).rotate(-6, expand=True, resample=Image.BICUBIC)

    gap = 1000                                       # centre-to-centre, phones
    wgap = 1640                                      # centre-to-centre, watches
    ck.paste_with_shadow(canvas, w_left, (W // 2 - wgap - w_left.width // 2, 470), blur=30, alpha=120)
    ck.paste_with_shadow(canvas, w_right, (W // 2 + wgap - w_right.width // 2, 470), blur=30, alpha=120)
    ck.paste_with_shadow(canvas, left, (W // 2 - gap - left.width // 2, top + 110), blur=40, alpha=140)
    ck.paste_with_shadow(canvas, right, (W // 2 + gap - right.width // 2, top + 110), blur=40, alpha=140)
    ck.paste_with_shadow(canvas, centre, ((W - centre.width) // 2, top), blur=50, alpha=170)
    return canvas


def make_search(locale: str, text) -> Image.Image:
    """3:2: headline and chips on the reading-start side, real UI on the other."""
    W, H = ck.SEARCH_SIZE
    rtl = ck.is_rtl(locale)
    canvas = paper((W, H), center=(0.35 if rtl else 0.65, 0.45))

    # Devices: the 時辰 clock app behind, the Home Screen widgets in front, a watch beside.
    dev_x = 230 if rtl else W - 230                  # outer edge of the device group
    back = ck.phone(clock_app(), 2020)
    front = ck.phone(home_widgets(), 2140)
    wt = watch(watch_dial(), 820)
    back_x = dev_x if rtl else dev_x - back.width
    ck.paste_with_shadow(canvas, back, (back_x, 150), blur=50, alpha=150)
    front_x = back_x + back.width - 380 if rtl else back_x - front.width + 380
    ck.paste_with_shadow(canvas, front, (front_x, H - front.height - 140), blur=60, alpha=180)
    wt_x = (dev_x - wt.width + 120) if not rtl else dev_x - 120
    ck.paste_with_shadow(canvas, wt, (wt_x, H - wt.height - 110), blur=40, alpha=170)

    head_img, *chip_imgs = (ck.ink(t) for t in text)
    block_h = 36 + 100 + head_img.height + 140 + sum(c.height + 2 * 34 + 44 for c in chip_imgs) - 44
    y = (H - block_h) // 2
    bar_x = W - SEARCH_MARGIN - 160 if rtl else SEARCH_MARGIN
    canvas.alpha_composite(Image.new("RGBA", (160, 36), (*SEAL, 255)), (bar_x, y))
    y += 36 + 100
    hx = W - SEARCH_MARGIN - head_img.width if rtl else SEARCH_MARGIN
    canvas.alpha_composite(head_img, (hx, y))
    y += head_img.height + 140
    for chip_text in chip_imgs:
        chip = ck.pill(chip_text, 56, 34, CHIP_FILL)
        cx = W - SEARCH_MARGIN - chip.width if rtl else SEARCH_MARGIN
        canvas.alpha_composite(chip, (cx, y))
        y += chip.height + 44
    return canvas


def keep_together(text: str) -> str:
    """Never strand "Watch" on its own line."""
    return text.replace("Apple Watch", "Apple Watch")


def text_jobs(locale: str, headline: str, chips: list[str]) -> list[dict]:
    align = "right" if ck.is_rtl(locale) else "left"
    lang = ck.text_lang(locale)
    hex_ink = "#%02X%02X%02X" % INK
    jobs = [{"text": keep_together(headline), "lang": lang, "size": 200, "width": SEARCH_COL_W,
             "maxLines": 3, "align": align, "weight": "heavy", "lineHeight": 1.05, "color": hex_ink}]
    jobs += [{"text": f"✓  {keep_together(c)}" if align == "left" else f"{keep_together(c)}  ✓",
              "lang": lang, "size": 76, "width": SEARCH_COL_W - 112, "maxLines": 1, "align": align,
              "weight": "semibold", "color": INK_SOFT} for c in chips]
    return jobs


def main(locales: list[str]) -> int:
    jobs = {loc: text_jobs(loc, *COPY[loc]) for loc in locales}
    # One swift call for every locale's text.
    flat = ck.render_texts([j for loc in locales for j in jobs[loc]])

    outputs = [ck.save(make_header(), OUT / "header_21x9_3840x1646.png", ck.HEADER_SIZE)]
    print(f"✓ {outputs[-1].relative_to(HERE)}")
    for loc in locales:
        text, flat = flat[:len(jobs[loc])], flat[len(jobs[loc]):]
        outputs.append(ck.save(make_search(loc, text), OUT / loc / "search_3x2_3840x2560.jpg",
                               ck.SEARCH_SIZE))
        print(f"✓ {outputs[-1].relative_to(HERE)}")
    sheet = ck.contact_sheet(outputs, OUT / "contact_sheet.png", cols=3)
    print(f"✓ {sheet.relative_to(HERE)}")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:] or list(COPY)))
