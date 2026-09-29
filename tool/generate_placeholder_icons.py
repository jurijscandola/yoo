"""Generates the placeholder launcher icons of Yoo (the "Classic" preview:
a light "Y" on the dark accent), for Android and iOS.

The "Y" is the same polygon as android/app/src/main/res/drawable/ic_stat_yoo.xml
(24x24 viewport). Replace this with the final artwork when it exists.

Usage (needs Pillow):  python tool/generate_placeholder_icons.py
"""

import json
import pathlib

from PIL import Image, ImageDraw

ROOT = pathlib.Path(__file__).resolve().parent.parent
BACKGROUND = (0x1E, 0x1D, 0x1B)
FOREGROUND = (0xFA, 0xF8, 0xF4)
# "Y" in a 24x24 viewport, glyph box x 4..20, y 3..21 (center 12, 12).
GLYPH = [(4, 3), (8.6, 3), (12, 8.9), (15.4, 3), (20, 3), (14, 12.9), (14, 21), (10, 21), (10, 12.9)]
SUPERSAMPLE = 4


def draw_icon(size: int, glyph_height: float, rounded: bool) -> Image.Image:
    """A [size] px icon; the glyph is [glyph_height] of the side. Rounded
    corners for Android legacy icons, full bleed for iOS (masked by iOS)."""
    big = size * SUPERSAMPLE
    image = Image.new("RGBA" if rounded else "RGB", (big, big), (0, 0, 0, 0) if rounded else BACKGROUND)
    draw = ImageDraw.Draw(image)
    if rounded:
        draw.rounded_rectangle([0, 0, big - 1, big - 1], radius=big * 0.22, fill=BACKGROUND)
    scale = big * glyph_height / 18  # the glyph is 18 units tall
    points = [(big / 2 + (x - 12) * scale, big / 2 + (y - 12) * scale) for x, y in GLYPH]
    draw.polygon(points, fill=FOREGROUND)
    return image.resize((size, size), Image.LANCZOS)


def android() -> None:
    res = ROOT / "android/app/src/main/res"
    for folder, size in {"mdpi": 48, "hdpi": 72, "xhdpi": 96, "xxhdpi": 144, "xxxhdpi": 192}.items():
        draw_icon(size, 0.5, rounded=True).save(res / f"mipmap-{folder}/ic_launcher.png")


def ios() -> None:
    folder = ROOT / "ios/Runner/Assets.xcassets/AppIcon.appiconset"
    contents = json.loads((folder / "Contents.json").read_text(encoding="utf-8"))
    for entry in contents["images"]:
        points = float(entry["size"].split("x")[0])
        pixels = round(points * int(entry["scale"].rstrip("x")))
        draw_icon(pixels, 0.5, rounded=False).save(folder / entry["filename"])


if __name__ == "__main__":
    android()
    ios()
    print("Placeholder icons written.")
