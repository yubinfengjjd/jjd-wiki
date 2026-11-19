"""Compose figure graphics only, using page coordinates recorded after inspection."""
from pathlib import Path
import argparse

from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[1]
CROPS = {
    1: (3, (124, 96, 1128, 1357)),
    2: (4, (175, 88, 1080, 1346)),
    3: (6, (123, 98, 1128, 995)),
    4: (7, (181, 99, 1072, 1357)),
    5: (9, (179, 99, 1074, 1359)),
    6: (10, (149, 100, 1100, 1357)),
}

SUPPLEMENTARY = {
    "s1": (1, 1080),
    "s2": (2, 1262),
    "s3": (3, 1262),
    "s4": (4, 1262),
    "s5": (5, 1262),
    "s6": (6, 1262),
}


def build(figure):
    figure = str(figure)
    header = 38
    if figure in SUPPLEMENTARY:
        number, height = SUPPLEMENTARY[figure]
        stem = f"sfig{number:02}"
        original_path = ROOT / f"extracted/pages/supp_media/image{number}.png"
        region = None
    else:
        number = int(figure)
        page, region = CROPS[number]
        height = 1300
        stem = f"fig{number:02}"
        original_path = ROOT / f"extracted/pages/main_p{page:02}.png"
    replica_path = ROOT / f"review/{stem}_replica.png"
    with Image.open(original_path) as page_image, Image.open(replica_path) as replica:
        reference = page_image.convert("RGB")
        if region is not None:
            reference = reference.crop(region)
        panels = [
            panel.resize((round(panel.width * height / panel.height), height), Image.Resampling.LANCZOS)
            for panel in (reference, replica.convert("RGB"))
        ]
    output = Image.new("RGB", (sum(panel.width for panel in panels) + 3, height + header), "#ffffff")
    draw = ImageDraw.Draw(output)
    draw.rectangle((0, 0, output.width, header - 1), fill="#f0f0f0")
    draw.rectangle((panels[0].width, 0, panels[0].width + 2, output.height), fill="#c5c5c5")
    font = ImageFont.truetype("C:/Windows/Fonts/arial.ttf", 15)
    for x, panel, title in zip((0, panels[0].width + 3), panels, ("Original (Cai et al., 2026)", "1:1 Replica")):
        output.paste(panel, (x, header))
        draw.text((x + panel.width / 2, header / 2), title, font=font, fill="#222222", anchor="mm")
    if figure == "3":
        # The cropped page includes the lower-row F/G/H tags beside E's legend.
        # Mask only the prior row's three empty margins outside the A–E marks.
        sx = panels[0].width / (region[2] - region[0])
        sy = height / (region[3] - region[1])
        for x0, x1 in ((124, 161), (476, 510), (791, 821)):
            draw.rectangle(((x0-region[0])*sx, header+(968-region[1])*sy,
                            (x1-region[0])*sx, height+header-1), fill="white")
    directory = ROOT / "review/compare"
    directory.mkdir(exist_ok=True)
    result = directory / f"{stem}_side_by_side.png"
    output.save(result, optimize=True)
    if result.stat().st_size >= 5_000_000 or output.height > 1400:
        raise ValueError(f"Comparison exceeds delivery limits: {result}")
    print(f"{result.name} {output.width} x {output.height}, {result.stat().st_size:,} bytes")

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("figure", choices=[*(str(n) for n in CROPS), *SUPPLEMENTARY])
    build(parser.parse_args().figure)
