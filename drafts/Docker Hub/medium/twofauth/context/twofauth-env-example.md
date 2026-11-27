# 2FAuth .env.example (tag v9.0.3)

Source URL(s): https://raw.githubusercontent.com/Bubka/2FAuth/v9.0.3/.env.example (fetched 2026-11-27; API contents endpoint 403)

## Keys (defaults in file)
| Key | Default |
| --- | --- |
| APP_NAME | 2FAuth |
| APP_ENV | local |
| APP_KEY | (empty; must be set) |
| APP_URL | http://localhost |
| APP_SUBDIRECTORY | (empty) |
| APP_DEBUG | false |
| SITE_OWNER | mail@example.com |
| LOG_CHANNEL / LOG_LEVEL | daily / notice |
| CACHE_DRIVER / SESSION_DRIVER | file / file |
| DB_CONNECTION, DB_DATABASE, DB_HOST, DB_PORT, DB_USERNAME, DB_PASSWORD | empty |
| MAIL_MAILER | log |
| MAIL_HOST / MAIL_PORT | smtp.mailtrap.io / 2525 |
| AUTHENTICATION_GUARD | web-guard |
| AUTH_PROXY_HEADER_FOR_USER / _FOR_EMAIL, PROXY_LOGOUT_URL | null |
| WEBAUTHN_NAME / WEBAUTHN_USER_VERIFICATION | 2FAuth / preferred |
| TRUSTED_PROXIES | null |
| THROTTLE_API / LOGIN_THROTTLE | 60 / 5 |
| REDIS_HOST / REDIS_PORT / REDIS_PASSWORD | 127.0.0.1 / 6379 / null |
| QUEUE_DRIVER / BROADCAST_DRIVER | sync / log |

## Gotchas
- Image's Dockerfile ENV sets DB_CONNECTION=sqlite, but .env.example leaves it empty.
- Note values `null` are literal strings in .env style files.
