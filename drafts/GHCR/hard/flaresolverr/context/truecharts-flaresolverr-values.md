# TrueCharts flaresolverr values.yaml

Source URL: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/flaresolverr/values.yaml (fetched 2026-11-27)

## Image
- repository: `ghcr.io/flaresolverr/flaresolverr`
- tag: `v3.5.2@sha256:c80ae007ce2ccdcd217a12426e4f039ef763ff90738c808d38810c3e59323767`
- pullPolicy: IfNotPresent

## Ports
- service.main.ports.main: port 8191 (no targetPort set)

## Env (set by chart)
| Name | Value |
| --- | --- |
| PORT | templated from service port (8191) |
| HOST | 0.0.0.0 |
| TEST_URL | https://www.google.com |
| BROWSER_TIMEOUT | 40000 |
| HEADLESS | true |
| LOG_LEVEL | info |
| LOG_HTML | false |
| CAPTCHA_SOLVER | none |

## Persistence
| Name | mountPath |
| --- | --- |
| config | /config |

## Security context (chart)
- runAsUser 0, runAsGroup 0, runAsNonRoot false, readOnlyRootFilesystem false

## Gotchas
- Chart sets PORT/HOST/TEST_URL/BROWSER_TIMEOUT/HEADLESS/LOG_LEVEL/LOG_HTML/CAPTCHA_SOLVER. These names are what the chart uses; upstream source for them was not fetched in this run.
- Chart runs as root; upstream Dockerfile sets `USER flaresolverr`.
