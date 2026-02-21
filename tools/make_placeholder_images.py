#!/usr/bin/env python3
"""
Generate solid-color placeholder PNG images for the roku-photos channel.
Run from the project root: python3 tools/make_placeholder_images.py

Required sizes:
  icon_focus_hd  290 x 218  (Roku home screen icon, focused)
  icon_side_hd   108 x 69   (Roku home screen icon, side panel)
  splash_hd     1280 x 720  (Splash screen while channel loads)
"""

import os
import struct
import zlib


def make_png(width, height, r, g, b):
    def chunk(name, data):
        c = name + data
        return struct.pack(">I", len(data)) + c + struct.pack(">I", zlib.crc32(c) & 0xFFFFFFFF)

    ihdr = struct.pack(">IIBBBBB", width, height, 8, 2, 0, 0, 0)
    row = b"\x00" + bytes([r, g, b] * width)
    raw = row * height
    png = b"\x89PNG\r\n\x1a\n"
    png += chunk(b"IHDR", ihdr)
    png += chunk(b"IDAT", zlib.compress(raw))
    png += chunk(b"IEND", b"")
    return png


IMAGES = [
    ("roku-app/images/icon_focus_hd.png", 290, 218),
    ("roku-app/images/icon_side_hd.png", 108, 69),
    ("roku-app/images/splash_hd.png", 1280, 720),
]

# Dark navy — matches the MainScene background colour
R, G, B = 26, 26, 46

os.makedirs("roku-app/images", exist_ok=True)

for path, w, h in IMAGES:
    with open(path, "wb") as f:
        f.write(make_png(w, h, R, G, B))
    print(f"  {path}  ({w}x{h})")

print("Done.")
