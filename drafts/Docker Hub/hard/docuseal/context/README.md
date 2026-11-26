# docuseal context index

Fetched 2026-11-26. Summaries of every web source referenced by draft.md and plan.md.

## Sources

| Source URL | Summary file |
| --- | --- |
| https://github.com/docusealco/docuseal | github-docusealco-docuseal.md |
| https://github.com/docusealco/docuseal/blob/a628dd30daafde9f2e7b9ef161a3a9b7c6f4d9fc/Dockerfile (fetched as raw) | github-docusealco-docuseal.md (Dockerfile section, 3.3.8) |
| https://github.com/docusealco/docuseal/releases/tag/3.4.0 | github-docusealco-docuseal.md (release section) |
| https://github.com/docusealco/docuseal/releases/tag/3.3.8 | github-docusealco-docuseal.md (release section) |
| https://github.com/docusealco/docuseal (LICENSE, plus 3.4.0 Dockerfile read as a plan reference) | github-docusealco-docuseal.md |
| https://www.docuseal.com | docs-docuseal-com.md |
| https://www.docuseal.com/docs/embedded | docs-docuseal-com-embedded.md |
| https://hub.docker.com/r/docuseal/docuseal | dockerhub-docuseal-docuseal.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/docuseal | truecharts-docuseal.md (directory not fetched; values.yaml fetched via raw URL) |

## Skipped URLs

| URL | Reason |
| --- | --- |
| https://cla-assistant.io/trueforge-org/containerforge | CLA link (not a source) |
| https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json | forgetool schema URL |
| https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json | forgetool schema URL |
| https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu | containerforge apps/<base> link |
| http://0.0.0.0:3000 | contains 0.0.0.0 (local address) |
| https://github.com/docusealco/docuseal/archive/refs/tags/${VERSION}.tar.gz | contains `${` (template; tarball pattern recorded) |

## Fetch failures and partial content

- Release pages 3.3.8 and 3.4.0: fetched, but the asset lists did not load ("2 assets" shown, names not given).
- Docker Hub page: architecture list not shown on the page.
- Not fetched: `fields-detection` model, pdfium-binaries and noto/dancing fonts (these are downloads used by the Dockerfile; checksums recorded only for pdfium), and `LICENSE_ADDITIONAL_TERMS` (named in the Dockerfile and README, not fetched).

## plan.md corrections

- Section 1, License row: "UNVERIFIED the exact text" about the Section 7 notice -> README states "AGPLv3 License with Section 7(b) Additional Terms" and the repo has `LICENSE_ADDITIONAL_TERMS`. Bare SPDX `AGPL-3.0-only` may not capture it. Source: github-docusealco-docuseal.md.
- Section 6, settings sentence on `DATABASE_URL` and SQLite: UNVERIFIED -> confirmed by README ("by default the container uses SQLite"; `DATABASE_URL` selects PostgreSQL or MySQL). Source: github-docusealco-docuseal.md, dockerhub-docuseal-docuseal.md.
- Section 1, Upstream Dockerfile row: "The 3.4.0 Dockerfile was not re-read" -> re-read 2026-11-26, same three-stage layout and ENV/CMD. Source: github-docusealco-docuseal.md.

## plan.md unverified (not edited)

- Section 1, Downloads row: "No binary release assets (expanded assets list empty)". Both release pages say "2 assets", but names did not load, so the empty-list claim is not confirmed. Source: github-docusealco-docuseal.md.
- Section 1: "glibc build is needed on Ubuntu" for pdfium. Upstream pins only the musl build (`pdfium-musl-$(uname -m).zip`); a glibc source was not found. Source: github-docusealco-docuseal.md.
- Section 6: `SECRET_KEY_BASE` not mentioned by any fetched source. Source: none.
- Draft "Container" field: `docuseal/docuseal:3.3.8`; the TrueCharts chart already uses 3.4.0 (`@sha256:b664cc8...`). Source: truecharts-docuseal.md. Draft not edited.
