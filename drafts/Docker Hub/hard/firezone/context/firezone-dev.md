# firezone.dev (website and knowledge base)

Source URL(s) + fetch date:
- https://www.firezone.dev (fetched 2026-11-26)
- https://www.firezone.dev/kb (fetched 2026-11-26)

## What it is

Firezone: zero-trust network access (ZTNA) product that replaces traditional VPNs. Built on WireGuard; identity via OIDC providers (Okta, Google, Entra, or any OIDC). Per-user and per-group access rules. Clients for macOS, Windows, Linux, iOS, Android, Chrome. REST API. Cloud regions US and EU. "Deploy on your own infrastructure or use managed cloud."

## Versions and license

- No version numbers on either page. No license statement; points to GitHub repo.

## Docs index (relative paths under /kb)

- Architecture: /kb/architecture
- Quickstart: /kb/quickstart
- Deploy (production setup): /kb/deploy
- Authenticate (OIDC, user and group sync): /kb/authenticate
- Maintain: /kb/maintain; Automate (Terraform): /kb/automate
- Client apps: /kb/install
- FAQ: /kb/faq; Enterprise support: /kb/support

The KB index does not mention Docker deployment, env vars or WireGuard requirements. Docker deployment docs for 0.7 are linked from the Hub page: https://docs.firezone.dev/deploy/docker/ (not fetched).

## Gotchas

- These docs describe the current 1.x product; the 0.7.36 image in the draft is documented elsewhere (Hub page, GitHub README FAQ). Not confirmed here.
