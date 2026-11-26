# TrueCharts chart: ffmpeg-mkvdts2ac3

Source URL(s) + fetch date:
- https://github.com/trueforge-org/truecharts/tree/master/charts/stable/ffmpeg-mkvdts2ac3 (chart values fetched via raw `values.yaml`, 2026-11-26)

## Image

- `repository`: `docker.io/snoopy86/ffmpeg`
- `tag`: `latest@sha256:4d2695ffee46787cd39a222dbc7c8a42c5d4a1a2dd976d4e23bea00470ac55c9`
- `pullPolicy`: `IfNotPresent`

## Security

- `securityContext.container`: `runAsUser: 0`, `runAsGroup: 0`, `readOnlyRootFilesystem: false`.

## Persistence

- `config` -> `/config`, `copy` -> `/copy`, `output` -> `/output`, `watch` -> `/watch`. All `enabled: true`, no `type` in the snippet.

## Env (container main)

- `script`: `encode.sh` (default)
- `parameters`: `-map 0;-vcodec copy;-scodec copy;-acodec ac3;-b:a 640k`
- `output_format`: `mkv`
- `mkvdts2ac3_params`: `--compress none;-d;-n;-w /output;--new`

## Ports and probes

- `service.main.enabled: false`, `service.main.ports.main.enabled: false`. No liveness, readiness or startup probes.

## Gotchas

- The chart default `script` is `encode.sh`, while the container's default `script` is not stated on the Hub page.
- The chart's `mkvdts2ac3_params` writes `-w /output`, so the temp dir is the output volume in that configuration. Plan's default `-w /tmp/work` differs (intentional by the plan).
