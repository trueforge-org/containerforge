# Context: rss-proxy

| Source URL | File |
| --- | --- |
| https://github.com/damoeb/rss-proxy | damoeb-rss-proxy-readme.md |
| https://github.com/damoeb/rss-proxy/blob/d91dbde/Dockerfile | rss-proxy-dockerfile.md |
| https://github.com/damoeb/rss-proxy/blob/d91dbdef4051951fc7a6d209a23aea55b5f85a1d/Dockerfile | rss-proxy-dockerfile.md (same file, full-SHA duplicate) |
| https://github.com/damoeb/rss-proxy/releases | rss-proxy-releases.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/rss-proxy | truecharts-rss-proxy-values.md |
| https://hub.docker.com/r/damoeb/rss-proxy | dockerhub-damoeb-rss-proxy.md |

Skipped categories: none beyond pre-filtering (urls.txt already filtered).
Failures: none. Recovered: https://api.github.com/repos/damoeb/rss-proxy/releases/latest returned 404 (no releases); one alternative (releases list) returned an empty list. Recorded in rss-proxy-releases.md.

## plan.md corrections
- Line 16 (upstream Dockerfile summary): `TZ` Europe/Berlin -> `APP_TIMEZONE` Europe/Berlin. Source: upstream Dockerfile at d91dbde (ENV `APP_TIMEZONE=Europe/Berlin`; there is no `TZ`).
- Line 18 (env vars): replaced the UNVERIFIED variable-name list with the names from the upstream Dockerfile: `APP_JWT_SECRET`, `APP_ROOT_EMAIL`, `APP_ROOT_SECRET_KEY`, `APP_ACTUATOR_PASSWORD`, `APP_ACTIVE_PROFILES` (the plan's guess `SPRING_PROFILES_ACTIVE` was wrong). Source: upstream Dockerfile at d91dbde.
- Not edited, stale now: plan line 69 still says "Do not list the JWT and root-secret variables until their names are confirmed". Names are confirmed above; the decision is left to the user.
- Verified and consistent: GitHub has no releases (plan line 10 and 14), APP_API_GATEWAY_URL from the README, port 8080, base `damoeb/feedless:core-0.1.3`.
