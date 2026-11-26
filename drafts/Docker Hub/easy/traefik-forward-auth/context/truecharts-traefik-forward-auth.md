# TrueCharts traefik-forward-auth chart

**Source URL(s) + fetch date**
- https://github.com/trueforge-org/truecharts/tree/master/charts/stable/traefik-forward-auth (chart directory)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/traefik-forward-auth/values.yaml (fetched 2026-11-26)

**What it is**
The chart that uses `thomseddon/traefik-forward-auth` as its main container.

**Image (values.yaml)**
- repository `docker.io/thomseddon/traefik-forward-auth`
- tag `latest@sha256:b364aa6a4117569163eff793999901f9f5a0c4f7f2da18b4ecbcd140d7b6107b`
- pullPolicy `IfNotPresent`

**Security context**
Not defined in values.yaml.

**Env**
No `env` block. The main container uses `envFrom` with `secretRef` `tfa-secrets` (so provider credentials and SECRET come from that Kubernetes secret).

**Persistence**
Not defined.

**Service/ports**
- `service.main.ports.main`: `targetPort: 4181`, `port: 4181`.

**Gotchas**
- The chart runs the Docker Hub `latest` image by digest, not the `2.3.0` tag the plan uses.
- Secrets come from `tfa-secrets`, so the chart expects `SECRET` and provider credentials to be supplied there.
