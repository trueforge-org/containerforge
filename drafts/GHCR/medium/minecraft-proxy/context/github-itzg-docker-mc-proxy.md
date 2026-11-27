# itzg/docker-mc-proxy Dockerfile (commit 89a7d3ad7dc6) and README (main)

Source URL(s) + date:
- https://raw.githubusercontent.com/itzg/docker-mc-proxy/89a7d3ad7dc6/Dockerfile (2026-11-27)
- https://raw.githubusercontent.com/itzg/docker-mc-proxy/main/README.md (2026-11-27; key sections)

## What it is
Container for BungeeCord, Waterfall, Velocity or custom proxy jars; `TYPE` selects the proxy.

## Build steps / deps
- `ARG BASE_IMAGE=eclipse-temurin:25-jre`; `FROM ${BASE_IMAGE}`
- VOLUME ["/server"]; WORKDIR /server
- `/build/install-packages.sh`; `COPY --from=tianon/gosu /gosu /usr/local/bin/`; `/build/setup-user.sh`
- easy-add 0.8.19; mc-monitor 1.18.3; rcon-cli 1.7.9; mc-image-helper 1.76.0 (tgz to /usr/share, symlink /usr/bin/mc-image-helper)
- COPY templates/ -> /templates/; COPY /scripts/* -> /usr/bin/ (scripts not fetched)

## Runtime
- CMD `["/usr/bin/run-bungeecord.sh"]` (script not fetched)
- HEALTHCHECK `--start-period=10s CMD /usr/bin/health.sh`

## Env vars (Dockerfile ENV)
| var | default |
| --- | --- |
| RCON_PORT | 25575 |
| MEMORY | 512m |

## Ports
- EXPOSE 25577 (Bungee/Waterfall default) and 25565 (Velocity default)

## Volumes/paths
- /server (VOLUME, WORKDIR), /config (synced into /server), /plugins (copied before start)

## README key facts
| var | default / note |
| --- | --- |
| TYPE | BUNGEECORD (also VELOCITY, WATERFALL, CUSTOM) |
| CUSTOM_FAMILY | bungeecord, velocity, waterfall (for CUSTOM) |
| BUNGEE_JAR_URL | required for CUSTOM |
| VELOCITY_VERSION | latest |
| VELOCITY_BUILD_ID | latest |
| MEMORY | 512m; INIT_MEMORY and MAX_MEMORY default to MEMORY |
| ONLINE_MODE | must be FALSE for BungeeCord |
| ENABLE_RCON | Velocity uses code-lime/Velocircon; Bungee uses orblazer/bungee-rcon |
| PLUGINS, PLUGINS_FILE, SPIGET_PLUGINS | plugin download |
| PUID / PGID | chown of $BUNGEE_HOME (/server) to PUID:PGID unless disabled |
| HEALTH_HOST | localhost |
| BUNGEE_JOB_ID | lastStableBuild |
| ENABLE_JMX | optional |

## Gotchas
- Bungee port 25577 must be mapped to 25565 by the user.
- Velocity default bind 25565; README example sets `bind` to localhost:25577 in velocity.toml.
- Start scripts (run-bungeecord.sh, health.sh, setup-user.sh) are not fetched; entrypoint behaviour beyond the README not verified.
