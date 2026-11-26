# TrueCharts chart cannery (values.yaml)

Source URL(s) + fetch date:
- https://github.com/trueforge-org/truecharts/tree/master/charts/stable/cannery (raw values.yaml: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/cannery/values.yaml) · fetched 2026-11-26

## Image
`docker.io/shibaobun/cannery:1.5.9@sha256:bf1da2b577b1893c68ff3a68895b46971b14b5216b9042f0adb991aa160f0226`, pullPolicy IfNotPresent.

## Command
`/bin/sh -c`; creates `${UPLOADS_PATH}/tmp`, then `exec /app/bin/cannery start`.

## Ports
Main `http` port 4000.

## Env
- PORT: 4000 (templated). HOST: `cannery.local`. DATABASE_URL, CLOAK_KEY, SECRET_KEY_BASE, SMTP_PASSWORD from secret `env-secrets`.
- ECTO_IPV6 `false`, REGISTRATION `invite`, LOCALE `en_US`, SMTP_HOST `smtp.gmail.com`, SMTP_USERNAME `example@gmail.com`, SMTP_SSL `false`, EMAIL_FROM `no-reply@HOST`, EMAIL_NAME `Cannery`.
- Commented out: POOL_SIZE (10), SMTP_PORT (587).

## Persistence
uploads -> `/var/cannery/uploads` (enabled).

## Security context / probes
securityContext, readOnlyRootFilesystem, runAsUser not set. No probes.

## Database
postgresql dependency enabled; username and database `cannery`; DATABASE_URL built as `ecto://user:password@host:5432/database`.

## Secrets (placeholder values)
SECRET_KEY_BASE, CLOAK_KEY placeholder values ("change-me-32-random-bytes-base64"), SMTP_PASSWORD `example`.

## Gotchas
- Chart pins `1.5.9`; `UPLOADS_PATH` value is in the chart's `command` and persistence, not env.
