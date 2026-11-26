# TrueCharts phpldapadmin chart values

Source URL: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/phpldapadmin/values.yaml (fetched)
Chart page: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/phpldapadmin (not fetched)

- Image: docker.io/osixia/phpldapadmin:0.9.0 (sha256 pinned), pullPolicy IfNotPresent. Uses the ARCHIVED osixia image.
- Main service port 10026 -> targetPort 80
- Env defaults: PHPLDAPADMIN_HTTPS=false, PHPLDAPADMIN_TRUST_PROXY_SSL=true
- Persistence: varrun disabled; no paths
- Probes: none
- securityContext: runAsUser 0, runAsGroup 0 (root), readOnlyRootFilesystem false
- Deps: none
- Schema: values.schema.json
