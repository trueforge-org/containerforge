# benweet/stackedit (upstream repo README + release v5.14.0)

Source URL(s): https://github.com/benweet/stackedit (and .git variant, same repo); raw README https://raw.githubusercontent.com/benweet/stackedit/master/README.md; https://api.github.com/repos/benweet/stackedit/releases/tags/v5.14.0 (fetched 2026-11-26)

## What it is
- Open-source Markdown editor based on PageDown (Stack Overflow's Markdown lib). Browser app.
- npm package `stackedit`.
- Repo has no Dockerfile in its README; image build is not documented here.

## Build steps (from README)
- `npm install`
- `npm start` (dev server localhost:8080, hot reload)
- `npm run build` (production, minified); `npm run build --report` (bundle analyzer)

## Deploy
- README documents Helm chart at https://benweet.github.io/stackedit-charts/ (not fetched). Helm values include Dropbox/Google/GitHub/WordPress OAuth client ids/secrets (external service keys; not container facts).

## Release v5.14.0
- tag_name `v5.14.0`, name empty, published 2019-07-02T14:06:21Z
- No release assets returned.

## Version/asset naming
- Git tags `vX.Y.Z`; npm package name `stackedit`.

## Gotchas
- Release is from 2019; README uses Travis CI badges (stale).
- Static SPA: runs client-side; any server is just static file serving (inference, not stated in sources).
