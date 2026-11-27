# Upstream: ix-ai/smtp v0.7.7 (Dockerfile, entrypoint.sh, README)

Source URLs (fetched 2026-11-27, tag v0.7.7):
- https://raw.githubusercontent.com/ix-ai/smtp/v0.7.7/Dockerfile
- https://raw.githubusercontent.com/ix-ai/smtp/v0.7.7/entrypoint.sh
- https://raw.githubusercontent.com/ix-ai/smtp/v0.7.7/README.md

## Status
- README: "This project is deprecated and has been archived". Successor: gitlab.com/egos-tech/smtp, image `registry.gitlab.com/egos-tech/smtp:1.0.0` (one-to-one compatible with this repo's latest).

## Dockerfile
- `FROM public.ecr.aws/docker/library/debian:stable-slim@sha256:00a24d7c...`.
- ARG PORT=25, BIND_IP=0.0.0.0, BIND_IP6=::0, CI_PIPELINE_ID.
- apt (no-install-recommends): ca-certificates exim4-daemon-light iproute2; `dist-upgrade` first; purge lists, logs truncated.
- `ENV PORT=${PORT} BIND_IP=${BIND_IP} BIND_IP6=${BIND_IP6}`; `EXPOSE ${PORT}`.
- COPY entrypoint.sh, set-exim4-update-conf, update-exim4.conf.debug → /bin/.
- `ENTRYPOINT ["/bin/entrypoint.sh"]`; `CMD ["exim", "-bd", "-q15m", "-v"]`. No USER (root).

## entrypoint.sh (flow)
1. `file_env` for GMAIL_USER, GMAIL_PASSWORD, SES_USER, SES_PASSWORD, SMARTHOST_USER, SMARTHOST_PASSWORD (also `*_FILE` variants).
2. Writes `/etc/exim4/exim4.conf.localmacros` (empty first). If MAILNAME: `MAIN_HARDCODE_PRIMARY_HOSTNAME`, writes `/etc/mailname`.
3. SMTPPORTOUT: awk rewrites `/etc/exim4/exim4.conf.template` remote_smtp driver port.
4. TLS: if KEY_PATH and CERTIFICATE_PATH non-empty files: copies to `/etc/exim4/exim.key`, `exim.crt` (chgrp Debian-exim, mode 640), `MAIN_TLS_ENABLE = yes`; else TLS disabled.
5. DKIM: if DKIM_KEY_PATH non-empty: copies to `/etc/exim4/dkim.key`; writes DKIM macros with DKIM_SELECTOR (default dkim).
6. Builds opts: `dc_local_interfaces "[BIND_IP]:PORT ; [BIND_IP6]:PORT"`, `dc_other_hostnames OTHER_HOSTNAMES`, `dc_relay_nets` from `ip addr show dev ${NET_DEV:-eth0}` + RELAY_NETWORKS.
7. DISABLE_IPV6 (any non-empty) → `disable_ipv6=true`.
8. Mode precedence: GMAIL_USER+GMAIL_PASSWORD (smtp.gmail.com::587) > SES_USER+SES_PASSWORD (email-smtp.SES_REGION.amazonaws.com::SES_PORT, defaults us-east-1 / 587) > SMARTHOST_ADDRESS (`${SMARTHOST_ADDRESS}::${SMARTHOST_PORT-25}`) > RELAY_DOMAINS (internet config) > internet.
9. Writes `/etc/exim4/passwd.client` for gmail/ses/aliases.
10. `_docker_additional_macros` appended if present; USE_SPLIT_CONFIG=true → `dc_use_split_config`.
11. `/bin/set-exim4-update-conf "${opts[@]}"`; then `exec "$@"`.

## Env vars (README + entrypoint)
| Name | Default / notes |
| --- | --- |
| PORT | 25 (image ENV) |
| BIND_IP / BIND_IP6 | 0.0.0.0 / ::0 |
| DISABLE_IPV6 | any value disables IPv6 |
| RELAY_NETWORKS | must begin with `:` (appended to detected nets) |
| RELAY_DOMAINS | relay domains |
| MAILNAME | sets primary hostname and /etc/mailname |
| OTHER_HOSTNAMES | other hostnames |
| NET_DEV | eth0 |
| SMTPPORTOUT | outbound port rewrite |
| KEY_PATH, CERTIFICATE_PATH | TLS key and cert files |
| DKIM_KEY_PATH, DKIM_SELECTOR | DKIM key file, selector (dkim) |
| USE_SPLIT_CONFIG | false |
| GMAIL_USER, GMAIL_PASSWORD | Gmail smarthost |
| SES_USER, SES_PASSWORD, SES_REGION (us-east-1), SES_PORT (587) | Amazon SES |
| SMARTHOST_ADDRESS, SMARTHOST_PORT (25), SMARTHOST_USER, SMARTHOST_PASSWORD, SMARTHOST_ALIASES | generic smarthost; aliases semicolon-separated |

## Paths written by upstream entrypoint (root required)
- /etc/exim4/exim4.conf.localmacros, /etc/exim4/exim4.conf.template, /etc/mailname, /etc/exim4/exim.key, exim.crt, dkim.key, passwd.client.

## Ports
- 25 (EXPOSE ${PORT}).
