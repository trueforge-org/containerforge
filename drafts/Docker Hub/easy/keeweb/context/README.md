# keeweb: context sources

Fetched 2026-11-26. Summaries for every web source referenced by `draft.md` and `plan.md`.

## Sources

| Source URL | File |
| --- | --- |
| https://github.com/keeweb/keeweb (+ releases, releases/latest, raw Dockerfile, LICENSE and README at v1.18.7) | github-keeweb-keeweb.md |
| https://raw.githubusercontent.com/keeweb/keeweb/v1.18.7/package/docker/Dockerfile (blob link in draft/plan) | github-keeweb-keeweb.md |
| https://raw.githubusercontent.com/keeweb/keeweb/v1.18.7/LICENSE | github-keeweb-keeweb.md |
| https://hub.docker.com/r/antelle/keeweb | dockerhub-antelle-keeweb.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/keeweb (Chart.yaml and values.yaml via raw) | truecharts-keeweb.md |

## Skipped

| URL | Reason |
| --- | --- |
| https://cla-assistant.io/trueforge-org/containerforge | CLA page, skipped by rule |
| https://github.com/trueforge-org/containerforge/tree/main/apps/nginx | containerforge base link, skipped by rule |
| https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu (x2) | containerforge base link, skipped by rule |
| https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json | forgetool schema, skipped by rule |
| https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json | forgetool schema, skipped by rule |
| https://github.com/keeweb/keeweb/releases/download/v1.18.7/KeeWeb-1.18.7.html.zip | direct release download. Asset pattern recorded in github-keeweb-keeweb.md |
| https://github.com/keeweb/keeweb/releases/download/v1.18.7/KeeWeb-1.18.7.linux.x64.deb | direct release download (draft amd64 link, wrong for web container per plan) |
| https://github.com/keeweb/keeweb/releases/download/v1.18.7/KeeWeb-1.18.7.win.arm64.zip | direct release download (draft arm64 link, wrong for web container per plan) |
| https://github.com/keeweb/keeweb/releases/download/v${VERSION}/KeeWeb-${VERSION}.html.zip and `.../Verify.sha256` | templated release download |
| https://raw.githubusercontent.com/keeweb/keeweb/v${VERSION}/LICENSE | templated form of the LICENSE fetched at v1.18.7 (same file, already summarised) |
| http://<container-ip> | placeholder address, not a source |

Named but not fetched: `keeweb-plugins` (upstream Dockerfile downloads its `master.zip`; archive download, skipped), `nginx:stable` base image (upstream), Dropbox/GDrive wiki (README link, not referenced in draft/plan).

## Fetch failures

- https://github.com/keeweb/keeweb/releases: first attempt failed with a DNS error (`getaddrinfo EAI_AGAIN github.com`). Retried once, succeeded. Not a 403/404.
- https://github.com/keeweb/keeweb/releases/latest: asset list did not load (`Assets 18` shown, names not listed). Tag and date loaded.

## plan.md corrections

No edits made. Nothing in the fetched sources clearly contradicts a plan fact that can be corrected in place. The contradictions below are unverified.

Unverified (not edited):
- plan.md section 1 (Version row): "`v1.18.8` ... has no assets." The releases page summary lists 2 assets for v1.18.8 (names not shown). Source: github-keeweb-keeweb.md.
- plan.md section 1 (Version row): "`v1.18.8` and `v1.18.9` (2026-05)". Releases page shows 30 Apr and 08 May, year not shown. Source: github-keeweb-keeweb.md.
- plan.md section 1 (Version row): "Docker Hub `antelle/keeweb:latest` was last pushed 2021-07-18". Docker Hub shows only "over 5 years ago" with no exact date. Source: dockerhub-antelle-keeweb.md.
- plan.md section 1 (License row): "GitHub reports `NOASSERTION` only because of the file header." Not checked (repo page did not name a license type).
- plan.md section 1 (Ports row): "PORT_HTTP/PORT_HTTPS belong to the keeweb alpine-base build." Not in the v1.18.7 Dockerfile, not checked against the master Dockerfile.
- plan.md section 1 (Ports row): `index.html` contains `<meta name="kw-config" content="(no-config)">`. Not checked; the release zip was not fetched.
- plan.md section 10: Web Crypto/HTTPS caveat. Not stated in the README or Docker Hub pages (they only show TLS certs in the Docker setup).
- plan.md section 10: upstream plugin loading via `kw-config`. Not covered by sources.
