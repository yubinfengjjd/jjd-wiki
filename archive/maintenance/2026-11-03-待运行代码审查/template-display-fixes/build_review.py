"""Build bounded PNG/PDF review sheets from an existing, hash-bound replay."""
import argparse
import hashlib
import json
from pathlib import Path

import pypdfium2 as pdfium
from PIL import Image, ImageDraw, ImageOps


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--run-root", type=Path, required=True)
    parser.add_argument("--report", type=Path, required=True)
    args = parser.parse_args()
    destination = Path(__file__).resolve().parent
    cases = json.loads(args.report.read_text(encoding="utf-8"))["cases"]
    for number, case in enumerate(cases, 1):
        source = args.run_root / case["id"] / "output"
        for name, expected in case["outputs_sha256"].items():
            if hashlib.sha256((source / name).read_bytes()).hexdigest() != expected:
                raise ValueError(f"Output changed: {case['id']}/{name}")
        png = Image.open(source / "figure.png").convert("RGB")
        document = pdfium.PdfDocument(source / "figure.pdf")
        page = document[0]
        pdf = page.render(scale=2).to_pil().convert("RGB")
        sheet = Image.new("RGB", (1600, 900), "white")
        draw = ImageDraw.Draw(sheet)
        draw.text((12, 8), case["id"], fill="black")
        for index, (label, picture) in enumerate((("PNG", png), ("PDF", pdf))):
            draw.text((index * 800 + 12, 30), label, fill="black")
            thumbnail = ImageOps.contain(picture, (780, 835))
            sheet.paste(thumbnail, (index * 800 + (800-thumbnail.width)//2, 55))
        sheet.save(destination / f"{args.report.stem}-review-{number:02d}.jpg", quality=90)
        page.close()
        document.close()
    print(f"Reviewed-output hashes matched for {len(cases)} cases; sheets created")


if __name__ == "__main__":
    main()
