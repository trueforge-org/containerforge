# TrueCharts chart: grafana
Source URL(s): https://github.com/trueforge-org/truecharts/tree/master/charts/stable/grafana (raw values.yaml + Chart.yaml fetched 2026-11-26; values.yaml is 533 lines, dashboards block omitted here)

## Chart.yaml
- name grafana, chart version 25.0.1, appVersion 13.3.2
- dependency: common 32.8.5 (oci://oci.trueforge.org/truecharts); dependency postgresql (enabled, see below)
- train stable; min helm 3.14, max helm 4.1; max k8s 1.35.0

## Image
| Key | Value |
| --- | --- |
| image.repository | docker.io/grafana/grafana |
| image.tag | 13.3.2@sha256:81556409ba48b2b922e0adb69a2511337d8ba7578f11962eefa6149a2d815101 |
| sidecarImage | ghcr.io/kiwigrid/k8s-sidecar 2.14.3@sha256:52d311dcedd587421a236c4d6c621f05614c40a51386e955e0699dca97ec0880 |

## Service / ports
- service.main.ports.main: port 3000, targetPort 3000, protocol http

## Main container env (workload.main.podSpec.containers.main.env)
| Env | Value |
| --- | --- |
| GF_SECURITY_ADMIN_USER | admin |
| GF_SECURITY_ADMIN_PASSWORD | secretKeyRef env-secrets (chart default secret value "testpassword") |
| GF_INSTALL_PLUGINS | "" |
| GF_AUTH_LDAP_ENABLED | "false" |
| GF_AUTH_LDAP_ALLOW_SIGN_UP | "false" |
| GF_SERVER_HTTP_PORT | 3000 |
| GF_DATABASE_TYPE | postgres |
| GF_DATABASE_NAME | grafana (from dependencies.postgresql.depconfig.postgresqlUsername) |
| GF_DATABASE_USER | grafana (from ...postgresqlDatabase) |
| GF_DATABASE_SSL_MODE | disable |
| GF_DATABASE_HOST | secretKeyRef <release>-postgresqlcreds key plainhost |
| GF_DATABASE_PASSWORD | secretKeyRef <release>-postgresqlcreds key postgresql-password |

## Probes
- liveness, readiness, startup: HTTP path /api/health

## Sidecars / init (chart-specific, not in upstream image)
- initContainer download-dashboards runs /download-dashboards.sh (ubuntuImage)
- sidecar containers dashboards, datasources, alerts, plugins, notifiers (k8s-sidecar, METHOD WATCH, LABEL grafana_dashboard|grafana_datasource|grafana_alerts|grafana_plugins|grafana_notifiers, LABEL_VALUE "1", REQ_URL http://localhost:3000/api/admin/provisioning/<kind>/reload, REQ_METHOD POST, REQ_USERNAME admin)
- Sidecar FOLDER: /tmp/dashboards, /etc/grafana/provisioning/{datasources,alerts,plugins,notifiers}

## Volumes / paths
| Mount | Type | Path |
| --- | --- | --- |
| config | configmap config subPath grafana.ini | /etc/grafana/grafana.ini |
| ldap | configmap config subPath ldap.toml | /etc/grafana/ldap.toml |
| data | persistence (type not set in chart values) | /var/lib/grafana |
| grafana-tmp | emptyDir | /app/tmp |
| sc-dashboard-volume | emptyDir | /tmp/dashboards |
| sc-dashboard-config | configmap dashboard-provider subPath provider.yaml | /etc/grafana/provisioning/dashboards/sc-dashboardproviders.yaml |
| download-dashboards-config | configmap, mode 0555 | /download-dashboards.sh |
| sc-datasource/alerts/plugins/notifiers-volume | emptyDir | /etc/grafana/provisioning/{datasources,alerts,plugins,notifiers} |

## Config (configmap config, grafana.ini excerpt)
- paths.data /var/lib/grafana/, logs /var/log/grafana, plugins /var/lib/grafana/plugins, provisioning /etc/grafana/provisioning
- log.mode console; analytics.check_for_updates true; grafana_net.url https://grafana.net
- server.domain from ingress.main host if enabled

## Other
- securityContext.container.readOnlyRootFilesystem: false
- rbac.main: clusterWide, get/watch/list on configmaps and secrets (for sidecars)
- metrics.main: servicemonitor, port main, path /metrics
- podOptions.automountServiceAccountToken: true
- Strategy Recreate, replicas 1
- Dashboard marketplace IDs/URLs listed in values (disabled by default except cert-manager, id 20842 rev 3)
