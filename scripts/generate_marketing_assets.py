from pathlib import Path
from PIL import Image, ImageDraw, ImageFont, ImageFilter

ROOT = Path(__file__).resolve().parents[1]
ICON_SOURCE = ROOT / "MarketingAssets" / "Icons" / "aihostcall-ikemen-source.png"
OUT = ROOT / "MarketingAssets" / "Screenshots"
OUT.mkdir(parents=True, exist_ok=True)

DEVICES = {
    "iphone69": (1320, 2868),
    "iphone65": (1242, 2688),
    "iphone55": (1242, 2208),
    "ipad129": (2048, 2732),
}

GOLD = (242, 184, 74)
SOFT_GOLD = (255, 223, 143)
BLACK = (8, 7, 6)
PANEL = (28, 23, 17)
PANEL_2 = (45, 35, 24)
WHITE = (250, 247, 240)
MUTED = (190, 178, 155)
RED = (212, 56, 54)


def font(size, bold=False):
    candidates = [
        "C:/Windows/Fonts/YuGothB.ttc" if bold else "C:/Windows/Fonts/YuGothR.ttc",
        "C:/Windows/Fonts/meiryo.ttc",
        "C:/Windows/Fonts/msgothic.ttc",
    ]
    for path in candidates:
        if Path(path).exists():
            return ImageFont.truetype(path, size)
    return ImageFont.load_default(size)


def fit_text(draw, text, max_width, size, bold=False):
    current = size
    while current > 20:
        f = font(current, bold)
        if draw.textbbox((0, 0), text, font=f)[2] <= max_width:
            return f
        current -= 2
    return font(current, bold)


def cover(image, size, focus_y=0.45):
    iw, ih = image.size
    w, h = size
    scale = max(w / iw, h / ih)
    nw, nh = int(iw * scale), int(ih * scale)
    resized = image.resize((nw, nh), Image.Resampling.LANCZOS)
    x = (nw - w) // 2
    y = int((nh - h) * focus_y)
    return resized.crop((x, y, x + w, y + h))


def gradient(size):
    w, h = size
    sw, sh = 96, 160
    img = Image.new("RGB", (sw, sh), BLACK)
    px = img.load()
    for y in range(sh):
        for x in range(sw):
            t = y / max(1, sh - 1)
            glow = max(0, 1 - ((x - sw * 0.72) ** 2 + (y - sh * 0.05) ** 2) ** 0.5 / (sw * 0.8))
            r = int(8 + 26 * t + 34 * glow)
            g = int(7 + 18 * t + 20 * glow)
            b = int(6 + 10 * t)
            px[x, y] = (r, g, b)
    return img.resize(size, Image.Resampling.BICUBIC)


def rounded(draw, box, radius, fill, outline=None, width=1):
    draw.rounded_rectangle(box, radius=radius, fill=fill, outline=outline, width=width)


def text(draw, xy, body, size, fill=WHITE, bold=False, anchor=None, max_width=None):
    f = fit_text(draw, body, max_width, size, bold) if max_width else font(size, bold)
    draw.text(xy, body, font=f, fill=fill, anchor=anchor)
    return f


def multiline(draw, xy, body, size, fill=WHITE, bold=False, spacing=8, max_width=None):
    f = font(size, bold)
    lines = []
    current = ""
    for ch in body:
        probe = current + ch
        if max_width and draw.textbbox((0, 0), probe, font=f)[2] > max_width and current:
            lines.append(current)
            current = ch
        else:
            current = probe
    if current:
        lines.append(current)
    draw.multiline_text(xy, "\n".join(lines), font=f, fill=fill, spacing=spacing)


def paste_hero(canvas, hero, x, y, w, h, radius):
    crop = cover(hero, (w, h), focus_y=0.22)
    crop = crop.filter(ImageFilter.UnsharpMask(radius=1, percent=120))
    mask = Image.new("L", (w, h), 0)
    ImageDraw.Draw(mask).rounded_rectangle((0, 0, w, h), radius=radius, fill=255)
    canvas.paste(crop, (x, y), mask)


def phone_chrome(draw, w, h):
    pad = int(w * 0.055)
    status_y = int(h * 0.035)
    text(draw, (pad, status_y), "22:30", int(w * 0.035), SOFT_GOLD, bold=True)
    draw.ellipse((w - pad - 82, status_y + 4, w - pad - 52, status_y + 34), fill=SOFT_GOLD)
    draw.rounded_rectangle((w - pad - 48, status_y + 8, w - pad, status_y + 30), radius=11, outline=SOFT_GOLD, width=3)


