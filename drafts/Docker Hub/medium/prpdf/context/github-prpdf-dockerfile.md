# GitHub: maschhoff/prpdf Dockerfile, requirements, release

Source URL(s):
- https://raw.githubusercontent.com/maschhoff/prpdf/main/Dockerfile
- https://raw.githubusercontent.com/maschhoff/pdfscanexplorer/main/requirements.txt
- https://api.github.com/repos/maschhoff/prpdf/releases/latest (redirected to pdfscanexplorer repo)
Fetched: 2026-11-27

## Dockerfile
### Stage 1 builder: python:3.11-slim-bookworm
| Step | Detail |
| --- | --- |
| build deps | build-essential, autoconf, automake, libtool, pkg-config, git, wget, curl, ca-certificates, libleptonica-dev, cmake |
| jbig2enc | git clone github.com/agl/jbig2enc; autogen, configure, make; copy `src/jbig2` to /usr/local/bin/jbig2enc |
| Ghostscript | wget ghostscript-10.03.1.tar.gz from ArtifexSoftware/ghostpdl-downloads release gs10031; configure, make, make install |

### Stage 2 final: python:3.11-slim-bookworm
| Item | Value |
| --- | --- |
| WORKDIR | /source |
| ENV | WORKDIR=/source, FLASK_APP=prpdf.py, FLASK_RUN_HOST=0.0.0.0, FLASK_RUN_PORT=80 |
| apt runtime | tesseract-ocr, tesseract-ocr-deu, poppler-utils, qpdf, libjpeg-dev, libpng-dev, libfreetype6-dev, zlib1g-dev, libopenjp2-7 |
| copied | /usr/local/bin/jbig2enc, /usr/local/bin/gs from builder; `./` to /source |
| pip | `pip3 install -r /source/requirements.txt` |
| CMD | `["flask", "run"]` |
| EXPOSE / USER / VOLUME | none |

## requirements.txt (pdfscanexplorer main; prpdf repo copy not fetched)
flask, Pillow, pytesseract, pdf2image, PyPDF2, ocrmypdf, pycryptodome, openai, google-generativeai, anthropic (unpinned). Comments: pdfsplit (disabled), apt tesseract/poppler notes.

## Release
- releases/latest for maschhoff/prpdf resolves to repo maschhoff/pdfscanexplorer: tag `1.0.2` ("Stable 1.0.2", published 2026-09-09, no assets; tarball/zipball only). Notes: more AI support, camera scan, responsive view, document upload.
- Image has no version tag; only `latest` / `latest-dev`.

## Gotchas
- Repo was renamed/moved: prpdf API redirects to pdfscanexplorer; the Dockerfile lives in maschhoff/prpdf.
- Dockerfile default CMD is `flask run` with FLASK_APP=prpdf.py, port 80 via FLASK_RUN_PORT; Docker Hub README runs `python3 /source/prpdf.py` instead.
- Ghostscript 10.03.1 and jbig2enc are compiled from source (no pinned hash).
- Requirements unpinned: rebuilds pick latest packages.
- Runtime needs tesseract German language pack (tesseract-ocr-deu) per Dockerfile.
