# TrueCharts chart: sinusbot

Source URL(s) + date:
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/sinusbot/Chart.yaml (fetched 2026-11-27)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/sinusbot/values.yaml (fetched 2026-11-27)

## What it is
- Chart v11.0.0, appVersion latest. Category Productivity.
- "SinusBot is a MusicBot that will let you listen to music together with your friends on either TeamSpeak 3 or Discord."
- Sources: forum.sinusbot.com, ghcr.io/gamer92000/sinusbot-docker.
- Deps: common 32.8.5 (oci://oci.trueforge.org/truecharts)

## Image (values.yaml)
- `ghcr.io/gamer92000/sinusbot-docker`, tag `latest@sha256:1ee6aa699e94aeb035149b3b1dca12d8d971944796dda4ec3b13bdb459ff385b`, pullPolicy IfNotPresent. Floating tag `latest`.

## Ports
| name | port | targetPort | protocol |
| --- | --- | --- | --- |
| main | 8087 | 8087 | tcp |

## Env (container main, set by chart)
| key | value |
| --- | --- |
| OVERRIDE_PASSWORD | secretKeyRef env-secrets/OVERRIDE_PASSWORD |

Secret `env-secrets` OVERRIDE_PASSWORD default: `foobar` (chart default, change for real use).

## Persistence
| name | mountPath |
| --- | --- |
| data | /opt/sinusbot/data |
| scriptspath | /opt/sinusbot/scripts |

## Security context (chart)
- runAsUser 0, runAsGroup 0, readOnlyRootFilesystem false.

## Upstream Dockerfile (sinusbot-docker @966f042)
Source URL: https://raw.githubusercontent.com/gamer92000/sinusbot-docker/966f042fce2ab6a93c7fa50e39aff335ebd81e9a/Dockerfile (fetched 2026-11-27)
- Base `debian:bookworm-slim`. LABEL version 1.1f.
- apt (no-install-recommends): ca-certificates bzip2 unzip curl python3 procps libxkbcommon0 locales x11vnc xvfb libxcursor1 libnss3 libegl1-mesa libasound2 libglib2.0-0 libxcomposite-dev less jq libevent-2.1-7 libxcb-xinerama0 liblcms2-2 libatomic1 libxcb-icccm4 libxcb-keysyms1 libxcb-randr0 libxcb-render-util0 libxcb-shape0 libxcb-xkb1 libxkbcommon-x11-0 libpci3 libxslt1.1 libxcb-image0
- Locale en_US.UTF-8 (LC_ALL, LANG, LANGUAGE)
- WORKDIR /opt/sinusbot; ADD install.sh; run in order: `install.sh sinusbot`, `yt-dlp`, `deno`, `text-to-speech`, `teamspeak`
- ADD entrypoint.sh (chmod 755)
- EXPOSE 8087
- VOLUME ["/opt/sinusbot/data", "/opt/sinusbot/scripts"]
- ENTRYPOINT ["/opt/sinusbot/entrypoint.sh"]
- HEALTHCHECK every 1m, timeout 10s: `curl -f http://localhost:8087/api/v1/botId`

## Install steps (upstream install.sh @966f042, fetched via raw URL)
- sinusbot: `curl https://michael.frie.se/sinusbot-1.1f-amd64.tar.bz2 | tar xj`; chmod sinusbot; scripts -> default_scripts; private.dat symlink to data/private.dat; config.ini.dist -> config.ini.configured with TS3Path = "".
- text-to-speech: patts.tar.gz from chromium.googlesource.com (speech_synthesis); extracts tts_service_x86_64.nexe, voice_lstm_en-US.zvoice, voice_lstm_de-DE.zvoice into tts/; appends [TTS] config (Enabled = false, en-US and de-DE modules).
- yt-dlp: `github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp` -> /usr/local/bin/yt-dlp; adds YoutubeDLPath to config.
- deno: `github.com/denoland/deno/releases/latest/download/deno-x86_64-unknown-linux-gnu.zip` unzipped to /usr/local/bin.
- teamspeak: URL from `https://www.teamspeak.com/versions/client.json` (.linux.x86_64.mirrors["teamspeak.com"]); runs installer `.run` silently; copies plugin/libsoundbot_plugin.so; removes libqxcb-glx-integration.so; sets TS3Path to /opt/sinusbot/TeamSpeak3-Client-linux_amd64/ts3client_linux_amd64.

## Entrypoint (upstream entrypoint.sh @966f042)
- Moves default_scripts into scripts; copies config.ini.configured to data/config.ini if absent; symlinks config.ini.
- Runs `yt-dlp -U` (self-update) at every start.
- UID/GID from env UID/GID (default 9987 if unset or 0); chown -R of $PWD to that UID/GID.
- Drops capabilities and privileges via `setpriv --clear-groups --inh-caps=-all-like list --reuid --regid`.
- If OVERRIDE_PASSWORD set: `./sinusbot --override-password=...`; else `./sinusbot`.
- Traps SIGTERM/SIGINT to forward SIGINT to process group.

## Runtime deps
- sinusbot 1.1f binary, yt-dlp, deno, TeamSpeak 3 client (ts3client), xvfb/x11vnc, python3.

## Volumes/paths
- /opt/sinusbot/data, /opt/sinusbot/scripts (chart maps to same).
- config: /opt/sinusbot/data/config.ini (symlinked from config.ini).

## User/UID
- Upstream: runtime drops to UID/GID env (default 9987) via setpriv; chart runs container as root with runAsUser 0.

## Version/asset naming
- SinusBot tarball fixed name `sinusbot-1.1f-amd64.tar.bz2` (upstream host michael.frie.se).
- yt-dlp, deno: `releases/latest` (unpinned).
- TeamSpeak client: latest from client.json (unpinned).

## Arch
- amd64 only (x86_64 TeamSpeak, sinusbot amd64, deno x86_64).

## Gotchas
- Install is unpinned for yt-dlp, deno and TeamSpeak (latest at build).
- Entrypoint runs `yt-dlp -U` at every container start.
- Chart OVERRIDE_PASSWORD default is `foobar`.
- Upstream api.github.com contents call for install.sh returned 403 (rate limit); raw URL at the same commit used instead.
