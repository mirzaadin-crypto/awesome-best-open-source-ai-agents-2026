#!/usr/bin/env python3
"""Generate a cool ULTRON icon (.ico, multi-size) + PNG preview. Pure stdlib."""
import math, zlib, struct, sys

OUT_ICO = sys.argv[1] if len(sys.argv) > 1 else "ultron.ico"
OUT_PNG = sys.argv[2] if len(sys.argv) > 2 else "ultron_preview.png"

CYAN = (0.13, 0.83, 0.94)
GOLD = (1.00, 0.72, 0.00)
BG_TOP = (0.055, 0.10, 0.18)
BG_BOT = (0.02, 0.04, 0.07)


def clamp(v, a, b):
    return a if v < a else b if v > b else v


def sd_round_box(px, py, hw, rad):
    qx = abs(px) - hw + rad
    qy = abs(py) - hw + rad
    return math.hypot(max(qx, 0), max(qy, 0)) + min(max(qx, qy), 0) - rad


def color_at(x, y, aa):
    # background rounded square
    sd = sd_round_box(x - 0.5, y - 0.5, 0.47, 0.20)
    bg_a = clamp(0.5 - sd / aa, 0.0, 1.0)
    t = y
    r = BG_TOP[0] * (1 - t) + BG_BOT[0] * t
    g = BG_TOP[1] * (1 - t) + BG_BOT[1] * t
    b = BG_TOP[2] * (1 - t) + BG_BOT[2] * t
    a = bg_a

    # radial glow behind the core
    d = math.hypot(x - 0.5, y - 0.5)
    glow = math.exp(-((d / 0.30) ** 2)) * 0.55
    r += CYAN[0] * glow * 0.35
    g += CYAN[1] * glow * 0.35
    b += CYAN[2] * glow * 0.35

    # outer cyan ring (glow + crisp core)
    ring = math.exp(-(((d - 0.395) / 0.055) ** 2)) * 0.9
    core = clamp(0.5 - (abs(d - 0.395) - 0.016) / aa, 0.0, 1.0)
    ri = min(1.0, ring + core)
    r = r * (1 - ri) + CYAN[0] * ri
    g = g * (1 - ri) + CYAN[1] * ri
    b = b * (1 - ri) + CYAN[2] * ri

    # gold "U" = lower half annulus + two vertical bars
    cx, cy, rin, rout = 0.5, 0.50, 0.085, 0.175
    dd = math.hypot(x - cx, y - cy)
    in_u = (rin <= dd <= rout and y >= cy)
    in_u = in_u or ((cx - rout <= x <= cx - rin) and (cy - 0.16 <= y <= cy))
    in_u = in_u or ((cx + rin <= x <= cx + rout) and (cy - 0.16 <= y <= cy))
    if in_u:
        # soft gold with slight vertical shading
        gg = 0.85 + 0.15 * (1 - y)
        r, g, b = GOLD[0] * gg, GOLD[1] * gg, GOLD[2] * gg
        a = max(a, 1.0)

    return r, g, b, a


def render(size, ss=3):
    W = size * ss
    buf = bytearray(size * size * 4)
    aa = 1.0 / (size * ss)
    inv = 1.0 / (ss * ss)
    for oy in range(size):
        for ox in range(size):
            ar = ag = ab = aA = 0.0
            for sy in range(ss):
                for sx in range(ss):
                    x = (ox * ss + sx + 0.5) / W
                    y = (oy * ss + sy + 0.5) / W
                    r, g, b, a = color_at(x, y, aa)
                    ar += r * a; ag += g * a; ab += b * a; aA += a
            a = aA * inv
            if a > 0:
                r = (ar * inv) / a; g = (ag * inv) / a; b = (ab * inv) / a
            else:
                r = g = b = 0
            i = (oy * size + ox) * 4
            buf[i] = int(clamp(r, 0, 1) * 255)
            buf[i + 1] = int(clamp(g, 0, 1) * 255)
            buf[i + 2] = int(clamp(b, 0, 1) * 255)
            buf[i + 3] = int(clamp(a, 0, 1) * 255)
    return buf


def dib(rgba, size):
    h = size
    xor = bytearray()
    for y in range(h - 1, -1, -1):
        for x in range(h):
            i = (y * h + x) * 4
            xor += bytes((rgba[i + 2], rgba[i + 1], rgba[i], rgba[i + 3]))
    stride = ((h + 31) // 32) * 4
    andmask = bytes(stride * h)
    hdr = struct.pack('<IiiHHIIiiII', 40, h, h * 2, 1, 32, 0, len(xor) + len(andmask), 0, 0, 0, 0)
    return hdr + bytes(xor) + andmask


def write_png(path, rgba, size):
    raw = bytearray()
    for y in range(size):
        raw.append(0)
        raw += rgba[y * size * 4:(y + 1) * size * 4]
    def chunk(tag, data):
        c = struct.pack('>I', len(data)) + tag + data
        return c + struct.pack('>I', zlib.crc32(tag + data) & 0xffffffff)
    png = b'\x89PNG\r\n\x1a\n'
    png += chunk(b'IHDR', struct.pack('>IIBBBBB', size, size, 8, 6, 0, 0, 0))
    png += chunk(b'IDAT', zlib.compress(bytes(raw), 9))
    png += chunk(b'IEND', b'')
    open(path, 'wb').write(png)


sizes = [16, 32, 48, 64, 128, 256]
imgs = []
for s in sizes:
    imgs.append((s, dib(render(s), s)))

n = len(imgs)
out = struct.pack('<HHH', 0, 1, n)
off = 6 + 16 * n
body = b''
for s, data in imgs:
    w = 0 if s == 256 else s
    out += struct.pack('<BBBBHHII', w, w, 0, 0, 1, 32, len(data), off + len(body))
    body += data
open(OUT_ICO, 'wb').write(out + body)
write_png(OUT_PNG, render(256, ss=3), 256)
print(f"wrote {OUT_ICO} ({len(out)+len(body)} bytes) and {OUT_PNG}")
