# damoeb/rss-proxy Dockerfile (commit d91dbde)

Source: https://raw.githubusercontent.com/damoeb/rss-proxy/d91dbdef4051951fc7a6d209a23aea55b5f85a1d/Dockerfile (also reached via https://github.com/damoeb/rss-proxy/blob/d91dbde/Dockerfile, same commit), fetched 2026-11-26. Full file read.

## Build
- `FROM damoeb/feedless:core-0.1.3` (base is the feedless core image; the rss-proxy layer only adds files).
- `COPY packages/playground/dist/ ./public` (web playground).
- No RUN, no USER, no EXPOSE, no ENTRYPOINT/CMD in this file.

## Env (ENV)
| Var | Value | Note |
| --- | --- | --- |
| APP_AUTHENTICATION | authRoot | |
| APP_JWT_SECRET | password | placeholder |
| APP_HOST_URL | http://localhost:8080 | |
| APP_ACTUATOR_PASSWORD | password | placeholder |
| APP_TIMEZONE | Europe/Berlin | |
| APP_LOG_LEVEL | error | |
| APP_ACTIVE_PROFILES | legacy,cache,static | |
| APP_WHITELISTED_HOSTS | "" | |
| AUTH_TOKEN_ANONYMOUS_VALIDFORDAYS | 3 | |
| APP_ROOT_EMAIL | admin@localhost | |
| APP_ROOT_SECRET_KEY | password | placeholder |

## Gotchas
- Shipped default secrets are literal `password` (JWT, root secret, actuator).
- Timezone variable is APP_TIMEZONE (not TZ).
- Base image feedless core 0.1.3 is a JVM app (Java version not in this file).
