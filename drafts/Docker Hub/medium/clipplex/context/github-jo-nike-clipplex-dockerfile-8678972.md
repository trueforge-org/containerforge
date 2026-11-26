# jo-nike/clipplex Dockerfile @ 8678972

Source: https://raw.githubusercontent.com/jo-nike/clipplex/8678972/Dockerfile (fetched 2026-11-26)

## Base / build
- `FROM alpine:3.15` (single stage)
- ARG PLEX_URL, PLEX_TOKEN, STREAMABLE_LOGIN, STREAMABLE_PASSWORD (no defaults)
- apk add --no-cache (unpinned): build-base tzdata ffmpeg python3 python3-dev py-pip
- forced symlink `python` -> `python3.9` in /usr/bin
- ENV TZ=America/New_York; ENV PLEX_URL, PLEX_TOKEN, STREAMABLE_LOGIN, STREAMABLE_PASSWORD from ARGs (creds baked into image env)
- COPY . /app; WORKDIR /app
- `pip install -r requirements.txt`
- `RUN set FLASK_APP=main.py` (Windows syntax; no effect on Linux; ENV needed)

## Runtime
- CMD shell form `flask run --host 0.0.0.0`
- No EXPOSE, VOLUME, USER (root), ENTRYPOINT, download URLs

## requirements.txt (HEAD)
- Flask==2.0.2, requests==2.26.0, flask_wtf==0.14.3, jinja2==3.0, Werkzeug==2.0.0, ffmpeg-python==0.2.0
