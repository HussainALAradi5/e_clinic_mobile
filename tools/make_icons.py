"""Draws the e-Clinic icons from the brand mark and the Material icon font (no image files needed):

- the app icon: Android launcher icons (legacy and adaptive) and the web favicon / home-screen icons;
- one notification image per kind of message: its colour with its icon in white, the same pair the inbox shows.

Usage (from the repository root, with Pillow installed):
  python tools/make_icons.py apps/clinic/android/app/src/main/res ../e_clinic_client/public
Android gets mipmap-*/ic_launcher.png, drawable-*/ic_launcher_foreground.png, mipmap-anydpi-v26/ic_launcher.xml and
drawable-nodpi/notify_<kind>.png; the web client favicon.ico, icons/icon-<size>.png and
notifications/notify-<kind>.png. The icon font is Flutter's own (bin/cache/artifacts/material_fonts).
"""
import os
import shutil
import sys

from PIL import Image, ImageDraw, ImageFont

# The brand mark (web brand-mark component): teal rounded square, white plus, gold dot.
TEAL = (11, 93, 87)
GOLD = (242, 181, 68)
WHITE = (255, 255, 255)

# kind -> (colour, Material icon codepoint): the inbox colour (Material 700 shade, so white reads on amber and
# cyan too) and the rounded icon of the apps (NotificationKindIcon / NOTIFICATION_KIND_ICONS).
KINDS = {
    'visit': ((25, 118, 210), 0xF71C),        # event
    'treatment': ((0, 121, 107), 0xF0144),    # self_improvement
    'result': ((123, 31, 162), 0xF5BC),       # biotech
    'pharmacy': ((56, 142, 60), 0xF8B1),      # medication
    'billing': ((255, 160, 0), 0xF0058),      # payments
    'hr': ((48, 63, 159), 0xF5A5),            # badge
    'chat': ((0, 151, 167), 0xF79D),          # forum
    'support': ((245, 124, 0), 0xF01F5),      # support_agent
    'urgent': ((211, 47, 47), 0xF00C1),       # priority_high
    'files': ((194, 24, 91), 0xF6DD),         # download_done
    'system': ((113, 113, 122), 0xF002A),     # notifications
}

LAUNCHER = {'mdpi': 48, 'hdpi': 72, 'xhdpi': 96, 'xxhdpi': 144, 'xxxhdpi': 192}
SCALE = 4  # draw large, then shrink: smooth edges


def icon_font(size):
    flutter = shutil.which('flutter')
    if flutter is None:
        raise SystemExit('flutter is not on PATH (the icon font comes with it)')
    root = os.path.dirname(os.path.realpath(flutter))
    return ImageFont.truetype(os.path.join(root, 'cache', 'artifacts', 'material_fonts', 'materialicons-regular.otf'), size)


def plus(draw, box, colour):
    """The mark's plus (path M13.2 7.5h5.6v5.7h5.7v5.6h-5.7v5.7h-5.6v-5.7H7.5v-5.6h5.7z on a 32 grid)."""
    x0, y0, x1, y1 = box
    u = (x1 - x0) / 32
    pts = [(13.2, 7.5), (18.8, 7.5), (18.8, 13.2), (24.5, 13.2), (24.5, 18.8), (18.8, 18.8), (18.8, 24.5),
           (13.2, 24.5), (13.2, 18.8), (7.5, 18.8), (7.5, 13.2), (13.2, 13.2)]
    draw.polygon([(x0 + x * u, y0 + y * u) for x, y in pts], fill=colour)
    r = 2.4 * u
    cx, cy = x0 + 23.6 * u, y0 + 8.4 * u
    draw.ellipse((cx - r, cy - r, cx + r, cy + r), fill=GOLD)


def brand_mark(size, rounded=True):
    big = size * SCALE
    img = Image.new('RGBA', (big, big), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    draw.rounded_rectangle((0, 0, big - 1, big - 1), radius=big * 9 / 32 if rounded else 0, fill=TEAL)
    plus(draw, (0, 0, big, big), WHITE)
    return img.resize((size, size), Image.LANCZOS)


def foreground(size):
    """Adaptive icon layer (108 dp): the plus and dot inside the 66 dp safe zone, on transparent."""
    big = size * SCALE
    img = Image.new('RGBA', (big, big), (0, 0, 0, 0))
    inset = big * 21 / 108
    plus(ImageDraw.Draw(img), (inset, inset, big - inset, big - inset), WHITE)
    return img.resize((size, size), Image.LANCZOS)


def kind_image(colour, codepoint, size=192):
    big = size * SCALE
    img = Image.new('RGBA', (big, big), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    draw.ellipse((0, 0, big - 1, big - 1), fill=colour)
    font = icon_font(int(big * 0.58))
    glyph = chr(codepoint)
    l, t, r, b = draw.textbbox((0, 0), glyph, font=font)
    draw.text(((big - (r - l)) / 2 - l, (big - (b - t)) / 2 - t), glyph, font=font, fill=WHITE)
    return img.resize((size, size), Image.LANCZOS)


def main(res_dir, web_dir):
    for density, px in LAUNCHER.items():
        mip = os.path.join(res_dir, f'mipmap-{density}')
        os.makedirs(mip, exist_ok=True)
        brand_mark(px).save(os.path.join(mip, 'ic_launcher.png'))
        draw_dir = os.path.join(res_dir, f'drawable-{density}')
        os.makedirs(draw_dir, exist_ok=True)
        foreground(px * 108 // 48).save(os.path.join(draw_dir, 'ic_launcher_foreground.png'))
    adaptive = os.path.join(res_dir, 'mipmap-anydpi-v26')
    os.makedirs(adaptive, exist_ok=True)
    with open(os.path.join(adaptive, 'ic_launcher.xml'), 'w', encoding='utf-8') as f:
        f.write('<?xml version="1.0" encoding="utf-8"?>\n'
                '<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">\n'
                '    <background android:drawable="@color/ic_launcher_background" />\n'
                '    <foreground android:drawable="@drawable/ic_launcher_foreground" />\n'
                '    <monochrome android:drawable="@drawable/ic_launcher_foreground" />\n'
                '</adaptive-icon>\n')
    with open(os.path.join(res_dir, 'values', 'ic_launcher_background.xml'), 'w', encoding='utf-8') as f:
        f.write('<?xml version="1.0" encoding="utf-8"?>\n<resources>\n'
                '    <color name="ic_launcher_background">#0B5D57</color>\n</resources>\n')

    nodpi = os.path.join(res_dir, 'drawable-nodpi')
    os.makedirs(nodpi, exist_ok=True)
    web_kinds = os.path.join(web_dir, 'notifications')
    os.makedirs(web_kinds, exist_ok=True)
    for kind, (colour, codepoint) in KINDS.items():
        image = kind_image(colour, codepoint)
        image.save(os.path.join(nodpi, f'notify_{kind}.png'))
        image.save(os.path.join(web_kinds, f'notify-{kind}.png'))

    icons = os.path.join(web_dir, 'icons')
    os.makedirs(icons, exist_ok=True)
    for px in (180, 192, 512):
        brand_mark(px).save(os.path.join(icons, f'icon-{px}.png'))
    brand_mark(256).save(os.path.join(web_dir, 'favicon.ico'), sizes=[(16, 16), (32, 32), (48, 48), (64, 64)])
    print(f'launcher icons, favicon and {len(KINDS)} notification images written')


if __name__ == '__main__':
    main(sys.argv[1], sys.argv[2])
