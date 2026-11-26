# TrueCharts chart: flexo

Source URL(s) + fetch date:
- https://github.com/trueforge-org/truecharts/tree/master/charts/stable/flexo (chart values via raw `master/charts/stable/flexo/values.yaml`), fetched 2026-11-26

## Image

- `repository`: `docker.io/nroi/flexo`
- `tag`: `1.6.14@sha256:3787e3d1ac567423d61f17b07b3128e59a26b7cd980443462b220528b5929c6d`
- `pullPolicy`: `IfNotPresent`

## Security

- No `securityContext` in values. Chart default applies (draft/plan: non-root 568, read-only rootfs true, not privileged). Not overridden.

## Persistence

- `data`: enabled, `type: emptyDir`, `size: 10Gi`, mounted at `/var/cache/flexo`.

## Env (verbatim keys)

- `FLEXO_LISTEN_IP_ADDRESS` = `"0.0.0.0"`
- `FLEXO_PORT` = `"{{ .Values.service.main.ports.main.port }}"` (templated to 7878)

## Ports and probes

- service `main` port `7878`, protocol `http`.
- Liveness, readiness and startup probes: path `/metrics`. Whether upstream Flexo serves `/metrics` is not documented in the fetched upstream sources (UNVERIFIED).

## Dependencies

- None shown in values.

## Gotchas

- Chart's pinned tag is 1.6.14; the plan targets 1.6.14 too.
- Chart's cache is emptyDir, which matches the plan's caveat that cache is lost on pod restart.
- The `/metrics` probe path differs from the plan's container test, which uses TCP only.
