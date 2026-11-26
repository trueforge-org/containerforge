# TrueCharts chart: answer

**Source URL(s) + fetch date**
- https://github.com/trueforge-org/truecharts/tree/master/charts/stable/answer (listed in draft; the values file was fetched raw)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/answer/values.yaml (fetched 2026-11-26)

**Config (values.yaml)**
- Image: `docker.io/answerdev/answer` tag `1.2.0` with a sha256 digest; pullPolicy `IfNotPresent`.
- Service `main`: http, port 9080 -> targetPort 80. Comment: `INSTALL_PORT` (80) is used only for the initial install and does not change the listening port.
- Persistence `data`: enabled, mountPath `/data`, no size.
- securityContext: not set in values.yaml (no runAsUser, runAsNonRoot, readOnlyRootFilesystem or privileged overrides).
- Env (main): `AUTO_INSTALL: true`, `INSTALL_PORT: 80`, `DB_TYPE: postgres`, `DB_USERNAME` from postgresql depconfig `postgresqlUsername`, `DB_PASSWORD` from secret (release name + `postgresqlcreds`, key `postgresql-password`), `DB_HOST` from postgresql `creds.plainhost` with `:5432`, `DB_NAME` from `postgresqlDatabase`, `LANGUAGE` from `answer.app.language` (default `en-US`), `LOG_LEVEL` default `DEBUG`, `SITE_NAME` "Answer", `SITE_URL` "http://localhost:9080", `CONTACT_EMAIL` "contact@example.com", `ADMIN_NAME` "admin", `ADMIN_PASSWORD` from secret `env-secrets` key `ADMIN_PASSWORD`, `ADMIN_EMAIL` "admin@example.com".
- Secret `env-secrets`: enabled; `ADMIN_PASSWORD` from `answer.admin.password` (placeholder default in the file).
- Probes: liveness and readiness `/healthz` (http); startup tcp.
- PostgreSQL dependency: enabled, username `answer`, database `answer`.
- `operator.verify.enabled: false`.

**Gotchas**
- Chart persists `/data`, matching the upstream `VOLUME /data`. plan.md's `/config` remap is a ContainerForge decision, not a chart fact.
- The chart uses postgres via `AUTO_INSTALL`, so the postgres path needs the optional dependency (plan.md optional dep).
