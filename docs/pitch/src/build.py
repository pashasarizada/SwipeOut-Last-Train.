"""Assemble the pitch pages, print them to PDF with headless Chrome and
render PNG previews for checking. Usage: python3 build.py OUT.pdf"""
import pathlib
import subprocess
import sys

import pypdfium2 as pdfium

here = pathlib.Path(__file__).parent
out = pathlib.Path(sys.argv[1]).resolve()
parts = [p for p in ["pages_game.html", "pages_market.html"] if (here / p).exists()]
body = "\n".join((here / p).read_text(encoding="utf-8") for p in parts)
html = f"""<!doctype html><html lang="tr"><head><meta charset="utf-8">
<title>Last Train — Tanıtım ve Pazarlama</title>
<link rel="stylesheet" href="base.css"><link rel="stylesheet" href="pages.css"></head>
<body>{body}</body></html>"""
(here / "index.html").write_text(html, encoding="utf-8")

chrome = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
subprocess.run([chrome, "--headless=new", "--disable-gpu", "--no-pdf-header-footer",
                "--allow-file-access-from-files", "--virtual-time-budget=4000",
                f"--print-to-pdf={out}", (here / "index.html").as_uri()],
               check=True, capture_output=True)

pdf = pdfium.PdfDocument(str(out))
print(f"{out.name}: {len(pdf)} pages")
for i, page in enumerate(pdf):
    page.render(scale=1.4).to_pil().save(here / f"preview-{i + 1}.png")
