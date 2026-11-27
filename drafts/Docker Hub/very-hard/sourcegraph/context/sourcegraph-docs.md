# Sourcegraph docs (sourcegraph.com/docs)

## Source URL(s) + date
- https://sourcegraph.com/docs (2026-11-27, HTTP 200). Landing/index only.
- Failures: https://github.com/sourcegraph/sourcegraph (HTTP 404). One alternative tried: https://raw.githubusercontent.com/sourcegraph/sourcegraph/main/README.md (HTTP 404). Not retried.

## What it is
- Sourcegraph documentation index. Sections: Code Intelligence (Deep Search, Code Search, Code Navigation, Cody), code management (Batch Changes, Code Insights, Code Monitoring), developer tools (MCP Server, CLI, Integrations, API), Deploy & administer (Administration, Sourcegraph Cloud, Self-hosted).
- Page is an index; no install, env, port or volume details captured.

## Gotchas
- Self-hosted install docs are under "Deploy & administer > Self-hosted" (sub-pages not followed; budget).
- No public Dockerfile found: the GitHub repo URL returns 404 from this environment.
