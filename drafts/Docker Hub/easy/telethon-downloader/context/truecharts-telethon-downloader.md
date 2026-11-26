# TrueCharts telethon-downloader chart

**Source URL(s) + fetch date**
- https://github.com/trueforge-org/truecharts/tree/master/charts/stable/telethon-downloader (chart directory)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/telethon-downloader/values.yaml (fetched 2026-11-26)

**What it is**
The chart that uses this image as its main container.

**Image (values.yaml)**
- repository `docker.io/jsavargas/telethon_downloader`
- tag `latest@sha256:f9ad5f0caff72301cefddad3c9e866d064d627a7054b5fa8ae7b0d6d07de4af2`
- pullPolicy `IfNotPresent`

**Security context (container)**
- runAsUser `0`, runAsGroup `0`
- readOnlyRootFilesystem `false`
- privileged: not set in the fetched content

**Env**
- `TG_API_HASH`, `TG_API_ID`, `TG_AUTHORIZED_USER_ID`: `" "`
- `TG_BOT_TOKEN`: secretKeyRef `env-secrets` / key `TG_BOT_TOKEN` (secret enabled, value empty)
- `TG_PROGRESS_DOWNLOAD`: `""`

**Persistence**
- `config` at `/config`, `pathdownload` at `/download`, `pathwatch` at `/watch`, all enabled.

**Service/ports**
- `service.main.enabled: false`; no ports exposed.

**Probes**
- liveness, readiness, startup all disabled.

**Gotchas**
- The chart's env names are the `TG_` set; the chart runs as UID 0 with a writable rootfs, unlike the plan's rootless target.
