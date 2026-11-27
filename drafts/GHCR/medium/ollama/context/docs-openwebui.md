# Open WebUI docs (docs.openwebui.com)

Source URL(s) + date:
- https://docs.openwebui.com (2026-11-27, main page: site navigation, docs index only)
- https://docs.openwebui.com/getting-started/env-configuration/ : HTTP 404
- https://docs.openwebui.com/getting-started/env-configuration : HTTP 404 (one alternative, failed)

What it is: documentation for Open WebUI ("Self-hosted AI platform"). Sections: Getting Started, Reference, Features, Ecosystem, Troubleshooting, Tutorials, FAQ, Security, Contributing, License.

Build/runtime facts: none beyond the Dockerfile and chart. The env var reference page was not reachable, so env var semantics are only what the Dockerfile sets (see github-open-webui-dockerfile.md).

Gotchas: do not invent env var names from the docs; use the Dockerfile ENV list and the chart's env list.
