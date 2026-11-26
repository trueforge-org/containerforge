# distribution docs home (distribution.github.io/distribution)

Source URL(s) + fetch date:
- https://distribution.github.io/distribution/ · 2026-11-26

## Facts
- "a stateless, highly scalable server side application" implementing OCI Distribution Spec 1.0.1. Apache 2.0.
- Only install shown: `docker run -d -p 5000:5000 --name registry registry:3`; then tag/push/pull on `localhost:5000`.
- Links: deploying (`/about/deploying/`), configuration (`/about/configuration/`), garbage collection, insecure registries, notifications, storage drivers (filesystem, GCS, in-memory, Azure, S3), API v2 spec (`/spec/api/`, link only).
- Default port not stated (5000 used in examples).
