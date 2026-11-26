# Docker Hub: domoticz/domoticz

Source URL(s) + fetch date:
- https://hub.docker.com/r/domoticz/domoticz · 2026-11-26

## Facts
- Architectures: Arm 32-bit, Arm 64-bit, Linux 64-bit.
- Tags shown: `latest`; usage text mentions `stable`, `beta`, `2024.2`, `2024-beta.12345`.
- Env: `WWW_PORT=8080`, `SSL_PORT=443`, `TZ=Europe/Amsterdam` (only needed when /etc/localtime cannot be mounted), `EXTRA_CMD_ARG` (extra args, e.g. SSL cert), `LOG_PATH` (commented example `/opt/domoticz/userdata/domoticz.log`).
- Ports: examples map 8080:8080, and 8443:443.
- Volumes: `./config:/opt/domoticz/userdata` (config; plugins folder created on first launch). Optional `./config/www/templates:/opt/domoticz/www/templates` (enable only after first start). `customstart.sh` in userdata runs on every container start (per page; the upstream entrypoint runs it only on first start, see the entrypoint summary).
- Devices: serial passthrough via `devices:` / `--device`.
- User: not stated. Logging off by default.
- Image size 119.3 MB; last updated 2 days before fetch.
