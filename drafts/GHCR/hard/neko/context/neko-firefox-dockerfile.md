# Source: m1k1o/neko apps/firefox/Dockerfile (commit 92420ca8)

Source URL(s) + date: https://raw.githubusercontent.com/m1k1o/neko/92420ca8e4709c1ac49961c4bf5d3cc786d44f0d/apps/firefox/Dockerfile (fetched 2026-11-27)

## Build
- `ARG BASE_IMAGE=ghcr.io/m1k1o/neko/base:latest`, `FROM $BASE_IMAGE`.
- apt: openbox.
- Arch branches (via dpkg --print-architecture):
  - armhf: apt install firefox-esr; symlink /usr/lib/firefox -> firefox-esr; wget uBlock Origin and SponsorBlocker XPIs into /usr/lib/firefox-esr/distribution/extensions/ from addons.mozilla.org.
  - amd64: SRC_URL=https://download.mozilla.org/?product=firefox-latest&os=linux64&lang=en-US
  - arm64: SRC_URL=https://download.mozilla.org/?product=firefox-latest&os=linux64-aarch64&lang=en-US
  - amd64/arm64: apt install xz-utils libgtk-3-0 libdbus-glib-1-2; wget tarball; extract to /usr/lib/firefox; ln -s /usr/lib/firefox/firefox /usr/bin/firefox; purge xz-utils.
  - other arch: exit 1.
- Creates /home/neko/.mozilla/firefox/profile.default/extensions owned by neko.
- Cleanup apt lists.
- COPY: supervisord.conf -> /etc/neko/supervisord/firefox.conf; neko.js -> /usr/lib/firefox/mozilla.cfg; autoconfig.js -> /usr/lib/firefox/defaults/pref/autoconfig.js; policies.json -> /usr/lib/firefox/distribution/policies.json; profiles.ini -> /home/neko/.mozilla/firefox/profiles.ini (chown neko); openbox.xml -> /etc/neko/openbox.xml.

## Runtime deps
- Base image ghcr.io/m1k1o/neko/base (supervisord, neko server, Xorg stack not in this file).

## Gotchas
- Firefox downloaded at build time from Mozilla "latest" redirect: not pinned version. Image version is set by base/tag.
- Mozilla ftp release tarballs (ftp.mozilla.org/pub/firefox/releases/160.0.1/...) listed in urls.txt not fetched (binary).
