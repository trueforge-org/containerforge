# truecharts ntfy chart

**Source URL(s) + fetch date**
- https://github.com/trueforge-org/truecharts/tree/master/charts/stable/ntfy (listed in draft; not separately fetched)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/ntfy/values.yaml (fetched 2026-11-26)

**Container image used by chart**
- `image.repository: docker.io/binwiederhier/ntfy`
- `image.tag: v2.38.2@sha256:ca35419d29a834824db2440fa9320897fbe40b026c5fc2360c76ed3501b5e716`, `pullPolicy: IfNotPresent`

**Ports**
- `service.main.ports.main.port: 10222`; env `NTFY_LISTEN_HTTP: ":{{ port }}"` so the server listens on 10222 in the chart.

**Persistence**
- `persistence.config` enabled, mount `/etc/ntfy`.
- `persistence.cache` enabled, mount `/var/cache/ntfy`.

**Env and config (configmap `ntfy`)**
- `NTFY_BASE_URL: "http://localhost:10222"`, `NTFY_BEHIND_PROXY: false`, `NTFY_UPSTREAM_BASE_URL: "https://ntfy.sh"`.
- Feature-toggled via `ENABLE_*` (all default false):
  - `NTFY_ATTACHMENT_CACHE_DIR` -> `/var/cache/ntfy/attachments`
  - `NTFY_CACHE_FILE` -> `/var/cache/ntfy/cache.db`
  - `NTFY_AUTH_FILE` -> `/etc/ntfy/user.db`
  - `NTFY_FIREBASE_KEY_FILE` -> `/etc/ntfy/firebase-key.json`
- `args: ["serve"]`; `NTFY_ENABLE_METRICS` from metrics toggle.
- Probes: liveness, readiness, startup all `type: tcp`.
- Metrics ServiceMonitor and PrometheusRule disabled by default.

**Security**
- No `securityContext` in values.yaml; the common library default applies (plan.md says 568 and read-only rootfs true; not verified in this file).

**Gotchas**
- The chart sets `NTFY_BASE_URL` to `http://localhost:10222`; the plan leaves `NTFY_BASE_URL` empty by default.
- Chart uses `/etc/ntfy` and `/var/cache/ntfy`; plan.md maps everything to `/config` (consistent with draft).
