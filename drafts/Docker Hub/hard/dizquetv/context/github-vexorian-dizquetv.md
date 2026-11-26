# vexorian/dizquetv (source, wiki, release, Dockerfiles)

Source URL(s) + fetch date:
- https://github.com/vexorian/dizquetv (README via raw.githubusercontent.com/vexorian/dizquetv/master/README.md)
- https://raw.githubusercontent.com/vexorian/dizquetv/master/Dockerfile
- https://raw.githubusercontent.com/vexorian/dizquetv/ce37783/Dockerfile-nvidia
- https://raw.githubusercontent.com/vexorian/dizquetv/master/index.js
- https://github.com/vexorian/dizquetv/releases/tag/1.7.0
- https://github.com/vexorian/dizquetv/wiki (index page) and wiki pages Step-1, Step-3
- Fetched 2026-11-26

## What it is
- Tool that builds live TV channel streams from media on Plex servers, a fork of pseudotv-plex/pseudotv.
- Channels reachable by adding a spoofed HDHomerun tuner to Plex, Jellyfin or Emby, or via an M3U/IPTV URL.
- Web UI with a TV guide. Plex Pass needed for the spoofed HDHR in Plex.
- License: README states zlib for dizqueTV changes and MIT for the original pseudotv-Plex code (FontAwesome and Bootstrap also credited).

## Install/build steps and build deps
- Upstream master Dockerfile (2-stage):
  - Stage 1: `FROM node:12.18-alpine3.12`, WORKDIR `/home/node/app`, `COPY package.json ./`, `RUN npm install && npm install -g browserify nexe@3.3.7`, `COPY --from=vexorian/dizquetv:nexecache /var/nexe/linux-x64-12.16.2 /var/nexe/`, `COPY . .`, `RUN npm run build && LINUXBUILD=dizquetv sh make_dist.sh linuxonly`.
  - Stage 2: `FROM jrottenberg/ffmpeg:4.3-ubuntu1804`, `EXPOSE 8000`, WORKDIR `/home/node/app`, `COPY --from=0 /home/node/app/dist/dizquetv /home/node/app/`, `RUN ln -s /usr/local/bin/ffmpeg /usr/bin/ffmpeg`, `ENTRYPOINT ["./dizquetv"]`.
  - No ENV, ARG, USER, VOLUME or CMD in the master Dockerfile.
- nvidia Dockerfile (at commit ce37783): stage 1 `FROM node:14-alpine3.14` (same WORKDIR, browserify and nexe@3.3.7 global install, same make_dist step); stage 2 `FROM jrottenberg/ffmpeg:4.3-nvidia1804`, `EXPOSE 8000`, same WORKDIR, ENTRYPOINT `./dizquetv`, `ln -s /usr/local/bin/ffmpeg /usr/bin/ffmpeg`. No ENV/ARG/USER/VOLUME/CMD.
- Source build per wiki (needs Node.js 12 or greater): `git clone`, `npm install`, `npm run build`, `npm run start`.
- package.json scripts per README: `npm run build` (browserify), `npm run compile` and `npm run package` (babel + pkg, not needed for a source container), dev scripts use nodemon/watchify.
- Upstream builds a nexe binary (x64 only, Node 12 bundled). The Dockerfiles do not build from source with plain node in the runtime.

## Runtime deps
- ffmpeg: wiki says "FFMPEG 4.2.3 or later is required"; advises against nightly builds; development testing used 4.2.4. Docker images ship ffmpeg 4.3 (jrottenberg base).
- Node: wiki says NodeJS 12 or greater for the source route.
- Media source: one or more Plex servers.

## Binaries/entrypoint/CLI flags
- Entrypoint (Docker): `./dizquetv`. Source route: `node index.js` / `npm run start`.
- CLI flags (index.js argv loop):
  - `-p` / `--port <n>` sets `process.env.PORT`.
  - `-d` / `--database <dir>` sets `process.env.DATABASE`.
  - `--unlock` sets unlockPath (passed to FfmpegSettingsService).
