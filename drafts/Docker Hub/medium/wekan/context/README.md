# Context index: wekan

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/wekan/values.yaml + Chart.yaml | truecharts-wekan.md |
| https://hub.docker.com/v2/repositories/wekanteam/wekan/ + tags?page_size=10 | dockerhub-wekan.md |
| https://raw.githubusercontent.com/wekan/wekan/v13.20/Dockerfile (also blob/v13.20 URL) | wekan-dockerfile-v13.20.md |
| https://wekan.fi/install | wekan-install-page.md |

Skipped (one line): https://github.com/wekan/wekan (repo HTML), https://wekan.github.io (project site, not build input). No CLA, forgetool, containerforge, templated, binary-download or image-ref URLs in this list.
Failures: none.

## plan.md corrections
- No in-place edits.
- Checked and matching fetched sources: Dockerfile v13.20 uses `debian:trixie` in both stages, `USER wekan`, `ENV PORT=8080`, `EXPOSE $PORT`, `CMD bash /build/wekan-entrypoint.sh`, `STOPSIGNAL SIGKILL`, `NODE_VERSION=v26.13.1`, `WRITABLE_PATH=/data`, misspelled env names (`ACCOUNTS_LOCKOUT_UNKNOWN_USERS_FAILURES_BERORE`, `LDAP_AUTHENTIFICATION`). The Dockerfile ENV block has no `MONGO_URL` default (only `MONGO_URL_FILE=""`).
- Unverified conflict (not edited, version choice is the user's): plan.md says "Latest stable is `v13.31`". Docker Hub (2026-11-27) and wekan.fi/install show `v13.35` / WeKan 13.35 as newest, so plan.md's latest-stable line is stale. The TrueCharts chart pins `v13.35`.
- Unverified: the plan's base `ubuntu:26.04` choice and the bundle layout (`/build` vs `/app/wekan`) were not checked against the upstream entrypoint (releases/ferretdb/wekan-entrypoint.sh not fetched).
