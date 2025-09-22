#!/usr/bin/env python3
"""
Make brand assets from one logo:
- icons/favicon-192.png
- favicon.ico (16/32/48)
- assets/social/rbis-card.png (1200x630)

Run:
  python3 make_brand_assets.py path/to/logo.png --site-root ./
"""
import argparse, os, sys
from PIL import Image, ImageDraw, ImageFont
from PIL.Image import Resampling
def make_square(im: Image.Image, size: int, bg=(255,255,255,0)) -> Image.Image:
    w, h = im.size
    if w >= h:
        new_w, new_h = size, int(size * h / w)
    else:
        new_h, new_w = size, int(size * w / h)
    im_resized = im.resize((new_w, new_h), Resampling.LANCZOS)
    canvas = Image.new("RGBA", (size, size), bg)
    canvas.paste(im_resized, ((size - new_w)//2, (size - new_h)//2), im_resized)
    return canvas

def ensure_dir(p): 
    os.makedirs(p, exist_ok=True)
def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("src", help="Path to the logo image (PNG/JPG)")
    ap.add_argument("--title", default="RBIS — Behavioural & Intelligence Services")
    ap.add_argument("--subtitle", default="Evidence-first software & intelligence for repairs, compliance,\nand audit-ready reporting.")
    ap.add_argument("--site-root", default="", help="If set, copies into icons/ and assets/social/ under this root.")
    ap.add_argument("--out-dir", default="brand_out", help="Temp output dir.")
    args = ap.parse_args()

    if not os.path.exists(args.src):
        sys.exit(f"❌ Source image not found: {args.src}")

    img = Image.open(args.src).convert("RGBA")
    ensure_dir(args.out_dir)
    # 192x192
    png192 = make_square(img, 192, (255,255,255,0))
    png192_path = os.path.join(args.out_dir, "favicon-192.png")
    png192.save(png192_path, "PNG")

    # ICO (16/32/48)
    ico_base = make_square(img, 48, (255,255,255,0)).convert("RGBA")
    ico_path = os.path.join(args.out_dir, "favicon.ico")
    ico_base.save(ico_path, format="ICO", sizes=[(16,16),(32,32),(48,48)])

    # Social card 1200x630
    card_w, card_h = 1200, 630
    card = Image.new("RGB", (card_w, card_h), (255,255,255))
    box = int(card_h*0.7)
    logo = make_square(img, box, (255,255,255,0))
    lm = 80
    logo_y = (card_h - logo.height)//2
    card.paste(logo, (lm, logo_y), logo)
    draw = ImageDraw.Draw(card)
    try:
        font_bold = ImageFont.truetype("DejaVuSans-Bold.ttf", 66)
        font_reg  = ImageFont.truetype("DejaVuSans.ttf", 38)
    except:
        font_bold = ImageFont.load_default()
        font_reg  = ImageFont.load_default()

    text_x = lm + logo.width + 60
    text_y = logo_y + 10
    draw.text((text_x, text_y), args.title, fill=(0,0,0), font=font_bold)
    draw.multiline_text((text_x, text_y+110), args.subtitle, fill=(40,40,40), font=font_reg, spacing=6)

    card_path = os.path.join(args.out_dir, "rbis-card.png")
    card.save(card_path, "PNG", optimize=True)

    print("✅ Generated:")
    print(" -", png192_path)
    print(" -", ico_path)
    print(" -", card_path)
    if args.site_root:
        icons_dir  = os.path.join(args.site_root, "icons")
        social_dir = os.path.join(args.site_root, "assets", "social")
        ensure_dir(icons_dir); ensure_dir(social_dir)
        os.replace(ico_path,    os.path.join(args.site_root, "favicon.ico"))
        os.replace(png192_path, os.path.join(icons_dir, "favicon-192.png"))
        os.replace(card_path,   os.path.join(social_dir, "rbis-card.png"))
        print("📦 Copied into site folders.")
        print('   <link rel="icon" href="/favicon.ico">')
        print('   <link rel="icon" type="image/png" sizes="192x192" href="/icons/favicon-192.png">')
        print('   <meta property="og:image" content="https://www.rbisintelligence.com/assets/social/rbis-card.png">')

if __name__ == "__main__":
    main()
