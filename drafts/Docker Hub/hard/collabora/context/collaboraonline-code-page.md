# collaboraonline.com/code/ (CODE edition page) and collaboraonline.com home

Source URL(s) + fetch date:
- https://www.collaboraonline.com/code/ (draft's "binary" link is https://www.collaboraonline.com/code/) · fetched 2026-11-26
- https://collaboraonline.com (draft "Website") · fetched 2026-11-26
- https://www.collaboraoffice.com/code/docker/ returned 301 to www.collaboraonline.com//code/docker/ and then to https://www.collaboraonline.com/code/docker/ (see collaboraonline-code-docker.md)

## CODE = development edition
- Collabora Online Development Edition (CODE): "perfect for testing, home use or small teams, but **not recommended for production environments**". Rolling release, builds roughly monthly; built on the Collabora Office core. Free to test, early access features. Stable product is Collabora Online, sold separately.
- Office formats: Writer (.odt .docx .doc .pdf .rtf), Calc (.ods .xlsx .xls .xlsm .csv), Impress (.odp .ppt .pptx), Draw (.odg .vsd .vsdx).
- No version number on the page (screenshot file name mentions CODE-25.04, not a current-version statement).

## Install methods
- Docker image `collabora/code` on Docker Hub.
- Native deb: import keyring to `/etc/apt/keyrings`, create `/etc/apt/sources.list.d/collaboraonline.sources`, then `coolwsd` and `code-brand`. Minimal install without localisations; install `collaboraoffice*` packages for the full set.
- Native rpm (`coolwsd`, `CODE-brand`; amd64 only).
- Config: `/etc/coolwsd/coolwsd.xml`. Service: `systemctl restart coolwsd`; logs: `journalctl -u coolwsd`.

## Architectures
- Docker: x86-64, ppc64, arm64.
- deb: amd64, ppc64, arm64. rpm: amd64 only.

## Port
9980 is used in every example (`http://<ip>:9980`, `https://collabora:9980`). Not labelled as default.

## TLS
Default package config looks for an SSL cert and key that are not present. Suggests disabling SSL, optionally enabling SSL termination, and using a reverse proxy (Apache2/Nginx guides; Let's Encrypt recommended).

## WOPI / integration
- No aliasgroup setting on this page. The WOPI URL is the Collabora server address (e.g. https://collabora.example.com) entered in the file sync/share solution.
- Seafile example: `OFFICE_WEB_APP_BASE_URL = 'http://collabora:9980/hosting/discovery'`.
- Nextcloud: Administration settings > Nextcloud Office. ownCloud: integration app settings. HumHub: base URL.

## Licence / offering
- Licence not stated. Product built on LibreOffice; "Truly Open Source" wording; codebase auditable.
- Collabora Online subscription has pricing and SLA; no terms for CODE.

## Gotchas
- CODE is not recommended for production, which the plan does not state.
