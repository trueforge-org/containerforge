# Source: m1k1o/neko apps/chromium/Dockerfile (commit 92420ca8)

Source URL(s) + date: https://raw.githubusercontent.com/m1k1o/neko/92420ca8e4709c1ac49961c4bf5d3cc786d44f0d/apps/chromium/Dockerfile (fetched 2026-11-27)

## Build
- `ARG BASE_IMAGE=ghcr.io/m1k1o/neko/base:latest`, `FROM $BASE_IMAGE`.
- COPY ./widevinecdm.sh /widevine.sh.
- apt: chromium chromium-common chromium-sandbox openbox.
- amd64: apt xz-utils; run ./widevine.sh "/usr/lib/chromium/WidevineCdm"; remove script; purge xz-utils.
- arm64: copy /var/lib/widevine/WidevineCdm/* into /usr/lib/chromium/WidevineCdm/.
- other arch: echo message only.
- COPY: supervisord.conf -> /etc/neko/supervisord/chromium.conf; preferences.json -> /home/neko/.config/chromium/Default/Preferences; policies.json -> /etc/chromium/policies/managed/policies.json; openbox.xml -> /etc/neko/openbox.xml.

## Gotchas
- Widevine only on amd64 (downloaded by script) and arm64 (copied from base).
