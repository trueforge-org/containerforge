# context: shlink

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/shlink/values.yaml | truecharts-shlink.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/shlink/Chart.yaml | truecharts-shlink.md |
| https://raw.githubusercontent.com/shlinkio/shlink/v5.1.9/Dockerfile | truecharts-shlink.md (section "Upstream image") |
| https://raw.githubusercontent.com/shlinkio/shlink/v5.1.9/docker/docker-entrypoint.sh | truecharts-shlink.md (section "Entrypoint") |
| https://raw.githubusercontent.com/shlinkio/shlink/v5.1.9/config/roadrunner/.rr.yml | truecharts-shlink.md (section "RoadRunner config") |
| https://raw.githubusercontent.com/shlinkio/shlink/v5.1.9/LICENSE | truecharts-shlink.md (License, MIT) |
| https://api.github.com/repos/shlinkio/shlink/releases/latest | failed (403 rate limit); alt https://github.com/shlinkio/shlink/releases/latest redirect -> v5.1.9 (in truecharts-shlink.md) |

Skipped categories: github repo root (not fetched); github blob Dockerfile at v5.1.8 (mismatch with v5.1.9 raw, see plan note); https://shlink.io and https://shlink.io/documentation (marketing/docs index, not fetched, budget); no containerforge app links; no templated URLs; no binary downloads (RoadRunner via `rr get` and MS ODBC apk named in Dockerfile only).

Failures: api.github.com releases/latest (403), alt used.

## plan.md corrections
- none
- Unverified conflict: plan lists blob Dockerfile at v5.1.8 while the raw Dockerfile, LICENSE, .rr.yml and entrypoint are at v5.1.9 (chart pins 5.1.9). Not edited.
