# Docker Hub: rhasspy/wyoming-openwakeword

Source URL(s) + fetch date: https://hub.docker.com/r/rhasspy/wyoming-openwakeword · fetched 2026-11-26

## What it is
- "Wyoming protocol server for openWakeWord wake word detection system." Published by rhasspy. 1M+ pulls.

## Run (verbatim from page)
- `docker run -it -p 10400:10400 rhasspy/wyoming-openwakeword --preload-model 'ok_nabu'`
- Custom models: `docker run -it -p 10400:10400 -v /path/to/custom/models:/custom rhasspy/wyoming-openwakeword --preload-model 'ok_nabu' --custom-model-dir /custom`
- Pull: `docker pull rhasspy/wyoming-openwakeword`.
- Prose calls the flag `--preloaded-model`, examples use `--preload-model`. The fetched v2.1.0 code marks `--preload-model` deprecated and unused.

## Env vars
- None documented.

## Ports
- 10400.

## Volumes
- Optional bind mount at `/custom` for custom models.

## Version/release info
- Only `latest` tag shown (digest `sha256:52cb1168...`, 88 MB, updated about a year before capture).

## Arch support
- Not listed.

## Gotchas
- The page examples are stale for v2.1.0 (deprecated flag).
