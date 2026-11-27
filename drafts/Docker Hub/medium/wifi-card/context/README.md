# Context index: wifi-card

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/wifi-card/values.yaml + Chart.yaml | truecharts-wifi-card.md |
| https://hub.docker.com/v2/repositories/bndw/wifi-card/ + tags?page_size=10 | dockerhub-wifi-card.md |
| https://raw.githubusercontent.com/bndw/wifi-card/7a990dd2411f6c8758ad696bf737b509f9672953/Dockerfile (also blob URL) | wifi-card-dockerfile.md |

Skipped (one line): https://github.com/bndw/wifi-card (repo HTML root; the source archive is in plan.md, not fetched). No CLA, forgetool, containerforge, templated, binary-download or image-ref URLs in this list beyond the Dockerfile's FROM lines.
Failures: none.

## plan.md corrections
- No in-place edits.
- Checked and matching fetched sources: Dockerfile stages (`node:24-alpine` build, `nginx:stable-alpine` final, `/usr/share/nginx/html`), `yarn build`, no EXPOSE/USER/VOLUME/ENV/ENTRYPOINT, port 80 for the upstream nginx default, Docker Hub tag `7a990dd` exists (amd64).
- Unverified: plan.md's "`master` HEAD equals 7a990dd" and "no tags/releases" were not re-checked (not in urls.txt). Docker Hub `7a990dd` (2026-11-06, same size as `latest`) is the newest image build, so the pin matches the published image.
- Unverified: package.json `packageManager: yarn@4.18.0` and the `vite build` script (package.json not fetched).
