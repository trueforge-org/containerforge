# Lemur administration config (follow-up)

Source URL(s): https://lemur.readthedocs.io/en/latest/administration.html. Fetched 2026-11-26. (Page text truncated at 100000 chars; last 288 not read.)

## CFSSL plugin
| Var | Required | Default |
| --- | --- | --- |
| CFSSL_URL | yes | none (CFSSL API URL) |
| CFSSL_ROOT | yes | none (root cert, CA chain) |
| CFSSL_INTERMEDIATE | yes | none (intermediate cert) |
| CFSSL_KEY | no | none (HMAC key) |

## Basic config (selected)
- SQLALCHEMY_DATABASE_URI (Postgres), SQLALCHEMY_ENGINE_OPTIONS (pool defaults size 5, max_overflow 10)
- LEMUR_TOKEN_SECRET (JWT secret; generate random), LEMUR_TOKEN_SECRETS (rotation list), LEMUR_TOKEN_ALGORITHMS default ["HS256"], LEMUR_TOKEN_EXPIRATION default 1 (day)
- LEMUR_ENCRYPTION_KEYS: list, REQUIRED (Lemur won't start without); 32 url-safe base64 bytes each; encrypts private keys, DNS provider creds, role passwords
- LOG_LEVEL, LOG_FILE, LOG_UPGRADE_FILE, LOG_REQUEST_HEADERS (False), LOG_SANITIZE_REQUEST_HEADERS (True)
- DEBUG (never in prod), CORS (False), CUSTOM_RESPONSE_HEADERS ({})
- LEMUR_ALLOW_WEEKEND_EXPIRATION (True), LEMUR_ALLOWED_DOMAINS (regex list)
- DEFAULT_VALIDITY_DAYS (365), PUBLIC_CA_MAX_VALIDITY_DAYS (397), ALLOW_CERT_DELETION (False), ADMIN_ONLY_AUTHORITY_CREATION (True), LEMUR_STRICT_ROLE_ENFORCEMENT
- Cert defaults example: LEMUR_DEFAULT_ISSUER_PLUGIN "verisign-issuer", LEMUR_DEFAULT_AUTHORITY "verisign" (examples)
- LEMUR_AWS_REGION, LEMUR_AWS_PARTITION (aws), SENTRY_DSN, LEMUR_ENV
- No SECRET_KEY option documented in this content.
