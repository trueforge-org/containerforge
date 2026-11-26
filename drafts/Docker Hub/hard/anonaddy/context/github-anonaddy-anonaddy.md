# anonaddy/anonaddy (upstream application source)

**Source URL(s) + fetch date:** https://github.com/anonaddy/anonaddy (raw `master/README.md`; raw `v1.7.4/composer.json`; https://github.com/anonaddy/anonaddy/releases/tag/v1.7.4; source archive `https://github.com/anonaddy/anonaddy/archive/refs/tags/v${VERSION}.tar.gz` recorded, not downloaded) · fetched 2026-11-26

## What it is
addy.io (formerly AnonAddy): open-source anonymous email forwarding. Aliases forward to a real inbox and replies go out from the alias. Features: GPG/OpenPGP encryption, custom domains, multiple recipients per alias.

## Install/build steps and build deps
- Source-only release. No prebuilt binary. Archive is arch-independent PHP.
- `composer install --no-dev --optimize-autoloader` (composer.json `"require"` php `^8.3`).
- Frontend: `npm ci` then `npm run production` (vite build), as in the wrapper Dockerfile.
- Wrapper fetches tag `v${ANONADDY_VERSION}` via git shallow clone.

## Runtime deps (per README, Self-hosting requirements)
- PHP 8.2+ with `mailparse`; `gnupg` for encryption; `imagick` for 2FA QR codes.
- Redis 7.x+ (throttling and queues).
- MariaDB or MySQL.
- Nginx and Rspamd; Postfix 3.0.0+ with `postfix-mysql` and `postfix-pcre` (Postfix pipes incoming mail to the app).
- Port 25 open, FQDN hostname, MX/SPF/DKIM/DMARC DNS, reverse DNS, TLS certificate.

Note: composer.json lists no `ext-*` requirements (checked in raw composer.json at v1.7.4).

## Binaries/entrypoint/CLI flags
Not applicable (Laravel application).

## Config files and formats
Laravel `.env` (wrapper stores it under `/data/.env`). `SELF-HOSTING.md` in the repo (not fetched).

## Version/release info and asset naming
- Latest release `v1.7.4`, marked Latest, commit `0315a78` (GitHub signature verified), dated 29 Oct (year not shown). Master has 2 commits since.
- Source archive: `https://github.com/anonaddy/anonaddy/archive/refs/tags/v${VERSION}.tar.gz`. Naming pattern: `v<semver>.tar.gz` with `archive/refs/tags/` prefix.
- Release page reports 2 assets but the list did not load; names unknown.

## Release notes highlights (1.7.4)
- Rules: webhook action (signed JSON POST on accepted mail; body and headers optional, 1 MB each; five failed deliveries pause the URL for an hour).
- Aliases: random characters can be appended to custom aliases.
- Security: password reset signs out other sessions and deletes API keys; browser API requests need 2FA when enabled; API login restricted to permitted usernames; API 2FA attempts limited.
- Mail: malformed inbound From headers repaired; multi-From mail temporarily rejected; inbound errors ask Postfix to retry.

## Licence
`AGPL-3.0-or-later` (composer.json `license` field; README says GNU AGPL v3.0).

## Ports / Volumes / Users
Not applicable at source level; see wrapper summary (`github-anonaddy-docker.md`).

## Healthcheck/readiness endpoints
None in fetched text.

## Arch support
Not applicable (PHP source). Packaging deps are per-distro.

## Gotchas
- Self-hosting is documented as a manual Postfix setup; the wrapper handles the mail stack.
- Docs site: https://addy.io/help/ is a user help index (see `addy-io-help.md`).

## Contradictions with plan.md
- plan.md section 1: `composer.json` `php ^8.3` and licence `AGPL-3.0-or-later`: confirmed.
- plan.md section 1: tag `v1.7.4` and commit `0315a78...`: confirmed (commit prefix matches).
- plan.md section 1 says the wrapper `anonaddy/docker` is MIT: not confirmed in fetched text.
