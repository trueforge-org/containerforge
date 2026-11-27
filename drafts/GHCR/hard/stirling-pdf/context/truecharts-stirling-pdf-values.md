# TrueCharts stirling-pdf values.yaml
Source URL: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/stirling-pdf/values.yaml (fetched 2026-11-27)

## Images (all ghcr.io/stirling-tools/s-pdf, pullPolicy IfNotPresent)
| value | tag |
| --- | --- |
| image (default, `imageSelector: image`) | 3.5.0-ultra-lite@sha256:352d0e8cbaca82ac59989875456935a33a554882f15466b5d6f93142ff9b0043 |
| fatImage | 3.5.0-fat@sha256:a1e32cc644f03969997f3396089e63131ac8ac3bb15ad8c559047d39f996d91a |
| fullImage | 3.5.0@sha256:f5a38801f2dd551c26d0089ee3ea48d86a565e3adb414cb31e974bc9562cb48a |

## Security
- runAsNonRoot false, readOnlyRootFilesystem false, runAsUser 0, runAsGroup 0

## Ports
- service main: protocol http, targetPort 8080, port 18080

## Env (workload main)
| env | value |
| --- | --- |
| DOCKER_ENABLE_SECURITY | false |
| INSTALL_BOOK_AND_ADVANCED_HTML_OPS | false (Calibre) |
| LANGS | en_US |
Commented-out: SECURITY_INITIALLOGIN_USERNAME / SECURITY_INITIALLOGIN_PASSWORD (default admin/stirling in comment).

## Persistence
| name | mountPath |
| --- | --- |
| configs | /configs |
| tessdata | /usr/share/tessdata |
| custom-files | /customFiles |
| logs | /logs |
