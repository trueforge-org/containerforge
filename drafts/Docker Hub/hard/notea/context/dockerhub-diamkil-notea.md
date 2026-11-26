# Docker Hub: diamkil/notea

Source URL(s): https://hub.docker.com/r/diamkil/notea · fetched 2026-11-26

- Description: "Docker Image combining Notea and MinIO" (bundled S3 backend).
- Tags shown: only `latest` (digest sha256:e331f787…, truncated). Last updated about 4 years ago (page claims 15-minute rebuilds; listing does not reflect that).
- Architectures: not shown on page.
- Size: ~148 MB.
- Ports: 3000 (Notea), 9000 (MinIO, optional).
- Env: PASSWORD, STORE_USER, STORE_PASSWORD (MinIO user/password chosen by user).
- Volume: `/path/to/storage` mapped to `/data`.
- Pull: `docker pull diamkil/notea`.
