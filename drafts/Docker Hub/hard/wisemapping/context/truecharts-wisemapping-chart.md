# TrueCharts wisemapping chart (reference only; outdated image layout)

## Source URL(s) + date
- https://github.com/trueforge-org/truecharts/tree/master/charts/stable/wisemapping (tree page not parsed; files below fetched 2026-11-26)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/wisemapping/Chart.yaml
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/wisemapping/values.yaml

## What it is
- Helm chart `wisemapping`, chart version 7.0.0, appVersion `latest`, train stable, category design.
- Depends on `common` 32.8.5 (oci://oci.trueforge.org/truecharts) and PostgreSQL (`dependencies.postgresql.enabled: true`, user/db `wisemapping`).
- kubeVersion `>=1.33.0-0`. Description text in Chart.yaml says "home-assistant App" (copy-paste error upstream of the chart).

## Image (values.yaml)
- repository `docker.io/wisemapping/wisemapping`
- tag `latest@sha256:5a0a48137a284a7c4b7e3051c457addb6e5c991b99356a32735059f847269b78`

## Ports
- service main 8080 -> 8080

## Security context
- readOnlyRootFilesystem false, runAsNonRoot false, runAsUser 0, runAsGroup 0

## Config/paths
- `wisemappingConfig` mounted as configmap at `/usr/local/tomcat/webapps/ROOT/WEB-INF/app.properties`
- init container copies `.../WEB-INF/app.properties.dummy` to `app.properties` (Tomcat-era layout)
- persistence `config` mountPath `/usr/local/tomcat/webapps/ROOT/WEB-INF/` (disabled by default)

## Env
- `ADMIN_EMAIL: "change@me.com"`

## Probes
- liveness, readiness, startup: tcp

## Gotchas
- Layout (Tomcat WEB-INF/app.properties, port 8080) does NOT match upstream `distribution/app/Dockerfile` at 5099d14 (nginx on port 80 + Spring Boot, config via `/app/config/` optional app.yml). Treat as stale reference.
