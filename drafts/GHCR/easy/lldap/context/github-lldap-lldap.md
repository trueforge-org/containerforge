# lldap/lldap (upstream v0.6.3)

## Source URL(s) + date
- https://raw.githubusercontent.com/lldap/lldap/v0.6.3/README.md
- https://raw.githubusercontent.com/lldap/lldap/v0.6.3/LICENSE
- https://api.github.com/repos/lldap/lldap/releases/latest
- Fetched 2026-11-26

## What it is
Rust LDAP-style user management/auth server with web UI. "Unsafe forbidden" in README. Upstream installation doc lives in `docs/install.md` (not fetched).

## License
GNU GPL v3 (LICENSE header).

## Version/asset naming
- Latest release (API): tag `v0.6.3`, published 2026-04-30, target `main`.
- Release asset names seen (list possibly truncated): `aarch64-lldap.tar.gz`, `amd64-lldap.tar.gz`, `armhf-lldap.tar.gz`.
- Asset URL pattern: `https://github.com/lldap/lldap/releases/download/v0.6.3/<arch>-lldap.tar.gz`.
- Arch: aarch64, amd64, armhf (others not seen in fetched portion).

## Upstream README highlights
- Frontend for user management; LDAP interface; integrates with Keycloak, Authelia, Nextcloud, etc.
- Not a full LDAP server (use OpenLDAP for that).

## Gotchas
- Release tarballs are the source for binary installs; the chart uses the upstream `-debian` image tag instead.
