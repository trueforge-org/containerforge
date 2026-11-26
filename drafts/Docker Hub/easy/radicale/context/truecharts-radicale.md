# TrueCharts chart: radicale

Source URL(s) + fetch date (2026-11-26):
- https://github.com/trueforge-org/truecharts/tree/master/charts/stable/radicale (tree, not fetched directly)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/radicale/values.yaml (fetched)

## Image
- repository `docker.io/tomsquest/docker-radicale`, tag `3.9.2.0@sha256:cc586f75ec709d45d15dfbf20e53bab99e85ee5a4d7beafc7bbf852b2f07a2da`, pullPolicy IfNotPresent.

## Ports
- service.main port 5232, protocol http.

## Persistence
- `config-file`: configmap `radicale-config`, mountPath `/config/config`, subPath `config`.
- `users`: configmap `radicale-users`, mountPath `/config/users`, subPath `users`.
- `data`: mountPath `/data`.

## securityContext
- container: drop ALL; add SETUID, SETGID, KILL; runAsUser 2999; runAsGroup 2999.
- pod: fsGroup 2999.

## Env vars
- `TAKE_FILE_OWNERSHIP: false`.

## Radicale config values (chart)
- auth: type htpasswd, delay 1, realm `Radicale - Password Required`, users [].
- encoding: request utf-8, stock utf-8.
- logging: level warning, mask_passwords true.
- rights: type owner_only.
- server: max_connections 8, max_content_length 100000000, timeout 30.
- storage: type multifilesystem, max_sync_token_age 2592000.
- web: type internal.

## Probes
- None.
