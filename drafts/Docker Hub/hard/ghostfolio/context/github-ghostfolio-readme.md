# ghostfolio README (container-relevant facts)

Source URL: https://raw.githubusercontent.com/ghostfolio/ghostfolio/main/README.md
Date fetched: 2026-11-26

## What it is
Open source wealth management web app (stocks, ETFs, crypto). TypeScript, Nx workspace. Backend NestJS + Prisma, frontend Angular. License AGPLv3.

## Required services
- PostgreSQL (via Prisma)
- Redis
- Schema migrations run automatically at container start.

## Images and platforms
- Image: `ghostfolio/ghostfolio` (Docker Hub)
- Arch: linux/amd64, linux/arm/v7, linux/arm64
- Default port: 3333

## Compose files (repo)
- `docker/docker-compose.yml` (prebuilt image)
- `docker/docker-compose.build.yml` (local build)
- Setup: copy `.env.example` to `.env`. First user created via "Get Started" gets role `ADMIN`.
- No standalone `docker run` example on this page.

## Env vars: core
| Name | Type | Default | Purpose |
| --- | --- | --- | --- |
| ACCESS_TOKEN_SALT | string | - | Salt for access tokens |
| API_KEY_COINGECKO_DEMO | string, opt | - | CoinGecko demo key |
| API_KEY_COINGECKO_PRO | string, opt | - | CoinGecko pro key |
| DATABASE_URL | string | - | Postgres URL (pooled URL if a pooler is used) |
| DIRECT_URL | string, opt | falls back to DATABASE_URL | Direct URL for Prisma CLI migrations/seed |
| ENABLE_FEATURE_AUTH_TOKEN | bool, opt | true | Auth via security token |
| ENABLE_FEATURE_MCP | bool, opt | false | MCP server at /mcp (experimental) |
| ENABLE_FEATURE_SECURITY_HEADERS | bool, opt | false | CSP, X-Frame-Options etc. (experimental). HSTS not set; configure in reverse proxy |
| HOST | string, opt | 0.0.0.0 | Bind host |
| JWT_SECRET_KEY | string | - | JWT signing secret |
| LOG_LEVELS | string[], opt | - | e.g. ["debug","error","log","warn"] |
| PORT | number, opt | 3333 | Listen port |
| POSTGRES_DB | string | - | DB name |
| POSTGRES_PASSWORD | string | - | DB password |
| POSTGRES_USER | string | - | DB user |
| REDIS_DB | number, opt | 0 | Redis DB index |
| REDIS_HOST | string | - | Redis host |
| REDIS_PASSWORD | string | - | Redis password |
| REDIS_PORT | number | - | Redis port |
| REDIS_TLS | bool, opt | false | TLS to Redis |
| REQUEST_TIMEOUT | number, opt | 3000 | ms timeout for data provider requests |
| ROOT_URL | string, opt | http://0.0.0.0:3333 | Public root URL (callbacks, MCP host check) |
| TRUST_PROXY | string, opt | - | Express trust proxy (e.g. 1) for rate limiting client IP |

## Env vars: OIDC (experimental)
| Name | Default | Purpose |
| --- | --- | --- |
| ENABLE_FEATURE_AUTH_OIDC | false | Enable OIDC |
| OIDC_AUTHORIZATION_URL | - | Override auth endpoint |
| OIDC_CALLBACK_URL | ${ROOT_URL}/api/auth/oidc/callback | Callback |
| OIDC_CLIENT_ID | - | Client ID |
| OIDC_CLIENT_SECRET | - | Client secret |
| OIDC_ISSUER | - | Issuer; discovery via /.well-known/openid-configuration |
| OIDC_SCOPE | ["openid"] | Scopes |
| OIDC_TOKEN_URL | - | Override token endpoint |
| OIDC_USER_INFO_URL | - | Override userinfo endpoint |

## Health endpoints
- `GET /api/v1/health`: checks DB and Redis, returns 200 `{"status":"OK"}`. Redis check can take up to 5 s, so probe timeout >= 5 s. No token.
- `GET /api/v1/health/liveness`: no dependency checks. Suited for liveness/startup probes. No token.

## MCP (if enabled)
- Requires ENABLE_FEATURE_MCP=true and ROOT_URL set to public URL. Reverse proxy must forward Host header. Endpoint `POST <ROOT_URL>/mcp` with Bearer token.
