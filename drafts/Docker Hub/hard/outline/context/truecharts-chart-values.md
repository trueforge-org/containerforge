# TrueCharts outline chart (charts/stable/outline)

Source URLs:
- https://github.com/trueforge-org/truecharts/tree/master/charts/stable/outline (directory listing, fetched)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/outline/values.yaml (fetched)

## Files
.helmignore, CHANGELOG.md, Chart.yaml, README.md, icon(-small).webp, values.schema.json, values.yaml, templates/

## What it is
- Helm chart built on the common library chart (charts/library/common). Not maintained by upstream.
- OCI install: oci://oci.trueforge.org/truecharts/outline

## values.yaml
- Image: docker.io/outlinewiki/outline, tag 1.13.0, pinned by sha256 digest; pullPolicy IfNotPresent
- Service main port: 10196 (PORT env references it)
- Env defaults: FORCE_HTTPS=false, PGSSLMODE=disable, URL=http://localhost:<port>, SLACK_MESSAGE_ACTIONS=true, ENABLE_UPDATES=true, WEB_CONCURRENCY=1, MAXIMUM_IMPORT_SIZE=5120000, DEFAULT_LANGUAGE=en_US, FILE_STORAGE="", FILE_STORAGE_UPLOAD_MAX_SIZE=""
- DATABASE_URL from secret <release>-postgresqlcreds key `url`; REDIS_URL from secret <release>-valkeycreds key `url`
- SECRET_KEY / UTILS_SECRET from secret "secrets" (placeholder 64-hex values; must be changed)
- Persistence: `data` volume at /var/lib/outline/data
- Probes (liveness/readiness/startup): /_health
- securityContext: readOnlyRootFilesystem false, runAsNonRoot false, runAsUser 0, runAsGroup 0 (runs as root)
- Dependencies enabled: valkey (Redis-compatible), PostgreSQL (user and db `outline`)
- Commented options: S3 settings, SMTP (port 587, secure true), OIDC/Google/Azure/Slack auth, Sentry, TEAM_LOGO
