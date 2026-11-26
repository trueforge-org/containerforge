# TrueCharts chart: discordgsm

Source URL(s) + fetch date:
- https://github.com/trueforge-org/truecharts/tree/master/charts/stable/discordgsm (directory; content read from raw `charts/stable/discordgsm/values.yaml`) · 2026-11-26

## Values (as of fetch)
- Image: `docker.io/discordgsm/discord-game-server-monitor`, tag `2.20.1@sha256:c50826cb218cbd87e304e429bbf3a7272e7ee8ab84f1ea2c6ed3e036ffb942f4`, pullPolicy `IfNotPresent`.
- Env: `env` empty; `envFrom` from secret `gsm-secret` (variable names not listed).
- `gsm` config block: workers 2; timeout 90; app_token (empty/redacted); whitelist_guilds (empty list); app_activity_type 3; app_activity_name empty; app_presence_advertise false; task_query_server 60; command_query_public false; command_query_cooldown 5; web_api_enable false; postgres_ssl_mode `disable`; factorio_username and factorio_auth_token empty.
- Service main, port `main` 10230 (http).
- Persistence: `config` mounted at `/app/data`.
- Dependency: `postgresql` enabled, database and user `discord_gsm`.
- securityContext: runAsNonRoot false, readOnlyRootFilesystem false, runAsUser 0, runAsGroup 0.
- Probes: liveness, readiness and startup all `http`.
- Command: `/bin/sh -c` starts gunicorn in the background on `0.0.0.0:<service port>`, `gthread` worker class, `app:app`, then `python -u main.py`.

## Contradictions / notes vs plan.md
- Chart runs gunicorn (web API) and the bot in one container. Plan.md does not start gunicorn (web API off by default; open question there). Consistent with plan.md's `WEB_API_ENABLE` note.
- Chart sets `postgres_ssl_mode: disable`. plan.md default is `require`. Both are valid; plan.md says a server without TLS needs `disable` or `prefer`.
- Chart's dependency on postgresql is optional for upstream (sqlite is default). plan.md's "optional" claim holds.
