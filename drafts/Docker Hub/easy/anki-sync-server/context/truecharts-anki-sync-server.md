# TrueCharts chart: anki-sync-server

**Source URL(s) + fetch date**
- https://github.com/trueforge-org/truecharts/tree/master/charts/stable/anki-sync-server (fetched 2026-11-26)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/anki-sync-server/values.yaml

**What it is**
- TrueCharts stable chart `anki-sync-server`. Chart folder contains `templates/`, `.helmignore`, `CHANGELOG.md`, `Chart.yaml`, `README.md`, `icon-small.webp`, `icon.webp`, `values.schema.json`, `values.yaml`.
- README says the chart is "not maintained by the upstream project". Chart docs: https://truecharts.org/charts/stable/anki-sync-server. Install: `helm install mychart oci://oci.trueforge.org/truecharts/anki-sync-server`.
- Chart.yaml contents were not visible, so description and appVersion are unknown.

**Config files and formats (values.yaml)**
- Image: `1.1.4@sha256:c6e05752c62f6115eb0cb9f729ee599bb8d41a021b454a5f08bb55525894dec4`, repository `docker.io/ankicommunity/anki-sync-server-rs`, pullPolicy `IfNotPresent`.
- Service `main`, port `main`: 27701 -> targetPort 27701.
- Persistence `config`: enabled, mounted at `/app/data`, no size set.
- Container securityContext: runAsUser 0, runAsGroup 0, runAsNonRoot false, readOnlyRootFilesystem false, privileged not set.
- Env (main): `ANKISYNCD_USERNAME` = "test"; `ANKISYNCD_PASSWORD` from secret `env-secrets` key `ANKISYNCD_PASSWORD`. Secret `env-secrets` enabled, with `ANKISYNCD_PASSWORD` = "123456" (sample value in the chart).
- Probes: liveness, readiness and startup all HTTP `/`.

**Gotchas**
- The chart mounts data at `/app/data`, while the upstream image declares `VOLUME /app` and the default config's `root_dir` is `/app`. The `/app/data` path does not match upstream's `root_dir` of `/app` (plan.md's data-location conflict is confirmed).
- Chart sets an env-based user, so the user-from-env path is what the chart relies on.
