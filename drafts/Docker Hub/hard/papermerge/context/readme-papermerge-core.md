# papermerge-core README (master)

Source URL: https://raw.githubusercontent.com/papermerge/papermerge-core/master/README.md (fetched)

- What: open-source self-hosted DMS for scanned documents; OCR, full-text search, tags, folders, versioning, custom fields per type, multi-user/groups, multilingual UI.
- Supported formats: PDF, TIFF, JPEG, PNG.
- License: not stated on page.
- Stack: Python/Django versions not stated; PostgreSQL for dev; OpenAPI REST API; `uv` for CLI.
- Docker in README: `docker run -p 8000:80 -e PAPERMERGE__SECURITY__SECRET_KEY=abc -e PAPERMERGE__AUTH__PASSWORD=123 papermerge/papermerge:3.5.3`
- Source build: see CONTRIBUTING.md (PostgreSQL, env vars, `uv run pm search build`, pre-commit).
- Links: docs.papermerge.io/latest, GitHub issues/discussions, papermerge.com (SaaS).
