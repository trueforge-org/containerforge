# GitHub: n8n-io/n8n repo and latest release

Source URL(s) + date:
- https://github.com/n8n-io/n8n (2026-11-27, HTML, mostly site navigation)
- https://api.github.com/repos/n8n-io/n8n/releases/latest: 403 (rate limit/forbidden)
- Alternative tried once: https://github.com/n8n-io/n8n/releases/latest (HTML) -> page title "Release n8n@2.49.8"

What it is: "Fair-code workflow automation platform with native AI capabilities", self-hostable, 400+ integrations.

Version/asset naming:
- Release tags are prefixed `n8n@` (e.g. `n8n@2.49.8`); strip prefix for the version.
- Latest release seen 2026-11-27: `n8n@2.49.8`. The draft plan (verified 2026-11-25) says `n8n@2.49.6`.
- No prebuilt binary release assets; distribution is npm package `n8n` plus the Docker image.
- TrueCharts chart uses `ghcr.io/n8n-io/n8n:3.4.1`, a version higher than the GitHub "latest" seen here.

Gotchas: GitHub HTML pages returned only navigation text; the release asset list was not retrieved (API 403).
