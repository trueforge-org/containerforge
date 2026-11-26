# sindresorhus/fast-cli

Source URL(s): https://github.com/sindresorhus/fast-cli (raw readme fetched: https://raw.githubusercontent.com/sindresorhus/fast-cli/main/readme.md)
Date: fetched 2026-11-26

## What it is
- CLI measuring download (optionally upload) speed via fast.com. Uses Puppeteer; downloads Chrome (~200 MB) on first use if absent.

## Install
- `npm install --global fast-cli` (image uses `npm i fast-cli` in /usr/src/app)
- Requires Node.js >= 22.12 (note: image base node:14 is incompatible with this requirement).

## Flags
| Flag | Effect |
| --- | --- |
| `-u`, `--upload` | also measure upload |
| `--single-line` | one-line output |
| `--json` | JSON output |
| `--verbose` | latency, server locations, client location/IP |

## Output
- Default: plain value, e.g. "17 Mbps"; redirectable (`fast > file`).
- JSON fields: downloadSpeed, uploadSpeed, downloadUnit, uploadUnit, downloaded, uploaded, latency, bufferBloat, userLocation, serverLocations, userIp.

## Gotchas
- License not stated on the page.
