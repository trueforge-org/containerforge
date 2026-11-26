# modem7/docker-rickroll (GitHub)

Source URL(s) + fetch date (2026-11-26):
- https://github.com/modem7/docker-rickroll (repo; README via https://raw.githubusercontent.com/modem7/docker-rickroll/master/README.md)
- https://raw.githubusercontent.com/modem7/docker-rickroll/40cce76bf9f796d5171584624793f62db4bc9e84/Dockerfile (draft cites blob/40cce76.../Dockerfile)
- https://github.com/modem7/docker-rickroll/releases/tag/video-assets-v1 (release page)
- Not fetched, skipped: https://raw.githubusercontent.com/modem7/docker-rickroll/${VERSION}/LICENCE.txt (contains ${); https://github.com/modem7/docker-rickroll/releases/download/video-assets-v1/video.mp4, ${VIDEO_NAME}, <name (direct video downloads).

## What it is
"Self Hosted, self contained Rickroll container." Serves a video that autoplays muted behind a randomly chosen decoy screen (loading spinner or fake error) with a cookie banner. First click or keypress unmutes it. Built on nginxinc/nginx-unprivileged, runs as non-root. The video is baked into the image at build time.

## Install/build steps and build deps (Dockerfile at 40cce76)
```
FROM --platform=$BUILDPLATFORM alpine:3.24 AS video
RUN apk add --no-cache curl
ARG VIDEO_URL=https://github.com/modem7/docker-rickroll/releases/download/video-assets-v1/video-1080p.mp4
WORKDIR /video
RUN curl -fsSL "$VIDEO_URL" -o video.mp4

FROM nginxinc/nginx-unprivileged:1.31.7-alpine
USER 0
ARG UID=101
ARG GID=101
COPY --link --from=video /video/video.mp4 /usr/share/nginx/html/video.mp4
COPY --link --chmod=755 scripts/*.sh /docker-entrypoint.d/
COPY --link --chmod=755 scripts/index/80-index.sh /docker-entrypoint.d/
RUN chown $UID:0 /usr/share/nginx/html/index.html
EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=10s --retries=3 --start-period=10s \
    CMD ["sh", "-c", "curl -fss http://localhost:9090/healthz || exit 1"]
STOPSIGNAL SIGQUIT
USER $UID
CMD ["nginx", "-g", "daemon off;"]
```
- Build-time only: curl (apk) in the video stage.
- No VOLUME, no ENTRYPOINT (nginx-unprivileged docker-entrypoint.d scripts run).
- The Dockerfile's default VIDEO_URL is `video-1080p.mp4` (see the conflict note in README.md).

## Build args
- `VIDEO_URL`: release asset URL (default `.../video-assets-v1/video-1080p.mp4`). Example: `video-720p.mp4`.

## Runtime deps
- nginx (unprivileged image), nginx mp4 module serves the video (seek / byte-range).

## Env vars (README; defaults; from plan.md scripts 80-index.sh and 70-nginx.sh)
| Name | Default | Purpose |
| --- | --- | --- |
| PORT | 8080 | nginx listen port |
| OVERLAY | both | `error`, `loading`, or comma-separated list; random pick per visit |
| TITLE | Rickroll | tab title after reveal |
| PRE_TITLE | Loading... | tab title before reveal |
| HEADLINE | empty | heading over the video |
| HEIGHT | 100vh | video element height |
| WIDTH | 100% | video element width |
| OBJECT_FIT | cover | CSS object-fit; portrait viewports switch to contain |
| LOOP | true | video loops |
| VIDEO_FILE | video.mp4 | filename relative to web root, or full https URL |

(README lists no VIDEO_NAME. The draft's VIDEO_NAME reference is not an upstream variable.)

## Ports
- 8080 http (default, changeable with PORT). 9090 is the upstream health server (`/healthz`) used by the HEALTHCHECK.

## Volumes
- None documented or needed (video baked in).

## User/UID and permissions
- Final image: `USER 0` for setup, then `USER $UID` with ARG UID=101 GID=101 (nginx-unprivileged default). `chown $UID:0 /usr/share/nginx/html/index.html` so the entrypoint can rewrite index.html at start.

## Healthcheck/readiness
- `curl -fss http://localhost:9090/healthz` every 30s, 10s timeout, 3 retries, 10s start period.

## Version/release info and asset naming
- No product version. Upstream tags on Docker Hub: `480p` (854x480), `720p` (1280x720), `latest` and `1080p` (1920x1080), `2160p` (3840x2160). All same image except the baked-in video.
- Release `video-assets-v1` (published 07 Jul, year not shown; Latest). Description: source video assets fetched at build time. Named files on the page: `video4k.mkv` (4K master, all resolutions derived from it via the Dockerfile's RESOLUTION build arg) and `video.mp4` (older interim 1080p). Release page reports 8 assets; full list did not render. Per plan.md, the release also carries `video-480p.mp4`, `video-720p.mp4`, `video-1080p.mp4`, `video-2160p.mp4`.
- Asset URL pattern: `https://github.com/modem7/docker-rickroll/releases/download/video-assets-v1/<name>`.
- Release points to commit f466bee; master is 88 commits ahead (per release page).
- Transcoding workflow: `.github/workflows/video-assets.yml` (manual trigger).

## Arch support
- Image published for linux/amd64 and linux/arm64/v8 (Docker Hub page). Video asset is arch independent.

## Gotchas
- The video is not an open license per upstream README (repo MIT, content license not stated; plan.md section 10).
- Values are inserted unescaped into HTML/JS (plan.md, 80-index.sh; not re-verified).