def mic_symbol(draw, cx, cy, scale, fill):
    mic_w = int(scale * 0.42)
    mic_h = int(scale * 0.72)
    top = cy - int(scale * 0.42)
    draw.rounded_rectangle(
        (cx - mic_w // 2, top, cx + mic_w // 2, top + mic_h),
        radius=mic_w // 2,
        outline=fill,
        width=max(5, int(scale * 0.06)),
    )
    arc_box = (
        cx - int(scale * 0.42),
        cy - int(scale * 0.05),
        cx + int(scale * 0.42),
        cy + int(scale * 0.55),
    )
    draw.arc(arc_box, 0, 180, fill=fill, width=max(5, int(scale * 0.06)))
    draw.line((cx, cy + int(scale * 0.55), cx, cy + int(scale * 0.82)), fill=fill, width=max(5, int(scale * 0.06)))
    draw.line((cx - int(scale * 0.24), cy + int(scale * 0.82), cx + int(scale * 0.24), cy + int(scale * 0.82)), fill=fill, width=max(5, int(scale * 0.06)))


def home_screen(size, hero):
    w, h = size
    canvas = gradient(size)
    draw = ImageDraw.Draw(canvas)
    phone_chrome(draw, w, h)

    margin = int(w * 0.07)
    y = int(h * 0.1)
    paste_hero(canvas, hero, margin, y, w - margin * 2, int(h * 0.36), int(w * 0.04))

    y += int(h * 0.39)
    text(draw, (margin, y), "ホスコール", int(w * 0.075), WHITE, bold=True, max_width=w - margin * 2)
    y += int(w * 0.095)
    multiline(draw, (margin, y), "声で話すと、AIホストがすぐ返す。無料ではじめる会話練習。", int(w * 0.036), MUTED, max_width=w - margin * 2)
    y += int(w * 0.14)

    rounded(draw, (margin, y, w - margin, y + int(h * 0.18)), int(w * 0.025), PANEL, (104, 78, 34), 2)
    text(draw, (margin + 32, y + 28), "ホストタイプ", int(w * 0.034), SOFT_GOLD, bold=True)
    labels = ["優しいホスト", "オラオラ系", "犬系", "メン地下系", "社長系"]
    gx, gy = margin + 30, y + int(w * 0.09)
    bw = (w - margin * 2 - 78) // 2
    bh = int(w * 0.08)
    for i, label in enumerate(labels):
        cx = gx + (i % 2) * (bw + 18)
        cy = gy + (i // 2) * (bh + 14)
        fill = GOLD if i == 0 else PANEL_2
        rounded(draw, (cx, cy, cx + bw, cy + bh), 18, fill)
        text(draw, (cx + bw // 2, cy + bh // 2), label, int(w * 0.028), BLACK if i == 0 else WHITE, bold=True, anchor="mm", max_width=bw - 20)

    by = h - int(h * 0.13)
    rounded(draw, (margin, by, w - margin, by + int(w * 0.09)), 24, GOLD)
    text(draw, (w // 2, by + int(w * 0.045)), "通話開始", int(w * 0.036), BLACK, bold=True, anchor="mm")
    return canvas


def call_screen(size, hero):
    w, h = size
    canvas = gradient(size)
    draw = ImageDraw.Draw(canvas)
    phone_chrome(draw, w, h)
    margin = int(w * 0.07)
    y = int(h * 0.11)

    text(draw, (margin, y), "声で話すだけ", int(w * 0.075), WHITE, bold=True, max_width=w - margin * 2)
    y += int(w * 0.09)
    text(draw, (margin, y), "即答モード", int(w * 0.036), SOFT_GOLD, bold=True)
    y += int(w * 0.07)

    paste_hero(canvas, hero, margin, y, w - margin * 2, int(h * 0.31), int(w * 0.04))
    y += int(h * 0.34)

    for title, body in [
        ("あなた", "今日ちょっと緊張してる"),
        ("優しい", "うん、ちゃんと伝わってるよ。もう少し聞かせて。"),
    ]:
        rounded(draw, (margin, y, w - margin, y + int(h * 0.12)), 22, PANEL, (90, 67, 28), 2)
        text(draw, (margin + 30, y + 24), title, int(w * 0.027), SOFT_GOLD, bold=True)
        multiline(draw, (margin + 30, y + int(w * 0.07)), body, int(w * 0.034), WHITE, bold=True, max_width=w - margin * 2 - 60)
        y += int(h * 0.14)

    cx, cy, r = w // 2, h - int(h * 0.19), int(w * 0.105)
    draw.ellipse((cx - r, cy - r, cx + r, cy + r), fill=GOLD)
    mic_symbol(draw, cx, cy - int(r * 0.05), int(r * 0.8), BLACK)
    text(draw, (cx, cy + r + 34), "押して話す", int(w * 0.03), MUTED, bold=True, anchor="mm")
    return canvas


def voice_screen(size, hero):
    w, h = size
    canvas = gradient(size)
    draw = ImageDraw.Draw(canvas)
    phone_chrome(draw, w, h)
    margin = int(w * 0.07)
    y = int(h * 0.1)

    text(draw, (margin, y), "無料でも自然に", int(w * 0.07), WHITE, bold=True, max_width=w - margin * 2)
    y += int(w * 0.09)
    multiline(draw, (margin, y), "iPhone標準音声から高品質な日本語ボイスを自動選択。", int(w * 0.036), MUTED, max_width=w - margin * 2)
    y += int(w * 0.13)

    paste_hero(canvas, hero, margin, y, w - margin * 2, int(h * 0.28), int(w * 0.04))
    y += int(h * 0.31)

    rounded(draw, (margin, y, w - margin, y + int(h * 0.26)), 22, PANEL, (90, 67, 28), 2)
    text(draw, (margin + 30, y + 30), "声の調整", int(w * 0.04), SOFT_GOLD, bold=True)
    rows = [("速さ", 0.58), ("高さ", 0.42), ("音量", 0.88), ("音声", None)]
    sy = y + int(w * 0.11)
    for label, value in rows:
        text(draw, (margin + 30, sy), label, int(w * 0.03), MUTED, bold=True)
        if value is None:
            text(draw, (margin + int(w * 0.19), sy), "日本語プレミアム", int(w * 0.03), WHITE, bold=True)
        else:
            x1 = margin + int(w * 0.19)
            x2 = w - margin - 34
            yy = sy + int(w * 0.018)
            draw.rounded_rectangle((x1, yy, x2, yy + 8), radius=4, fill=(88, 70, 42))
            draw.rounded_rectangle((x1, yy, int(x1 + (x2 - x1) * value), yy + 8), radius=4, fill=GOLD)
            knob = int(x1 + (x2 - x1) * value)
            draw.ellipse((knob - 13, yy - 9, knob + 13, yy + 17), fill=SOFT_GOLD)
        sy += int(w * 0.07)
    return canvas


def result_screen(size, hero):
    w, h = size
    canvas = gradient(size)
    draw = ImageDraw.Draw(canvas)
    phone_chrome(draw, w, h)
    margin = int(w * 0.07)
    y = int(h * 0.09)

    text(draw, (margin, y), "会話のあとも練習", int(w * 0.066), WHITE, bold=True, max_width=w - margin * 2)
    y += int(w * 0.085)
    paste_hero(canvas, hero, margin, y, w - margin * 2, int(h * 0.24), int(w * 0.04))
    y += int(h * 0.27)

    rounded(draw, (margin, y, w - margin, y + int(h * 0.15)), 22, PANEL, (90, 67, 28), 2)
    text(draw, (w // 2, y + int(h * 0.055)), "92", int(w * 0.095), GOLD, bold=True, anchor="mm")
    text(draw, (w // 2, y + int(h * 0.105)), "会話スコア", int(w * 0.032), MUTED, bold=True, anchor="mm")
    y += int(h * 0.18)

    cards = [
        ("改善アドバイス", "理由を一言足すと、もっと自然に続きます。"),
        ("次に使える一言", "それ、もう少し聞いてほしいな。"),
        ("会話ログ", "あなた: 今日ちょっと緊張してる\nAI: うん、ちゃんと伝わってるよ。"),
    ]
    for title, body in cards:
        card_h = int(h * 0.115)
        rounded(draw, (margin, y, w - margin, y + card_h), 22, PANEL, (90, 67, 28), 2)
        text(draw, (margin + 30, y + 24), title, int(w * 0.03), SOFT_GOLD, bold=True)
        multiline(draw, (margin + 30, y + int(w * 0.07)), body, int(w * 0.028), WHITE, max_width=w - margin * 2 - 60)
        y += card_h + int(w * 0.035)
    return canvas


def main():
    hero = Image.open(ICON_SOURCE).convert("RGB")
    screens = [
        ("01_home", home_screen),
        ("02_call", call_screen),
        ("03_voice", voice_screen),
        ("04_result", result_screen),
    ]
    for device, size in DEVICES.items():
        for slug, maker in screens:
            image = maker(size, hero)
            image.save(OUT / f"{device}_{slug}.png", optimize=True)


if __name__ == "__main__":
    main()
