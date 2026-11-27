# deconz-docker download-deconz.sh

Source URL: https://raw.githubusercontent.com/deconz-community/deconz-docker/f23db7e09be257f35e3e753e69fda7494ea94d52/docker/download-deconz.sh (fetched 2026-11-27)

## What it does
`download-deconz.sh <VERSION> <CHANNEL> <TARGETPLATFORM>`, `set -ex`.

## URL selection (plain HTTP)
| Platform match | URL |
| --- | --- |
| arm64 | `http://deconz.dresden-elektronik.de/debian/${CHANNEL}/deconz_${VERSION}-debian-buster-${CHANNEL}_arm64.deb` |
| amd64 | `http://deconz.dresden-elektronik.de/ubuntu/${CHANNEL}/deconz-${VERSION}-qt5.deb` |
| v7 (arm/v7) | `http://deconz.dresden-elektronik.de/raspbian/${CHANNEL}/deconz-${VERSION}-qt5.deb` |

- Output: `curl -vv "${URL}" -o /deconz${DEV}.deb` (`DEV` unset, so `/deconz.deb`).
- No checksum or signature verification.
- Unknown platform: URL unset, curl gets empty arg (script does not fail explicitly).

## Gotchas
- HTTP only; pin sha256 yourself if reused.
