# leenooks phpLDAPadmin wiki: Docker-Container (v2 image phpldapadmin/phpldapadmin)

Source URL: https://github.com/leenooks/phpLDAPadmin/wiki/Docker-Container (fetched, follow-up; wiki root not fetched)

## Image
- phpldapadmin/phpldapadmin (Docker Hub); tags not listed. Pull: `docker pull phpldapadmin/phpldapadmin`
- Generate key: `docker run -it --rm phpldapadmin/phpldapadmin ./artisan key:generate --show` -> base64:... value for APP_KEY

## Env vars
| Var | Default | Purpose |
| --- | --- | --- |
| APP_KEY | auto-generated each start | encrypts cookies etc.; set to persist |
| APP_TIMEZONE | UTC | timezone (logging) |
| LDAP_CACHE | false | true = internal cache |
| LDAP_HOST | required, undefined | LDAP server host/IP |
| LDAP_USERNAME / LDAP_PASSWORD | anonymous bind if unset | used for schema and DN lookup |
| CACHE_DRIVER | file | or memcached |
| MEMCACHED_HOST / MEMCACHED_PORT | undefined / 11211 | memcached |
| SERVER_NAME | :8080 | frankenphp listen address |

## Ports / user
- Container 8080 by default (frankenphp, non-root). Map e.g. -p 80:8080. No built-in HTTPS; terminate TLS at proxy.
- UID not given.

## Volumes (optional)
- /app/storage/framework/sessions (sessions)
- /app/storage/logs (debug log)

## Notes
- No complete run or compose example on page. Config Variables wiki page separate (not fetched).
- Attribute login (e.g. mail) must be findable via the bind query.
