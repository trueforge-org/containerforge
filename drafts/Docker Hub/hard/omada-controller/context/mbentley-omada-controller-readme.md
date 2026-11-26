# mbentley/docker-omada-controller README

Source URL(s): https://github.com/mbentley/docker-omada-controller (raw README) · fetched 2026-11-26

## Run
- `docker run -d --name omada-controller --stop-timeout 60 --restart unless-stopped --ulimit nofile=4096:8192 --net host -e TZ=Etc/UTC -v omada-data:/opt/tplink/EAPController/data -v omada-logs:/opt/tplink/EAPController/logs mbentley/omada-controller:6.3`
- Bridge: same minus `--net host`, plus -p mappings; devices must be pointed at controller manually.
- Web UI: https://<host>:8043/.
- Suggested limits: `--cpus 2 --memory 4g --memory-swap 5g`.
- Ports <1024 need `--sysctl net.ipv4.ip_unprivileged_port_start=0` (container runs non-root).

## Ports
| Port | Proto | Purpose |
|---|---|---|
| 8088 | TCP | Manage HTTP (MANAGE_HTTP_PORT) |
| 8043 | TCP | Manage HTTPS (MANAGE_HTTPS_PORT) |
| 8843 | TCP | Portal HTTPS (PORTAL_HTTPS_PORT) |
| 8044 | TCP | Upgrade port 6.4+ (UPGRADE_HTTPS_PORT) |
| 27001 | UDP | App discovery |
| 19810 | UDP | Bridge example mapping (no var) |
| 29810 | UDP | Device discovery |
| 29811 | TCP | Manager v1 |
| 29812 | TCP | Adopt v1 |
| 29813 | TCP | Upgrade v1 |
| 29814 | TCP | Manager v2 |
| 29815 | TCP | Transfer v2 (5.9+) |
| 29816 | TCP | RTTY (5.9+) |
| 29817 | TCP | Device monitor (6.0+) |

## Volumes
| Path | Stores |
|---|---|
| /opt/tplink/EAPController/data | DB, settings (bind mount suggested) |
| /opt/tplink/EAPController/logs | logs |
| /cert (optional) | tls.crt (full chain), tls.key -> Java keystore |

## Environment variables
| Variable | Default | Meaning |
|---|---|---|
| _JAVA_OPTIONS | null | Override JVM args |
| APPLICATION_PROPERTIES | null | Spring properties -> application.properties |
| EAP_MONGOD_URI | null | External MongoDB URI |
| JAVA_MAX_HEAP_SIZE | null | Replaces -Xmx (default 1024m) |
| JAVA_MIN_HEAP_SIZE | null | Replaces -Xms (default 128m) |
| MANAGE_HTTP_PORT | 8088 | |
| MANAGE_HTTPS_PORT | 8043 | |
| MONGO_EXTERNAL | false | Skip embedded MongoDB |
| MONGOD_EXTRA_ARGS | null | Extra mongod args (not in rootless) |
| PUID / PGID | 508 / 508 | Process uid/gid |
| PUSERNAME / PGROUP | omada / omada | Names |
| PORTAL_HTTP_PORT | 8088 | |
| PORTAL_HTTPS_PORT | 8843 | |
| PORT_APP_DISCOVERY | 27001 | |
| PORT_DISCOVERY | 29810 | |
| PORT_MANAGER_V1 | 29811 | |
| PORT_ADOPT_V1 | 29812 | |
| PORT_UPGRADE_V1 | 29813 | |
| PORT_MANAGER_V2 | 29814 | |
| PORT_TRANSFER_V2 | 29815 | |
| PORT_RTTY | 29816 | |
| PORT_DEVICE_MONITOR | 29817 | |
| ROOTLESS | false | Rootless entrypoint |
| SHOW_SERVER_LOGS | true | Controller logs to STDOUT |
| SHOW_MONGODB_LOGS | false | |
| SKIP_6_4_UPGRADE_PRECHECK | false | Risky |
| SKIP_USERLAND_KERNEL_CHECK | false | armv7l/arm64 |
| SSL_CERT_NAME | tls.crt | in /cert |
| SSL_KEY_NAME | tls.key | in /cert |
| TLS_1_11_ENABLED | false | Re-enable TLS 1.0/1.1 |
| TZ | Etc/UTC | |
| UPGRADE_ES_HTTPS_PORT | 8044 | ES-series only |
| UPGRADE_HTTPS_PORT | 8043 (<6.4) / 8044 (>=6.4) | |
| WEB_CONFIG_OVERRIDE | false | Re-read ports from omada.properties each start |
| WORKAROUND_509 | n/a | 5.15.6.x only |

## User / UID
- Default non-root `omada`, UID/GID 508; PUID/PGID adjust.
- ROOTLESS=true: set container's real numeric UID/GID (PUID/PGID do not apply); pre-own data and logs; extra mounts must be readable.

## Versions / tags
- Tags: `6`, `6.3` (recommended), `6.3.0.112`. Currently supported: 6.3 (6.3.0.112), 6.2 (6.2.14.11). Beta: beta-6.4.0.33.
- `latest` points to deprecated 5.x; avoid. 6.0, 6.1, 5.x archived/unpatched. OpenJ9 `-openj9` suffix (amd64/arm64).
- Build args: INSTALL_VER, ARCH.

## Upgrade / migration
- Backup in controller first; stop with `--stop-timeout 60`; downgrades impossible.
- 6.3 -> 6.4: must come from 6.3; precheck `upgrade_precheck.json` in data/db must show 0; upgrade port moves to 8044; external MongoDB >= 4.0; health check `/api/info` (/login returns 404).
- CPU without AVX (amd64) / armv8.2-a (arm64): external MongoDB.

## Gotchas
- Bridge mode: inside and outside ports must match.
- MANAGE_*_PORT applied only on first start unless WEB_CONFIG_OVERRIDE=true; PORTAL_*_PORT always applied.
- Unclean stop can corrupt MongoDB; use longer stop timeout.
- Don't mix /cert with UI-installed certs.
- Low memory: JAVA_MAX_HEAP_SIZE, JAVA_MIN_HEAP_SIZE, MONGOD_EXTRA_ARGS=--wiredTigerCacheSizeGB.