- Windows example from wiki: `dizquetv-win-x64.exe --port 8000 --database .dizquetv`.

## Env vars
| Name | Default (index.js) | Notes |
| --- | --- | --- |
| PORT | 8000 | `process.env.PORT = process.env.PORT || 8000`; used in `app.listen(process.env.PORT)`. |
| DATABASE | `./.dizquetv` (`path.join(".", ".dizquetv")`) | Data directory; created if missing. Set by `--database` flag or env. |

- Release notes say the ffmpeg path can be set via an environment variable or `ffmpeg-path.json`, but the env var name is not given in any fetched page. Docker images come with the path preconfigured.
- No other process.env uses in index.js (all others are DATABASE).

## Ports
- 8000/tcp (web UI and API). `app.listen(PORT)` with no host, so Node binds all interfaces (`HTTP server running on port: http://*:<PORT>`).
- TrueCharts service maps `main` port 10071 -> targetPort 8000 (see truecharts-dizquetv.md).

## Volumes/paths and persistent data
- Data folder `.dizquetv`, created next to the executable by default; in Docker the wiki and TrueCharts use `/home/node/app/.dizquetv`.
- Created subfolders by index.js: `images/`, `channels/`, `filler/`, `custom-shows/`, `cache/`, `cache/images/`, `play-cache`, plus `custom.css` and generated PNG/TTF assets written at startup (initDB).
- EPG guide data at `.dizquetv/xmltv.xml`.
- Wiki: always mount a volume for the data folder so it survives upgrades.

## User/UID & permissions
- No USER instruction in either Dockerfile (runs as the base image's default user). Wiki states nothing about UID.

## Config files and formats
- Channels, programs, commercials and settings are configured in the web UI, stored in the data folder.
- `ffmpeg-path.json` (per release notes) holds the ffmpeg path.
- `custom.css` in the data folder (static route).

## Healthcheck/readiness endpoints
- None documented upstream. TrueCharts uses HTTP probes on `/` (liveness, readiness, startup).

## Version/release info and asset naming
- Release 1.7.0 marked Latest, released 15 Dec (year not shown on page), commit d99eda2 (signed). Described as an "edge" release; README and wiki point to 1.5.5 as stable.
- Release page says "Assets 6" but the asset list did not render. Asset names referenced elsewhere: `dizquetv-linux-x64`, `dizquetv-macos-x64`, `dizquetv-win-x64.exe`, `dizquetv-win-x86.exe` (wiki). No arm64 binary is mentioned.
- Linux binary: `dizquetv-linux-x64` from the release page, chmod +x. 32-bit systems must build from source.
- Docker Hub tags: `latest` (stable), `edge`, `development`, `X.Y.Z`; `-nvidia` suffix for NVENC builds (e.g. `latest-nvidia`).
- Release notes known issue: VirusTotal flags the Windows exe (nexe false positive).
- Docker Hub page labels "1.5.0-development" in its description (stale); README heading says "dizqueTV 1.5.5" (stale).

## Arch support
- Upstream prebuilt binaries: linux x64, macOS x64, Windows x64/x86. No arm64 binary or image arch listed on Docker Hub. nvidia image is amd64 only per Dockerfile base (jrottenberg nvidia1804).

## Gotchas
- Migrating from pseudoTV 0.0.51 requires renaming `.pseudotv` to `.dizquetv` (for Docker, equivalent volume handling).
- Plex media/server changes are not detected; programs must be removed and re-added manually. Server IP/port changes must be updated manually.
- Players may break when formats differ between episodes; transcoding helps at resource cost.
- Upstream says the project is for private use; exposing its ports to others is discouraged.
- Plex DVR always records and transcodes the channel.
- Release 1.7.0 removed the need for the UI Route setting (server now sits between UI and Plex).
- Filler lists sync with Plex collections/playlists, refresh on save and every 30 minutes.
- Wiki index lists Step 1 to Step 4 setup pages; no Docker-specific wiki page visible. Default port 8000 per Step 1 wiki page.
