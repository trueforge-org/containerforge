# Docker Hub: snoopy86/ffmpeg

Source URL(s) + fetch date:
- https://hub.docker.com/r/snoopy86/ffmpeg (fetched 2026-11-26)
- https://registry.hub.docker.com/r/snoopy86/ffmpeg (301 redirect to the hub.docker.com URL above; same page, not fetched separately)

## What it is

"A Docker container designed to watch a directory and encode media files." Single-maintainer image, last updated almost 6 years ago (plan says last pushed 2020-12-20). 50K+ pulls, 2 stars.

## Tags and arch

- Only tag: `latest`. Digest (per TrueCharts chart): `sha256:4d2695ffee46787cd39a222dbc7c8a42c5d4a1a2dd976d4e23bea00470ac55c9`.
- No architectures listed on the Hub page. Image size 58.5 MB. Pull command `docker pull snoopy86/ffmpeg`.

## Volumes

- `/config`, `/watch`, `/output`, `/copy`.

## Env vars

| Name | Use |
| --- | --- |
| `script` | `encode.sh` or `mkvdts2ac3.sh` |
| `parameters` | ffmpeg options, `;`-separated, e.g. `-map 0;-vcodec copy;-scodec copy;-acodec ac3;-b:a 640k` |
| `output_format` | ffmpeg output container, e.g. `mkv` |
| `mkvdts2ac3_params` | mkvdts2ac3 options, `;`-separated, e.g. `--compress none;-d;-n;-w /output;--new` |

## Behaviour (from the overview)

- encode.sh path: builds an ffmpeg command from input file, output format and `parameters`.
- mkvdts2ac3.sh path: runs `mkvdts2ac3.sh` with `mkvdts2ac3_params`.
- Exact script internals (`encode.sh`, `/copy` semantics) are not on the Hub page; not public source.

## Ports, healthcheck, user

- No ports documented. Hub page gives no user, UID or healthcheck.

## Gotchas

- The TrueCharts chart default sets `script: encode.sh` and `parameters: -map 0;-vcodec copy;-scodec copy;-acodec ac3;-b:a 640k`, and `mkvdts2ac3_params` as above (see truecharts file).
- No public Dockerfile or source.
