# TrueCharts paperless-ngx chart values

Source URL: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/paperless-ngx/values.yaml (fetched)
Also: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/paperless-ngx (not fetched)

## Images (sha256 pinned)
- Main: ghcr.io/paperless-ngx/paperless-ngx:3.5.1, pullPolicy IfNotPresent
- Gotenberg: docker.io/gotenberg/gotenberg:9.10
- Tika: docker.io/apache/tika:3.4.0.0

## Ports
- Main service 10140 -> targetPort 8000; Gotenberg 3000; Tika 9998
- Gotenberg and Tika gated by tika.enabled (default false)

## Main env
- Paths: data /data/, consume /consume/, media /media/
- PAPERLESS_PORT from targetPort; PAPERLESS_URL empty; TZ from .Values.TZ
- USERMAP_UID from PUID; USERMAP_GID from pod fsGroup
- DB: engine postgresql, port 5432, name and user "paperless-ng"; password/host from postgresql creds secret
- Redis URL from valkey creds secret
- PAPERLESS_TIKA_ENABLED 1/0 per tika.enabled; Gotenberg http://<fullname>-gotenberg:3000; Tika http://<fullname>-tika:9998
- PAPERLESS_WEBSERVER_WORKERS=2
- Admin user "admin" (password from secret env-secrets, default "admin")
- OCR language eng; OCR languages "eng fra deu spa ita"
- PAPERLESS_SECRET_KEY from secret `secrets`; placeholder must be changed (>=32 random chars)

## Persistence
- data -> /data, consume -> /consume, media -> /media; varrun disabled

## Probes
- Main: http, Host: localhost header
- Gotenberg: http /health :3000; command `gotenberg --chromium-disable-javascript=true --chromium-allow-list=file:///tmp/.*`
- Tika: http / :9998

## Security
- runAsNonRoot false, readOnlyRootFilesystem false, runAsUser 0, runAsGroup 0

## Dependencies
- Valkey (enabled), PostgreSQL (enabled; user/db "paperless-ng"); Tika and Gotenberg optional (disabled by default)
