# TrueCharts chart: fireshare

Source URL(s) + fetch date:
- https://github.com/trueforge-org/truecharts/tree/master/charts/stable/fireshare (chart values via raw `values.yaml`, fetched 2026-11-26)

## Image

- `repository`: `docker.io/shaneisrael/fireshare`
- `tag`: `1.9.6@sha256:73b4bea645262d40f6b3a07c25afe29c4f2692c1be995b30dac320b7d83b32f2`
- `pullPolicy`: `IfNotPresent`

## Security

- `runAsUser: 0`, `runAsGroup: 0`, `readOnlyRootFilesystem: false`. `privileged` not specified.

## Persistence (all enabled, no `type`)

- `data` -> `/data`; `processeddata` -> `/processed`; `videos` -> `/videos`; `images` -> `/images`.

## Env (main container)

- `SECRET_KEY`: from secret `fireshare-secrets` key `SECRET_KEY`
- `MINUTES_BETWEEN_VIDEO_SCANS`: `5`
- `ADMIN_PASSWORD`: from secret `env-secrets` key `ADMIN_PASSWORD`
- LDAP variables commented out under a TODO (inactive).

## Related values

- `fireshare.secretKey`: placeholder `PLACEHOLDERSECRETKEY000000000000` (must be changed to random, at least 32 characters).
- Secret `env-secrets`: `ADMIN_PASSWORD: "changeme"`.

## Ports

- service `main` port `10287`, protocol http, targetPort `80`.

## Probes and GPU

- No probes defined in the fetched content. No GPU/device settings.

## Gotchas

- Chart pins `1.9.6`, the draft says `1.9.3`, and plan says `1.9.4` with latest `1.9.5`. Newest version evidence is the chart (1.9.6); not confirmed against GitHub releases.
- Chart uses the standard (CUDA) image, not `-lite`; the chart does not set GPU settings.
