# skrashevich/double-take build (.build/Dockerfile and entrypoint.sh @ 60c957d)

## Source URL(s) + date
- https://raw.githubusercontent.com/skrashevich/double-take/60c957d/.build/Dockerfile
- https://raw.githubusercontent.com/skrashevich/double-take/60c957d/.build/entrypoint.sh
- Fetched 2026-11-27. Blob URL variant of the Dockerfile (same commit) not fetched, same content.
- Repo root https://github.com/skrashevich/double-take: page shows "MIT license" (identical to upstream page; fork LICENSE not separately confirmed).

## Stages (Dockerfile, in order)
| Stage | Base | Purpose |
| --- | --- | --- |
| recognizer-models | `alpine:latest` | wget dlib models (shape_predictor_5/68 landmarks, dlib resnet, mmod detector), bunzip2 |
| recognizer-builder | `golang:1.20-buster` | go build `recognizer` with CGO, libdlib-dev, libblas, libatlas, liblapack, libjpeg62-turbo-dev, gfortran; amd64 adds libquadmath0 |
| better-sqlite3-builder | `node:16` | fetch sqlite amalgamation 3420000, `npm install better-sqlite3@^8.4.0 --build-from-source` |
| canvas-builder | `node:16` | cairo/pango/jpeg/gif/rsvg build of node-canvas v2.11.2 (its output is copied only as commented lines) |
| frontend-builder | `oven/bun` | `bun install`, `bun run -b build` of `/frontend` |
| build | `node:16` | `npm install` in `/double-take/api`, copies better-sqlite3, server.js, src, frontend dist |
| debug | `node:16` | extra tools, ENTRYPOINT entrypoint.sh (not the default target) |
| final | `node:16-slim` | jq; copies `/double-take`, `/opt/lib/*`; `NODE_ENV=production`, `WORKDIR /double-take`, `EXPOSE 3000`, `ENTRYPOINT ["/bin/bash", "./entrypoint.sh"]` |

- Final stage has no USER line (runs as root). `RUN mkdir /.storage && ln -s /.storage /double-take/.storage`.
- `RUN cp /lib/*-linux-gnu*/libuuid.so.1.3.0 /opt/lib/libuuid.so.1`.

## Entrypoint (entrypoint.sh)
1. HA add-on branch: if `HA_ADDON=true` and `/data/options.json` exists, exports values via jq.
2. Watch paths: `--watch "$CONFIG_PATH"` if set, else `--watch ./.storage/config`; `SECRETS_PATH` optional.
3. CUDA check: `ldconfig -p | grep cuffda`.
4. If `/usr/local/bin/recognizer` exists: with CUDA (and not HA add-on) runs `recognizer -cnn -port 8888 -models /opt/recognizer/models -storage /.storage -d`, else `recognizer -port 8888 -models /opt/recognizer/models -storage /.storage -d`. No `&` in the script; whether `-d` daemonizes is not verified here.
5. `node -e 'require("./api/src/constants")()'`.
6. `exec nodemon -e yml,yaml $PATHS -q api/server.js`.

## Env vars (read by upstream scripts)
| Name | Use |
| --- | --- |
| CONFIG_PATH | watch path for config (default `./.storage/config`) |
| SECRETS_PATH | optional watch path |
| HA_ADDON | `true` enables add-on option import |
| NODE_ENV | `production` (Dockerfile) |

## Ports
- 3000 (EXPOSE, final stage). Recognizer on 8888 (internal).

## Volumes/paths
- `/.storage` (data, models, config) hard-coded in recognizer `-storage` flag and watch path. `/double-take` app root.
- `/opt/recognizer/models` (models copied from recognizer-models stage).

## User/UID
- Runs as root (no USER).

## Gotchas
- Recognizer needs dlib, cairo/pango; node:16 for native modules (better-sqlite3 8.x, canvas).
- Recognizer and API start from one script; upstream does not supervise the recognizer.
- Stage `debug` is not the default final target.
