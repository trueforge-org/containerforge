# Docker Hub apache/tika

Source URL: https://hub.docker.com/r/apache/tika (fetched)

- Image: apache/tika (ASF); source repo apache/tika-docker
- Tags: follow Tika server version, e.g. `2.5.0` (minimal) and `2.5.0-full`; `latest` exists. Pages list 2.5.0 as example only.
- Full variant adds GDAL and Tesseract OCR; language packs eng, fra, deu, ita, spa.
- Exposed port: 9998
- Base: latest Ubuntu. Java 8 (<=1.20), Java 11 (1.21, 1.24.1), Java 14 (<=1.27/2.0.0), Java 16 (newer).
- CMD/entrypoint: not stated. Env vars: none documented. Architectures: not stated.
- Run: `docker run -d -p 127.0.0.1:9998:9998 apache/tika:<version>` (localhost bind recommended; Docker alters iptables).
- Build from source: github.com/apache/tika-docker
