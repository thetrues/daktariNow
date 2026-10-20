"""Regenerates every app icon from the DaktariNow mark (see logo.svg).

Run from the medic_app folder:  python tool/brand/generate_icons.py
The geometry matches logo.svg and lib/shared/widgets/brand_logo.dart.
"""
from pathlib import Path

from PIL import Image, ImageDraw

PRIMARY = (0x1F, 0xB5, 0xA8)
PRIMARY_DARK = (0x13, 0x89, 0x7F)
WHITE = (255, 255, 255)
SS = 8  # supersampling factor for smooth edges

ROOT = Path(__file__).resolve().parents[3]  # the folder holding medic_app and medic_admin
APP = ROOT / 'medic_app'
ADMIN = ROOT / 'medic_admin'


def gradient(size):
    """Diagonal PRIMARY -> PRIMARY_DARK, as in logo.svg."""
    g = Image.new('RGB', (size, size))
    px = g.load()
    for y in range(size):
        for x in range(size):
            t = (x + y) / (2 * (size - 1))
            px[x, y] = tuple(round(a + (b - a) * t) for a, b in zip(PRIMARY, PRIMARY_DARK))
    return g


def render(size, *, rounded=True, scale=1.0):
    """The mark at [size] px. rounded=False fills the square (iOS, maskable);
    scale < 1 shrinks the bubble into the maskable safe zone."""
    s = size * SS
    u = s / 100  # one unit of the 100x100 design

    def p(x, y):  # design units -> pixels, scaled around the centre
        return (50 + (x - 50) * scale) * u, (50 + (y - 50) * scale) * u

    bg = gradient(64).resize((s, s), Image.BILINEAR)
    mask = Image.new('L', (s, s), 0)
    md = ImageDraw.Draw(mask)
    if rounded:
        md.rounded_rectangle((0, 0, s - 1, s - 1), radius=24 * u, fill=255)
    else:
        md.rectangle((0, 0, s, s), fill=255)
    img = Image.new('RGBA', (s, s), (0, 0, 0, 0))
    img.paste(bg, (0, 0), mask)

    d = ImageDraw.Draw(img)
    (x0, y0), (x1, y1) = p(20, 22), p(80, 72)
    d.rounded_rectangle((x0, y0, x1, y1), radius=14 * u * scale, fill=WHITE)
    d.polygon([p(30, 70), p(26, 84), p(46, 70)], fill=WHITE)  # tail
    for a, b in (((45, 32), (55, 62)), ((35, 42), (65, 52))):  # cross
        (ax, ay), (bx, by) = p(*a), p(*b)
        d.rectangle((ax, ay, bx, by), fill=PRIMARY)

    out = img.resize((size, size), Image.LANCZOS)
    if not rounded:  # iOS rejects icons with transparency
        out = out.convert('RGB')
    return out


def save(path, size, **kw):
    path.parent.mkdir(parents=True, exist_ok=True)
    render(size, **kw).save(path, optimize=True)
    print(f'{path.relative_to(ROOT)} {size}px')


def web(app_dir):
    w = app_dir / 'web'
    save(w / 'favicon.png', 64)
    save(w / 'icons' / 'Icon-192.png', 192)
    save(w / 'icons' / 'Icon-512.png', 512)
    save(w / 'icons' / 'Icon-maskable-192.png', 192, rounded=False, scale=0.8)
    save(w / 'icons' / 'Icon-maskable-512.png', 512, rounded=False, scale=0.8)


def main():
    web(APP)
    web(ADMIN)

    res = APP / 'android' / 'app' / 'src' / 'main' / 'res'
    for folder, size in {'mdpi': 48, 'hdpi': 72, 'xhdpi': 96, 'xxhdpi': 144, 'xxxhdpi': 192}.items():
        save(res / f'mipmap-{folder}' / 'ic_launcher.png', size)

    ios = APP / 'ios' / 'Runner' / 'Assets.xcassets' / 'AppIcon.appiconset'
    for f in sorted(ios.glob('Icon-App-*.png')):
        save(f, Image.open(f).size[0], rounded=False)

    save(APP / 'tool' / 'brand' / 'logo-1024.png', 1024)


if __name__ == '__main__':
    main()
