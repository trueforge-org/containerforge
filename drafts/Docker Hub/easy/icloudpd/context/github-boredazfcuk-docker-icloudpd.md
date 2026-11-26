# GitHub: boredazfcuk/docker-icloudpd (reference third-party image source)

Source URL(s) + fetch date: https://github.com/boredazfcuk/docker-icloudpd/blob/master/icloudpd.dockerfile ; read from https://raw.githubusercontent.com/boredazfcuk/docker-icloudpd/master/icloudpd.dockerfile · fetched 2026-11-26

## What it is
Alpine-based Docker image that wraps icloudpd. Plan.md uses this only as a reference, not for copying.

## Install/build steps and build deps
- `FROM alpine:3.23.4`
- Build packages (virtual `build`, deleted after): `gcc python3-dev libc-dev libffi-dev cargo openssl-dev`
- App packages: `findutils nano nano-syntax py3-pip exiftool coreutils tzdata curl libheif imagemagick shadow jq jpeg bind-tools expect inotify-tools msmtp`
- `pip3 install --no-cache-dir icloudpd==${icloudpd_version}` with `ARG icloudpd_version="1.32.3"` (this Dockerfile pins 1.32.3, older than upstream 1.34.0).

## Runtime deps
- Python (pip), exiftool, imagemagick, libheif, jq, msmtp and others listed above.

## Binaries/entrypoint/CLI flags
- `CMD ["/usr/local/bin/launcher.sh"]`. No ENTRYPOINT.

## Env vars (table)
| Name | Value |
| --- | --- |
| XDG_DATA_HOME | `/config` |
| TZ | `UTC` |
| ENV | `/etc/profile` |
| config_file | `/config/icloudpd.conf` |

## Ports
- None exposed.

## Volumes/paths and persistent data
- `VOLUME /config`.

## User/UID & permissions
- No USER instruction (root).

## Healthcheck
- `HEALTHCHECK --start-period=10s --interval=1m --timeout=10s CMD /usr/local/bin/healthcheck.sh`

## Gotchas
- This image sets `XDG_DATA_HOME=/config`. Plan.md relies on it for the keyring location; this is how the reference image places the keyring, which partly supports plan.md's approach.
- The HEALTHCHECK runs a script, so the image's health status depends on the upstream wrapper, not on icloudpd alone (plan.md notes an 8080 probe caveat).
