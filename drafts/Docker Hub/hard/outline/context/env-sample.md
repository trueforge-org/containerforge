# Environment variables (.env.sample)

Source URL: https://raw.githubusercontent.com/outline/outline/main/.env.sample (fetched)

## General
| Var | Sample | Note |
| --- | --- | --- |
| NODE_ENV | production | runtime mode |
| URL | (empty) | public FQDN; use proxy address if proxied |
| PORT | 3000 | server port; match compose |
| COLLABORATION_URL | (empty) | only for separate collab server |
| CDN_URL | (empty) | CDN origin should equal URL |
| WEB_CONCURRENCY | 1 | ~ memory MB / 512 |
| SECRET_KEY | generate_a_new_key | hex 32 bytes (`openssl rand -hex 32`) |
| UTILS_SECRET | generate_a_new_key | unique random key |
| DEFAULT_LANGUAGE | en_US | default UI language |

Any var can be supplied via `<VAR>_FILE` pointing to a file (trimmed; direct var wins if both set).

## Database
| DATABASE_URL | postgres://user:pass@postgres:5432/outline | production Postgres URL |
| DATABASE_CONNECTION_POOL_MIN | (empty) | default 0 |
| DATABASE_CONNECTION_POOL_MAX | (empty) | default 5, min 2 |
| PGSSLMODE | disable (commented) | uncomment if not using SSL |

## Redis
| REDIS_URL | redis://redis:6379 | ioredis URL or base64 config object |
| REDIS_COLLABORATION_URL | (empty) | needed to scale collaboration |

## File storage
| FILE_STORAGE | local | `s3` or `local` |
| FILE_STORAGE_LOCAL_ROOT_DIR | /var/lib/outline/data | must be writable |
| FILE_STORAGE_UPLOAD_MAX_SIZE | 262144000 | attachment max |
| FILE_STORAGE_IMPORT_MAX_SIZE | (empty) | document import max |
| FILE_STORAGE_WORKSPACE_IMPORT_MAX_SIZE | (empty) | workspace import max |
| AWS_ACCESS_KEY_ID / AWS_SECRET_ACCESS_KEY / AWS_REGION | placeholders | S3 creds (when s3) |
| AWS_S3_UPLOAD_BUCKET_URL / AWS_S3_UPLOAD_BUCKET_NAME | http://s3:4569 / bucket_name_here | S3 endpoint/bucket |
| AWS_S3_FORCE_PATH_STYLE | true | path-style |
| AWS_S3_ACL | private | object ACL |
| AWS_S3_UPLOAD_METHOD | post | `post` or `put` (R2 uses put) |
| AWS_CLOUDFRONT_URL / _KEY_PAIR_ID / _PRIVATE_KEY | (empty) | optional signed download CDN |

## SSL / proxy
| SSL_KEY / SSL_CERT | (empty) | base64 key/cert for HTTPS termination |
| FORCE_HTTPS | true | set false if LB terminates SSL |
| PROXY_IP_HEADER | (commented) | default X-Forwarded-For; alt X-Real-IP, X-Client-IP |
| PROXY_HEADERS_TRUSTED | true (commented) | false if no proxy in prod |

## Auth (at least one provider required)
| SLACK_CLIENT_ID / SLACK_CLIENT_SECRET | | Slack |
| GOOGLE_CLIENT_ID / GOOGLE_CLIENT_SECRET | | Google |
| AZURE_CLIENT_ID / AZURE_CLIENT_SECRET / AZURE_RESOURCE_APP_ID | | Entra/Azure AD |
| DISCORD_CLIENT_ID / _SECRET / DISCORD_SERVER_ID / DISCORD_SERVER_ROLES | | Discord |
| OIDC_CLIENT_ID / OIDC_CLIENT_SECRET | | generic OIDC |
| OIDC_AUTH_URI / OIDC_TOKEN_URI / OIDC_USERINFO_URI / OIDC_LOGOUT_URI | | OIDC endpoints |
| OIDC_USERNAME_CLAIM | preferred_username | JWT claim path |
| OIDC_DISPLAY_NAME | OpenID Connect | login label |
| OIDC_SCOPES | openid profile email | space-separated |

## Email
| SMTP_SERVICE | (empty) | nodemailer well-known service |
| SMTP_USERNAME / SMTP_PASSWORD / SMTP_FROM_EMAIL | (empty) | SMTP |

## Rate limiter
| RATE_LIMITER_ENABLED | true | master switch |
| RATE_LIMITER_REQUESTS | 1000 | global cap |
| RATE_LIMITER_DURATION_WINDOW | 60 | seconds |
| RATE_LIMITER_MULTIPLIER | 1 | scales per-endpoint limits |

## Integrations (optional)
GitHub, GitLab, Linear, Figma, Dropbox (DROPBOX_APP_KEY), Notion (NOTION_CLIENT_ID/SECRET), IFRAMELY_URL / IFRAMELY_API_KEY, SLACK_VERIFICATION_TOKEN / SLACK_APP_ID / SLACK_MESSAGE_ACTIONS, SENTRY_DSN / SENTRY_TUNNEL.

## Debug
| ENABLE_UPDATES | true | anonymized update checks |
| DEBUG | http | debug categories |
| LOG_LEVEL | info | error..silly |
