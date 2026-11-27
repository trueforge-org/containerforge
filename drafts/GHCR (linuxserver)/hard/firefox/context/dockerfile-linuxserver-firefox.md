# Upstream Dockerfile: linuxserver/docker-firefox

Source URL(s):
- https://raw.githubusercontent.com/linuxserver/docker-firefox/1be26bbc8f8aa6fea0e94f46a68bbc660a030d47/Dockerfile
- Blob variant (same content): https://github.com/linuxserver/docker-firefox/blob/1be26bbc8f8aa6fea0e94f46a68bbc660a030d47/Dockerfile
- Fetched 2026-11-27

## What it is
Single-stage Dockerfile on the Selkies desktop-streaming base. Installs Firefox from an apt PPA.

## Base
- `FROM ghcr.io/linuxserver/baseimage-selkies:ubunturesolute`

## Args / labels / env
- ARGs: `BUILD_DATE`, `VERSION`, `FIREFOX_VERSION` (declared, not used in RUN).
- LABEL build_version, maintainer thelamer.
- `ENV TITLE=Firefox PIXELFLUX_WAYLAND=true`

## Install steps (RUN, one layer)
1. `curl -o /usr/share/selkies/www/icon.png` from linuxserver docker-templates (icon, remote fetch at build).
2. `add-apt-repository ppa:xtradeb/apps`, `apt-get update`.
3. `apt-get install -y --no-install-recommends firefox ^firefox-locale`
4. Writes `/usr/lib/firefox/browser/defaults/preferences/firefox.js` with prefs:
   - datareporting.policy.firstRunURL = ""
   - datareporting.policy.dataSubmissionEnabled = false
   - datareporting.healthreport.service.enabled = false
   - datareporting.healthreport.uploadEnabled = false
   - trailhead.firstrun.branches = "nofirstrun-empty"
   - browser.aboutwelcome.enabled = false
   - security.sandbox.warn_unprivileged_namespaces = false
5. Writes `/build_version` ("Linuxserver.io version: ${VERSION}\nBuild-date: ${BUILD_DATE}").
6. Cleanup: `apt-get autoclean`, rm `/config/.cache`, `/config/.launchpadlib`, `/var/lib/apt/lists/*`, `/var/tmp/*`, `/tmp/*`.

## Runtime
- `COPY /root /` (s6 service files from repo root/ dir, not fetched).
- `EXPOSE 3001`
- `VOLUME /config`
- No USER, no ENTRYPOINT, no CMD in this file (inherited from base).

## Gotchas
- Firefox comes from the xtradeb PPA, not Mozilla's tarball.
- Port 3001 is the web (Selkies) port. Served over HTTPS with a self-signed cert (see dockerhub-firefox.md).
- Firefox prefs file lives under `/usr/lib/firefox/browser/defaults/preferences/`.
