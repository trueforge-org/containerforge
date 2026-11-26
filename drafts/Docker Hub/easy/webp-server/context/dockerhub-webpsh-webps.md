# Docker Hub: webpsh/webps

Source URL(s) + fetch date: https://hub.docker.com/r/webpsh/webps · fetched 2026-11-26

## What it is
- Golang server converting images to WebP on the fly. Default handles jpg, jpeg, png (changeable in config.json). Supports JPEG, PNG, BMP and static GIF. Safari and Opera desktop receive the original. GPLv3. 100K+ pulls.

## Run
- Page describes a binary workflow: `./webp-server -dump-config > config.json`, then `./webp-server --config=/path/to/config.json`, Nginx `proxy_pass http://localhost:3333/;`. Docker and supervisor setups point to docs.webp.sh.
- Pull: `docker pull webpsh/webps`. No docker run example.

## Config keys shown
- HOST (127.0.0.1), PORT (3333), QUALITY (80), IMG_PATH, EXHAUST_PATH, ALLOWED_TYPES (jpg, png, jpeg, bmp), ENABLE_AVIF (false).

## Env vars, ports, volumes
- None documented as env vars. No Docker volumes or port mapping documented.

## Version/release info
- Only `latest` tag shown (digest `sha256:3b9e2e53...`, 78.8 MB, updated about 2 months before capture; repo updated about 1 month before capture).

## Arch support
- Not documented.

## Gotchas
- The listing is older and binary-focused (ENABLE_AVIF key here is not in the current 0.16.2 config.json). Use the GitHub repo summary as the primary source.
