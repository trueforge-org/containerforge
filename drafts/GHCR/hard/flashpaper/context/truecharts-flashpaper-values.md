# TrueCharts flashpaper values.yaml

Source URL: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/flashpaper/values.yaml (fetched 2026-11-27)

## Image
- repository: `ghcr.io/andrewpaglusch/flashpaper`
- tag: `master@sha256:e4add58d28b4fba45de44956465b1c36a3e64bbaaa0e52a643e6c5d06acfb58a`
- pullPolicy: IfNotPresent (tag is `master`, not a version)

## Ports
- service.main.ports.main: port 8544, targetPort 80, protocol tcp

## Persistence
| Name | mountPath |
| --- | --- |
| data | /var/www/html/data |
| varrun | disabled |

## Security context (chart)
- runAsUser 0, runAsGroup 0, runAsNonRoot false, readOnlyRootFilesystem false

## Env (set by chart, all under workload.main.podSpec.containers.main.env)
| Name | Value |
| --- | --- |
| ANNOUNCEMENT | "" |
| MAX_SECRET_LENGTH | 3000 |
| MESSAGES_CONFIRM_VIEW_SECRET_BUTTON | View Secret |
| MESSAGES_CONFIRM_VIEW_SECRET_HEADER | View this secret? |
| MESSAGES_ERROR_SECRET_TOO_LONG | Input length too long |
| MESSAGES_SUBMIT_SECRET_BUTTON | Encrypt Message |
| MESSAGES_SUBMIT_SECRET_HEADER | Create A Self-Destructing Message |
| MESSAGES_SUBMIT_SECRET_SUBHEADER | "" |
| MESSAGES_VIEW_CODE_HEADER | Self-Destructing URL |
| MESSAGES_VIEW_CODE_SUBHEADER | "Share this URL via email, chat, or another messaging service. It will self-destruct after being viewed once." |
| MESSAGES_VIEW_SECRET_HEADER | This message has been destroyed |
| PRUNE_ENABLED | true |
| PRUNE_MAX_DAYS | 730 |
| PRUNE_MIN_DAYS | 365 |
| RETURN_FULL_URL | true |
| SITE_TITLE | FlashPaper - Self-Destructing Message |

## Gotchas
- Chart's env names (MESSAGES_*, PRUNE_*, RETURN_FULL_URL, ANNOUNCEMENT, MAX_SECRET_LENGTH, SITE_TITLE) are not set by the upstream Dockerfile or entrypoint.sh (ENV list in the Dockerfile is empty). The app-side reader for them (possibly docker/settings.php, which the Dockerfile copies) was not fetched.
- Chart's data path /var/www/html/data is the upstream VOLUME path, not a ContainerForge path.
