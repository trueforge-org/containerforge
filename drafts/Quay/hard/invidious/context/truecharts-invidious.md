# TrueCharts invidious (stable)

Source URL(s): https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/invidious/values.yaml , .../Chart.yaml (fetched 2026-11-27)

## What it is
- Invidious: open source alternative YouTube front-end. Chart version 15.0.0, appVersion latest.
- Depends on common 32.8.5 (oci://oci.trueforge.org/truecharts) and PostgreSQL (dependencies.postgresql, enabled, db invidious, user kemal).
- Chart sources: docs.invidious.io/installation/#docker, github iv-org/invidious, quay.io/invidious/invidious.

## Image
- repository: quay.io/invidious/invidious
- tag: latest@sha256:90115ee1781332e988d357249fd2b2460244a8ef380a0c0772ad7fbe1318427f

## Ports
- main: 10594 (http) ; inbound external_port 10594. Container EXPOSE 3000 in upstream Dockerfile (chart maps service to 10594).

## Security context
- runAsUser 0, runAsGroup 0, runAsNonRoot false, readOnlyRootFilesystem false.

## Init container (dbseed)
- alpine-based installer: `apk add git`, clones invidious master docker/config dirs, runs ./init-invidious-db.sh with PG env (POSTGRES_DB from secret <release>-postgresqlcreds key url; PGPASSWORD from postgresql-password).
- Uses imageSelector postgresClientImage.

## Secrets / config
- Container envFrom: secret invidious-secret.
- invidious.hmacKey: must be random, >=64 chars (chart placeholder).
- invidious.network.inbound.external_port 10594, https_only false, domain "", hsts true.
- invidious.logging output STDOUT, level Info.
- Other notable defaults: registration_enabled true, captcha_enabled true, use_pubsub_feeds false, playlist_length_limit 500, channel_refresh_interval 30m, pool_size 100, force_resolve ipv4.
- captcha_api_url https://api.anti-captcha.com ; captcha_key empty.

## Probes
- liveness, readiness, startup: type http (path default).

## Gotchas
- Chart pins latest digest; not a version tag.
