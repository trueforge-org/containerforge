# Metabase: docs home and website

**Source URL(s):** https://www.metabase.com/docs/latest/ ; https://www.metabase.com
**Fetched:** 2026-11-26

## Docs home (docs/latest)
- Metabase is "an open-source business intelligence platform": query data, or embed dashboards in other products.
- Supported databases: a Databases section exists (connecting, roles, SSH tunnelling, SSL), but the page does not list them.
- Install options: Metabase Cloud (free trial, managed), or self-hosting by JAR, Docker or Cloud. No commands on this page.
- Java version: not stated. Health endpoint: not mentioned.
- Related topics linked: upgrading, application DB configuration, backups, migrating from H2, serialization, CLI, JAR commands.

## Website (metabase.com)
- Describes Metabase as "Open source AI analytics you can verify": semantic layer of metrics, query inspection, Metabot, Data Studio, embedded analytics, data apps (beta), MCP server, CLI, APIs and Slack access.
- Editions: Starter and Open Source, Pro, Enterprise. Open source is free and self-hosted; Metabot and MCP/CLI available on every plan including open source.
- SAML, JWT, OIDC sign-in, 2FA, row/column security, and usage analytics are Pro/Enterprise features.
- Open source start page: `/start/oss`. Docker: `docker run -d -p 3000:3000 --name metabase metabase/metabase`. JAR: `java --add-opens java.base/java.nio=ALL-UNNAMED -jar metabase.jar`.
- After "Metabase Initialization Complete" appears, open `localhost:3000` to create the admin account.
- License link in footer: `/license` (not fetched; see github-metabase-metabase.md for LICENSE-AGPL.txt).
