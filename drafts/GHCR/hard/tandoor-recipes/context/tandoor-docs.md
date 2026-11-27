# Tandoor Recipes docs (docs.tandoor.dev)
Source URLs: https://docs.tandoor.dev ; https://docs.tandoor.dev/install/docker/ ; https://docs.tandoor.dev/system/configuration/ (fetched 2026-11-27, mkdocs)

## Docker install page
- Docker is the officially maintained/tested install method
- Tags on Docker Hub: `latest` (default), `beta`, `develop`, `X.Y.Z` (pinned)
- No downgrade path once DB migrated
- Page examples use image `vabene1111/recipes` (legacy name; chart uses ghcr.io/tandoorrecipes/recipes)
- Container serves app on port 80 via integrated nginx
- Example env: SECRET_KEY, DB_ENGINE=django.db.backends.postgresql, POSTGRES_HOST, POSTGRES_PORT=5432, POSTGRES_USER, POSTGRES_PASSWORD, POSTGRES_DB; volumes /opt/recipes/staticfiles, /opt/recipes/mediafiles

## Configuration page (env vars)
| setting | default | notes |
| --- | --- | --- |
| SECRET_KEY | none (required) | 50+ chars |
| ALLOWED_HOSTS | * | comma list |
| POSTGRES_PORT | 5432 | |
| TANDOOR_PORT | 80 | port of internal web server |
| URL path | none | sub-path serving |
| STATIC_URL | /static/ | |
| STATIC_ROOT | <basedir>/staticfiles | |
| MEDIA_URL | /static/ | |
| MEDIA_ROOT | <basedir>/mediafiles | |
| LOCAL storage paths | <MEDIA_ROOT>/local_provider | comma list |
| Gunicorn workers | 3 | used by boot.sh |
| Gunicorn threads | 2 | used by boot.sh |
| Gunicorn timeout | 30 s | used by boot.sh |
Other sections on page: CSRF trusted origins, CORS, session cookies, captcha, metrics, auth/LDAP, email, S3, AI, debug, rate limits, zip import limits.

## Gotchas
- Docs state settings are read from the app server environment (usually .env)
