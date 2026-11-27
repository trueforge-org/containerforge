# itzg/docker-minecraft-bedrock-server (Dockerfile, bedrock-entry.sh, demoter-entry.sh, README, LICENSE; master)

Source URL(s) + date:
- https://raw.githubusercontent.com/itzg/docker-minecraft-bedrock-server/master/Dockerfile (2026-11-27)
- .../master/bedrock-entry.sh (2026-11-27; 20 KB, key lines grepped)
- .../master/demoter-entry.sh (2026-11-27)
- .../master/README.md (2026-11-27; env table not parsed by grep, not summarised in full)
- .../master/LICENSE (2026-11-27; MIT-style, read only as presence check)

## Build steps / deps
- Base: `FROM debian`; BuildKit `--mount` of `/build/install-packages`; `/build/setup-arm64` (box64 package via ARG BOX64_PACKAGE=box64).
- Binaries via easy-add (`ADD --chmod=755` from GitHub releases):
  - easy-add 0.8.20 (`itzg/easy-add`)
  - entrypoint-demoter 0.5.4 (`itzg/entrypoint-demoter`, tar.gz `..._linux_${TARGETARCH}.tar.gz`)
  - set-property 0.2.0
  - mc-monitor 1.21.1
  - mc-server-runner 1.18.0
- bds-ipv6fix: `https://github.com/poeggi/bds-ipv6fix/releases/latest/download/bds-ipv6fix_linux_{x86_64|aarch64}.so` to /opt/bds-ipv6fix.so (amd64/arm64 only).
- COPY *.sh -> /opt/; property-definitions.json -> /etc/bds-property-definitions.json; bin/* -> /usr/local/bin/.

## Runtime
- ENTRYPOINT `["/opt/demoter-entry.sh"]` (execs entrypoint-demoter as PID 1, runs `/opt/bedrock-entry.sh`).
- demoter-entry.sh: args `--match /data --debug --stdin-on-term stop /opt/bedrock-entry.sh`; optional announce-then-stop via STOP_SERVER_ANNOUNCE_DELAY (seconds) and STOP_SERVER_ANNOUNCE (default text "say Server s...").
- bedrock-entry.sh: downloads bedrock-server zip, extracts, renames binary to `bedrock_server-<VERSION>`, runs `exec mc-server-runner ... ./bedrock_server-<VERSION>`; if /usr/local/bin/box64 and USE_BOX64 true, runs via box64.
- Writes server.properties via `set-property --bulk /etc/bds-property-definitions.json`.
- Creates worlds under `worlds/$LEVEL_NAME`; addon packs installed from pack manifests.
- Requires EULA=TRUE (exits otherwise).

## Env vars (from scripts and Dockerfile)
| var | default | note |
| --- | --- | --- |
| VERSION | LATEST | Dockerfile ENV; also `none` path in entry |
| SERVER_PORT | 19132 | |
| SERVER_PORT_V6 | 19133 | |
| ENABLE_BDS_V6BIND_FIX | false | |
| DOWNLOAD_DIR | ${PWD}/.downloads | |
| DOWNLOAD_LINKS_URL | https://net.web.minecraft-services.net/api/v1.0/download/links | primary |
| DOWNLOAD_SECONDARY_LINKS_URL | same | fallback |
| PROCESSED_DOWNLOAD_LINKS_URL | https://raw.githubusercontent.com/kittizz/bedrock-server-downloads/refs/heads/main/bedrock-server-downloads.json | fallback |
| DIRECT_DOWNLOAD_URL | unset | overrides lookup; version parsed from `bedrock-server-X.zip` |
| LEVEL_NAME | Bedrock level | |
| DOWNLOAD_PROGRESS | false | |
| USE_BOX64 | | arm64 only, needs /usr/local/bin/box64 |
| STOP_SERVER_ANNOUNCE_DELAY | unset (0 = immediate stop) | demoter |
| EULA | (required TRUE) | |
| RESOLVE_XUID_API_URL | https://mcprofile.io/api/v1/bedrock/gamertag | used for OPS/MEMBERS/VISITORS names |
| ALLOW_LIST_USERS / WHITE_LIST_USERS | | allowlist, "NAME:XUID" pairs |

## Ports
- EXPOSE 19132/tcp, 19132/udp, 19133/udp

## Volumes/paths
- VOLUME /data; WORKDIR /data
- server binary `bedrock_server-<VERSION>` in /data; `.downloads` temp dir removed after extract.

## User/UID
- Not set in Dockerfile; runs as image default user (root) per fetched files. Not verified further.

## Healthcheck
- `--start-period=1m CMD /usr/local/bin/mc-monitor status-bedrock --host 127.0.0.1 --port $SERVER_PORT`

## Version/asset naming
- Zip: `bedrock-server-<version>.zip` under `https://www.minecraft.net/bedrockdedicatedserver/bin-linux/` (stable) or `bin-linux-preview/` (preview).
- Version extracted from URL with regex `bedrock-server-([0-9.]+)\.zip`.
- Processed mirror JSON (kittizz): top-level keys `release` and `preview`; each maps version -> {windows: {url}, linux: {url}}.

## Arch
- amd64 (x86_64) native; arm64 via box64 (setup-arm64). bds-ipv6fix arm64/amd64 only.

## Gotchas
- Download lookup order: minecraft-services API, then kittizz mirror JSON, then minecraft.net page (page failed to fetch here).
- Removes vanilla/chemistry/experimental behavior packs from behavior_packs at start (line ~401).
- Upstream Dockerfile default `FROM debian`; ContainerForge base differs.
