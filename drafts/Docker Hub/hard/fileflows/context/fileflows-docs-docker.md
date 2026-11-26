# FileFlows docs: Docker installation

Source URL(s) + fetch date:
- https://fileflows.com/docs/installation/docker (fetched 2026-11-26; DNS failed twice before a third attempt worked)

## Compose example (generator default)

```
services:
  fileflows:
    image: revenz/fileflows
    restart: unless-stopped
    ports:
      - "19200:5000"
```

No volumes or env entries in the default output; the generator adds them.

## Ports

- Container listens on 5000; default host port 19200 (`19200:5000`).

## Directories (documented)

- Temp Path: flow runner temp files; fast drive (NVMe) recommended.
- Data Directory: configuration and essential server/agent data. Back up.
- Logs Directory: all logs including per-file logs.
- Browser Start Directory: file browser start, default `/media`.
- Common Directory: shared storage for DockerMods installs; expose as a volume to keep them across recreation.
- Additional Volumes: host media folders mapped into the container.

Exact container paths for Data/Logs/Temp are not on the page (the TrueCharts chart uses `/app/Data`, `/app/Logs`, `/temp`, `/media`).

## Environment variables and users

- `TZ`: IANA timezone names.
- `PUID` (optional numeric uid, example `99`; blank = default user).
- `PGID` (optional gid, number or group name; blank = default group).
- OIDC (requires a valid license): generator labels `OidcAuthority`, `OidcClientId`, `OidcClientSecret`, `OidcCallbackAddress`, `OidcRequiredGroup`. Env var names not given on the page.
- Docker siblings: enabling it configures the Docker socket and `TempPathHost` (not supported by ContainerForge per plan).
- Agent-only: Agent Name, Server URL (example `http://192.168.1.5:19200`), Access Token (Config > Agents in the web console).

## Image tags (documented)

- `Default`: no pre-installed DockerMods; recommended.
- `Modded`: includes FFmpeg and ImageMagick. Use only if the container cannot reach the internet for DockerMods; do not combine with DockerMods.
- `Latest`: updated often, possibly unstable.
- `Stable`: most reliable, usually updated at the end of each month.

## DockerMods

- Usual way to install tools. "Latest image plus DockerMods" is the suggested setup. Installs go to the Common Directory.

## Hardware acceleration (documented)

- NVIDIA: sets required env vars and the NVIDIA runtime.
- AMD: sets `AMD_VISIBLE_DEVICES` and the AMD runtime; needs the AMD Container Toolkit on the host; `/dev/dri` not needed.
- AMD and NVIDIA cannot both be enabled.
- Intel QSV: passes `/dev/dri` into the container.

## Gotchas

- Official image uses PUID/PGID; the plan's fixed UID 568 is a design choice that differs.
- Docker-based tools/mods require network at runtime unless the Modded tag is used.
