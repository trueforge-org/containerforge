# Upstream: rossimo/retrobot (Dockerfile, package.json at d04ddd8; README on master)

Source URL(s):
- https://raw.githubusercontent.com/rossimo/retrobot/d04ddd8/Dockerfile (fetched 2026-11-27)
- https://raw.githubusercontent.com/rossimo/retrobot/d04ddd8/package.json (fetched 2026-11-27)
- https://raw.githubusercontent.com/rossimo/retrobot/master/README.md (fetched 2026-11-27; master, not d04ddd8)

## Dockerfile (d04ddd8)
- `FROM alpine:3.16.2`; `WORKDIR /retrobot`.
- `apk add --no-cache nodejs npm git python3 xz-dev make g++`.
- `npm install --global yarn cross-env forever`.
- `COPY . .`; `RUN yarn install && yarn cache clean`.
- `CMD ["yarn", "start"]`. No ENTRYPOINT, USER, EXPOSE, VOLUME, ENV.

## package.json (d04ddd8)
- name `libretro-webassembly-simple`, version 1.0.0, license MIT, main index.js.
- scripts: `start` = `ts-node src/index.ts`; `service:start`/`service:stop` via forever.
- Deps include discord.js ^14.9.0, fluent-ffmpeg (git fork rossimo/node-fluent-ffmpeg), @ffmpeg-installer/ffmpeg, @ffprobe-installer/ffprobe, piscina, bottleneck, shelljs, decompress (+bzip2/tarbz2/targz), hash-wasm, lru-cache, tmp, dotenv, typescript ^4.7.4, ts-node ^10.9.1.
- optionalDependencies: bufferutil, erlpack, utf-8-validate, zlib-sync.

## Runtime config (README, master)
| Var | Purpose / default |
| --- | --- |
| DISCORD_TOKEN | bot token, read from `.env` (required) |
| MAX_WORKERS | worker threads; default = CPU cores |
| MAX_WORKERS_PER_GAME | input-assist workers per game; default 3 |
| RECORDING_FRAMERATE | GIF FPS, default 30, range 1-60 |

- Run: `yarn install` then `yarn start`. Helper daemon: `yarn service:start` logs to `./forever/retrobot.log`.
- Docker example in README: `docker run -d -v ./data:/retrobot/data --env-file .env rossimo/retrobot` (official image on Docker Hub, not fetched).
- Bot invite needs Discord permissions 68608 and scope bot. "Message Content Intent" must be enabled.

## Ports
- None. Bot uses Discord gateway (outbound only). No listener documented.

## Volumes/paths
- `/retrobot/data` used in README docker example.

## License
- MIT for bot source (package.json and README). Core licences: mGBA, QuickNES, snes9x2010 (links in README).

## Gotchas
- Built on libretro cores compiled to WASM; no native emulator binary.
- Dockerfile base is Alpine 3.16.2 (old).
