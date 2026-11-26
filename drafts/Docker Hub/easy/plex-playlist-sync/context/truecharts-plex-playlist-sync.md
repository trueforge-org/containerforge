# truecharts plex-playlist-sync chart

**Source URL(s) + fetch date**
- https://github.com/trueforge-org/truecharts/tree/master/charts/stable/plex-playlist-sync (listed in draft; not separately fetched)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/plex-playlist-sync/values.yaml (fetched 2026-11-26)

**Container image used by chart**
- `image.repository: docker.io/rnagabhyrava/plexplaylistsync`
- `image.tag: latest@sha256:c9e85cb9def574004602c5a37b25b360b635fd4547e274fb1572318068180cf4`, `pullPolicy: IfNotPresent`

**Ports and service**
- `service.main` disabled and `service.main.ports.main` disabled (no port).

**Persistence**
- `persistence.data` enabled, mountPath `/data`. ContainerForge plan maps this to `/config/data` via symlink (plan.md).

**Security**
- `securityContext.container`: `readOnlyRootFilesystem: false`, `runAsNonRoot: false`, `runAsUser: 0`, `runAsGroup: 0`.

**Probes**
- Liveness, readiness and startup disabled.

**Env (chart `pps` values templated to env)**
- `PLEX_URL` default `http://localhost:32400` in chart values; `PLEX_TOKEN` from secret `env-secrets` (placeholder `plextoken123`).
- `SPOTIFY_CLIENT_ID`, `SPOTIFY_USER_ID` (empty), `SPOTIFY_CLIENT_SECRET` from secret (empty).
- `DEEZER_USER_ID` (empty), `DEEZER_PLAYLIST_ID` from list joined with spaces (`join " "`).
- `WRITE_MISSING_AS_CSV: false`, `APPEND_SERVICE_SUFFIX: true`, `ADD_PLAYLIST_POSTER: true`, `ADD_PLAYLIST_DESCRIPTION: true`, `APPEND_INSTEAD_OF_SYNC: false`, `SECONDS_TO_WAIT: 84000`.

**Gotchas**
- Chart runs as root with a writable rootfs; ContainerForge should run as `apps` with read-only rootfs (plan.md).
- Chart uses `APPEND_SERVICE_SUFFIX`, which does not appear in the v1.0.2 `run.py` or `utils/plex.py` reads.
