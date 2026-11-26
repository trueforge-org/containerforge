# diamkil/docker-notea README (third-party wrapper)

Source URL(s): https://github.com/diamkil/docker-notea (raw master README) · fetched 2026-11-26

- Single image `diamkil/notea:latest` bundling Notea and MinIO.
- Status: maintainer says "currently not supported" (vacation); PRs welcome.
- Run: container name `Notea`, detached; ports 3000 (Notea UI) and 9000 (MinIO, optional); env PASSWORD, STORE_USER, STORE_PASSWORD (user-chosen, no defaults documented); volume `/path/to/storage:/data`.
- Compose: version "3.3", service `notea`, same ports/env/volume/image.
- Not documented: start scripts / process management, bundled Notea and MinIO versions (only `latest`), other env vars.
- Gotcha: README sample has an inline `#` comment after a line-continuation backslash on the 9000 mapping; may break if pasted.
