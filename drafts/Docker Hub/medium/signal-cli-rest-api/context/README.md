# context: signal-cli-rest-api

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/signal-cli-rest-api/values.yaml | truecharts-signal-cli-rest-api.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/signal-cli-rest-api/Chart.yaml | truecharts-signal-cli-rest-api.md |
| https://hub.docker.com/v2/repositories/bbernhard/signal-cli-rest-api/ (+ tags?page_size=10) | dockerhub-signal-cli-rest-api.md |
| https://api.github.com/repos/AsamK/signal-cli/releases/latest | github-signal-cli-rest-api-dockerfile.md |
| https://api.github.com/repos/bbernhard/signal-cli-rest-api/license | github-signal-cli-rest-api-dockerfile.md |
| https://api.github.com/repos/bbernhard/signal-cli-rest-api/releases (fetched as releases/latest) | github-signal-cli-rest-api-dockerfile.md |
| https://raw.githubusercontent.com/bbernhard/signal-cli-rest-api/0.101/Dockerfile | github-signal-cli-rest-api-dockerfile.md |
| https://raw.githubusercontent.com/bbernhard/signal-cli-rest-api/0.101/LICENSE | skipped: license via api (MIT) |
| https://bbernhard.github.io/signal-cli-rest-api (follow-up) | docs-signal-cli-rest-api.md |
| https://github.com/bbernhard/signal-cli-rest-api, /blob/0.101/Dockerfile | skipped: HTML/blob variants, raw used |

Skipped categories: GitHub HTML/blob pages (raw or api used); LICENSE raw (api used).

Failures: 1 (https://bbernhard.github.io/signal-cli-rest-api returned no extractable content; docs-signal-cli-rest-api.md; not retried).

## plan.md corrections
- No edits made.
- Confirmed: plan line 8 latest release 0.102; plan line 9 state dir `SIGNAL_CLI_CONFIG_DIR=/home/.local/share/signal-cli` (not /config); plan line 11 MIT; plan line 14 signal-cli latest v0.14.10; plan line 17 PORT default 8080 and EXPOSE ${PORT}; plan line 16 build stage golang:1.26-trixie and runtime debian:trixie-slim (plan said the Dockerfile was only available as summary; verbatim text now fetched).
- Note for author: upstream final stage uses ENTRYPOINT `/init` (s6-overlay) and USER signal-api (1000); plan step 8 sets HOME=/config and a remapped config dir `/config/signal-cli`. Not edited (design choice, not a factual error).
