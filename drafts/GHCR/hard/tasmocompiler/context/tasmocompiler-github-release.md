# TasmoCompiler releases
- https://api.github.com/repos/benzino77/tasmocompiler/releases/tags/v14.0.3: HTTP 403 (failed, not retried)
- Alternative used: `HEAD https://github.com/benzino77/tasmocompiler/releases/tag/v14.0.3` -> 200 (tag page exists)
- `HEAD https://github.com/benzino77/tasmocompiler/releases/latest` -> Location .../releases/tag/v14.0.3 (v14.0.3 is latest)
- Asset names not retrieved (API blocked)
- Chart appVersion is `latest`, image tag `latest@sha256:...` (digest pinned)
