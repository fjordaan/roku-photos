#!/usr/bin/env python3
"""Generate play and pause icon PNGs for the Roku overlay."""

import struct
import zlib
import os

OUT_DIR = os.path.join(os.path.dirname(__file__), "..", "roku-app", "images")
SIZE = 128   # PNG canvas size in pixels


def write_png(path, size, pixels_rgba):
    """Write a SIZE×SIZE RGBA PNG to path. pixels_rgba is a flat list of (r,g,b,a)."""
    def chunk(tag, data):
        crc = zlib.crc32(tag + data) & 0xFFFFFFFF
        return struct.pack(">I", len(data)) + tag + data + struct.pack(">I", crc)

    raw = b""
    for y in range(size):
        raw += b"\x00"  # filter type None
        for x in range(size):
            raw += bytes(pixels_rgba[y * size + x])

    ihdr = struct.pack(">IIBBBBB", size, size, 8, 6, 0, 0, 0)  # 8-bit RGBA
    png = (
        b"\x89PNG\r\n\x1a\n"
        + chunk(b"IHDR", ihdr)
        + chunk(b"IDAT", zlib.compress(raw, 9))
        + chunk(b"IEND", b"")
    )
    with open(path, "wb") as f:
        f.write(png)


def play_pixels(size):
    """White right-pointing filled triangle (▶) on transparent background."""
    pad = size // 8
    cy = size / 2
    max_dist = cy - pad   # half-height of the triangle
    pixels = []
    for y in range(size):
        for x in range(size):
            dist = abs(y - cy)
            if dist >= max_dist:
                pixels.append((0, 0, 0, 0))
                continue
            # Right edge tapers from full-width at centre to zero at top/bottom
            right_edge = pad + (size - 2 * pad) * (1 - dist / max_dist)
            if pad <= x <= right_edge:
                pixels.append((255, 255, 255, 255))
            else:
                pixels.append((0, 0, 0, 0))
    return pixels


def pause_pixels(size):
    """Two white vertical bars on transparent background."""
    pad = size // 8
    bar_w = max(1, size // 5)
    gap   = max(1, size // 8)
    x1 = pad
    x2 = pad + bar_w + gap
    pixels = []
    for y in range(size):
        for x in range(size):
            in_bar = (x1 <= x < x1 + bar_w) or (x2 <= x < x2 + bar_w)
            in_height = pad <= y < size - pad
            if in_bar and in_height:
                pixels.append((255, 255, 255, 255))
            else:
                pixels.append((0, 0, 0, 0))
    return pixels


os.makedirs(OUT_DIR, exist_ok=True)
write_png(os.path.join(OUT_DIR, "icon_play.png"),  SIZE, play_pixels(SIZE))
write_png(os.path.join(OUT_DIR, "icon_pause.png"), SIZE, pause_pixels(SIZE))
print(f"Written icon_play.png and icon_pause.png ({SIZE}×{SIZE} RGBA) to {OUT_DIR}")
