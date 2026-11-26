# khlieng/dispatch config.default.toml (tag v0.7)

Source URL(s) + fetch date:
- https://raw.githubusercontent.com/khlieng/dispatch/v0.7/config.default.toml (followed from plan.md; not in draft) · 2026-11-26

## Contents (values as given)
Top level:
- `address = ""` (empty means all interfaces)
- `port = 80`
- `hexIP = false`
- `verify_certificates = true`

`[defaults]` (prefills connect form): name `freenode`, host `chat.freenode.net`, port 6697, channels `["#dispatch", "#go-nuts"]`, password `""`, ssl true, readonly false, show_details false.

`[https]`: `enabled = true`, `port = 443`, `cert = ""`, `key = ""`.

`[letsencrypt]`: `domain = ""`, `email = ""`.

`[auth]` (marked not implemented): `anonymous = true`, `login = true`, `registration = true`.

`[auth.providers.github|facebook|google|twitter]`: key and secret empty.

`[https.hsts]`: enabled false, max_age 31536000, include_subdomains false, preload false.

`[headers]`: no active entries (commented example `X-Example = "Rainbows"`).

## Notes vs plan.md
- Matches plan.md section 1 for `address`, `port`, `[https]`, `[auth]`.
- The `[defaults]` block points to freenode and `chat.freenode.net`. plan.md's start.sh/defaults plan keeps upstream defaults, so this would be seeded as-is.
- `[https] enabled = true` is the upstream default, which plan.md changes to false in `defaults/config.toml`.
- `[letsencrypt]` section exists; plan says the Let's Encrypt cache goes under `/config` if enabled.
