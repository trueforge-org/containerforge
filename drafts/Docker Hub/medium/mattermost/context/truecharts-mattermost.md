# TrueCharts chart: mattermost

Source URL(s): https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/mattermost/values.yaml, .../Chart.yaml (fetched 2026-11-26)

## What it is
- Chart `mattermost`, version 18.0.0, appVersion 9.6.0
- Description: open source platform for secure collaboration across the software development lifecycle
- Depends on `common` 32.8.5 from oci://oci.trueforge.org/truecharts

## Image
- Repository: docker.io/mattermost/mattermost-enterprise-edition
- Tag: release-9.6@sha256:f09129649ff61b7f259d30c413da88f9b69fe470f32299cca57632f9f91601d0
- pullPolicy: IfNotPresent

## Env vars
| Name | Value |
| --- | --- |
| TIMEZONE | {{ .Values.TZ }} |
| MM_SQLSETTINGS_DRIVERNAME | postgres |
| MM_BLEVESETTINGS_INDEXDIR | /mattermost/bleve-indexes |
| MM_SERVICESETTINGS_SITEURL | https://test.example.com |
| MM_SQLSETTINGS_DATASOURCE | secretKeyRef `<release>-postgresqlcreds` key `url` |

## Ports
- Service main: port 10239 -> targetPort 8065

## Volumes/paths (all enabled)
| Name | mountPath |
| --- | --- |
| config | /mattermost/config |
| data | /mattermost/data |
| logs | /mattermost/logs |
| plugins | /mattermost/plugins |
| clientplugins | /mattermost/client/plugins |
| bleveindexes | /mattermost/bleve-indexes |

## Dependencies
- postgresql: enabled true; depconfig postgresqlUsername=mattermost, postgresqlDatabase=mattermost

## Not specified in values.yaml
- Probes, securityContext, runAsUser, fsGroup (not set in this file)
