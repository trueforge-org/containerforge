# autobrr.com (homepage, introduction, Docker install)
Source URL(s): https://autobrr.com (fetched), https://autobrr.com/introduction (fetched), https://autobrr.com/installation/docker (fetched, 200)

## Overview
- Torrent announce/RSS automation; connects to IRC announce channels, filters releases, pushes to download client
- Docs version: Latest

## Docker install (docs)
- Image `ghcr.io/autobrr/autobrr:latest` (docs compose example)
- Compose example: `user: 1000:1000`, `TZ` env, volume `<data>/autobrr/config:/config`, port `7474:7474`, optional logging
- Env overrides (AUTOBRR__ prefix, all `_FILE` variants accepted for Docker secrets):
  - AUTOBRR__HOST, AUTOBRR__PORT, AUTOBRR__BASE_URL, AUTOBRR__BASE_URL_MODE_LEGACY
  - AUTOBRR__LOG_LEVEL, AUTOBRR__LOG_PATH, AUTOBRR__LOG_MAX_SIZE, AUTOBRR__LOG_MAX_BACKUPS
  - AUTOBRR__SESSION_SECRET (legacy, unused since v1.66.0)
  - AUTOBRR__CUSTOM_DEFINITIONS, AUTOBRR__CHECK_FOR_UPDATES
  - AUTOBRR__DATABASE_TYPE (sqlite|postgres), AUTOBRR__DATABASE_DSN, AUTOBRR__DATABASE_MAX_BACKUPS
  - AUTOBRR__POSTGRES_HOST, _PORT, _SOCKET, _DATABASE (alias _DB), _USER, _PASS (alias _PASSWORD), _SSLMODE, _EXTRA_PARAMS
  - AUTOBRR__CORS_ALLOWED_ORIGINS, AUTOBRR__PROFILING_ENABLED/_HOST/_PORT
  - AUTOBRR__OIDC_* (ENABLED, ISSUER, CLIENT_ID, CLIENT_SECRET, REDIRECT_URL, DISABLE_BUILT_IN_LOGIN, ALLOWED_SUBJECT, ALLOWED_EMAIL, AUTO_REDIRECT)
  - AUTOBRR__AUTH_DISABLED (+ _ACKNOWLEDGEMENT), AUTOBRR__AUTH_ALLOWED_PEER_CIDRS, AUTOBRR__AUTH_ALLOWED_HOSTS, AUTOBRR__AUTH_CLIENT_IP_HEADER, AUTOBRR__AUTH_TRUSTED_USER_HEADER, AUTOBRR__AUTH_TRUSTED_USER, AUTOBRR__AUTH_LOGOUT_URL
  - AUTOBRR__TRUSTED_PROXIES
  - AUTOBRR__METRICS_ENABLED/_HOST/_PORT/_BASIC_AUTH_USERS

## Homepage / intro
- Docs site: Introduction, Quick Start, Installation (Seedbox, Linux, Docker, MacOS, Windows), Reverse proxy, Configuration, Filters, Usage, API docs, FAQ
