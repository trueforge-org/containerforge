# Notea (QingWei-Li/notea) README

Source URL(s): https://github.com/QingWei-Li/notea · fetched 2026-11-26 (raw master README)

## What it is
- Self-hosted Next.js note app; data stored in S3-compatible bucket (no local data dir).
- Status: deprecated, barely maintained; maintainer suggests Joplin or Logseq. PRs still merged.

## Install/build
- Upstream docs: deploy via Vercel/Netlify fork, Docker image `cinwell/notea` (`-p 3000:3000`), Helm chart in `/helm`, dev via `docker-compose up -d` then `yarn dev`.
- Node version: not stated in README.
- Bucket is NOT auto-created: create it manually before start.

## Ports
- 3000 (HTTP).

## Env vars
| Name | Default | Meaning |
|---|---|---|
| PASSWORD | none | Login password (required unless DISABLE_PASSWORD) |
| DISABLE_PASSWORD | false | Disable built-in auth; external auth needed; `/share/:id` must stay anonymous |
| STORE_ACCESS_KEY | none | S3 access key (required) |
| STORE_SECRET_KEY | none | S3 secret key (required) |
| STORE_BUCKET | none | Bucket name (required) |
| STORE_END_POINT | none | S3 host/endpoint |
| STORE_REGION | us-east-1 | Region |
| STORE_FORCE_PATH_STYLE | false | Path-style URLs (required for MinIO, Oracle, Exoscale) |
| STORE_PREFIX | '' | Key prefix |
| COOKIE_SECURE | true | Cookies only over https; set false for plain http |
| BASE_URL | none | Site domain (SEO) |
| DIRECT_RESPONSE_ATTACHMENT | false | Serve attachments directly instead of redirecting to S3 URL |

## Storage presets
- MinIO: `STORE_END_POINT=http://localhost:9000`, `STORE_FORCE_PATH_STYLE=true`.
- Any S3-compatible service works.

## Gotchas
- Non-https: set `COOKIE_SECURE=false` or login fails.
- Data lives only in S3 bucket; no local data paths.
- Roadmap (not done): offline editing, versioning, file upload.
