"""Inspect existing replay outputs and create compact PNG/PDF contact sheets."""
import argparse
import hashlib
import json
import os
import textwrap
from pathlib import Path

import numpy as np
import pypdfium2 as pdfium
from PIL import Image, ImageDraw, ImageFont, ImageOps


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def measure(image):
    rgb = image.convert("RGB")
    sample = rgb.copy()
    sample.thumbnail((800, 800))
    pixels = np.asarray(sample)
    nonwhite = np.any(pixels < 245, axis=2)
    bounds = Image.fromarray(nonwhite.astype("uint8") * 255).getbbox()
    return {"size": list(rgb.size), "nonwhite_fraction": round(float(nonwhite.mean()), 5),
            "sample_size": list(sample.size), "nonwhite_bounds": list(bounds) if bounds else None}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--env-root", type=Path, required=True)
    args = parser.parse_args()
    output = Path(__file__).resolve().parent
    record = output.parent
    fonts = Path(os.environ.get("WINDIR", str(Path.home()))) / "Fonts"
    font = ImageFont.truetype(str(fonts / "arial.ttf"), 17)
    title_font = ImageFont.truetype(str(fonts / "arialbd.ttf"), 19)
    cases = []
    previews = []
    for language in ("python", "r"):
        report_name = f"template-{language}-replay2.json"
        report = json.loads((record / report_name).read_text(encoding="utf-8"))
        run = args.env_root / "work" / f"template-{language}-pass2"
        for case in report["cases"]:
            root = run / case["id"] / "output"
            actual = {name: digest(root / name) for name in case["outputs_sha256"]}
            if actual != case["outputs_sha256"]:
                raise ValueError(f"Replay hash mismatch: {case['id']}")
            with Image.open(root / "figure.png") as image:
                png = Image.new("RGB", image.size, "white")
                if "A" in image.getbands():
                    png.paste(image.convert("RGB"), mask=image.getchannel("A"))
                else:
                    png.paste(image.convert("RGB"))
            document = pdfium.PdfDocument(root / "figure.pdf")
            if len(document) != 1:
                raise ValueError(f"Unexpected PDF page count: {case['id']}")
            page = document[0]
            pdf = page.render(scale=2).to_pil().convert("RGB")
            textpage = page.get_textpage()
            text = textpage.get_text_range()
            cases.append({"id": case["id"], "language": language,
                          "report": report_name, "report_state": case["state"],
                          "source": f"<env>/work/template-{language}-pass2/{case['id']}/output",
                          "outputs_sha256": actual, "hashes_match_replay": True,
                          "png": measure(png), "pdf_render": measure(pdf),
                          "pdf_page_count": len(document), "pdf_text": text,
                          "scientific_validation": False})
            previews.append((case["id"], png, pdf))
            textpage.close()
            page.close()
            document.close()
    sheets = []
    tile_w, tile_h = 700, 540
    for start in range(0, len(previews), 3):
        batch = previews[start:start + 3]
        sheet = Image.new("RGB", (tile_w * 2, tile_h * len(batch)), "#e8ecf0")
        draw = ImageDraw.Draw(sheet)
        for row, (identity, png, pdf) in enumerate(batch):
            for column, (format_name, image) in enumerate((("PNG", png), ("PDF render", pdf))):
                x, y = column * tile_w, row * tile_h
                draw.rectangle((x + 5, y + 5, x + tile_w - 5, y + tile_h - 5), fill="white")
                draw.text((x + 16, y + 12), f"{start + row + 1:02d} | {format_name}", font=title_font, fill="#102332")
                for line_number, line in enumerate(textwrap.wrap(identity, width=67)):
                    draw.text((x + 16, y + 39 + line_number * 20), line, font=font, fill="#263746")
                thumbnail = ImageOps.contain(image, (tile_w - 30, tile_h - 100))
                sheet.paste(thumbnail, (x + (tile_w - thumbnail.width) // 2,
                                        y + 90 + (tile_h - 100 - thumbnail.height) // 2))
                cases[start + row]["contact_sheet"] = f"contact-{start // 3 + 1:02d}.jpg"
        filename = f"contact-{start // 3 + 1:02d}.jpg"
        sheet.save(output / filename, quality=88, optimize=True)
        sheets.append(filename)
    summary = {"scope": "visual presentation QA of isolated public-example replay outputs",
               "scientific_validation": False, "case_count": len(cases),
               "all_hashes_match_replay": True, "contact_sheets": sheets, "cases": cases}
    (output / "output_inventory.json").write_text(json.dumps(summary, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(json.dumps({"case_count": len(cases), "sheets": sheets, "hashes_match": True}))


if __name__ == "__main__":
    main()
