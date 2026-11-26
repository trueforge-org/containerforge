# nosqlclient/nosqlclient README

**Source:** https://raw.githubusercontent.com/nosqlclient/nosqlclient/master/README.md (fetched 2026-11-26)

## What it is
- MongoDB management tool (formerly Mongoclient), cross-platform, self-hosted.
- Supports MongoDB 4.0+ only.
- Author says it is no longer actively developed; Docker builds reportedly still work.
- License: MIT before 2.0.0; AGPLv3 from 2.0.0.

## Docker (per page)
- `docker pull mongoclient/mongoclient` (latest); `mongoclient/mongoclient:4.0.0` (stable)
- `docker run -d -p 3000:3000 mongoclient/mongoclient`
- Persist: `-v <path>:/data/db`

## Config / env
- MONGO_URL: external MongoDB; if unset, a MongoDB is installed in the container.
- /data/db bind mount persists connections and settings.

## Not on page
- Node version, npm/source install, healthcheck.
