# context: dockerregistry

## Sources (URL -> file)
| Source URL | File | Fetched |
| --- | --- | --- |
| https://github.com/distribution/distribution (README via raw main) | github-distribution-distribution.md | 2026-11-26 |
| https://github.com/distribution/distribution/releases/latest | github-distribution-distribution.md | 2026-11-26 |
| https://github.com/distribution/distribution-library-image/blob/775973b655bb4b11561db92a1cf50113148ce530/Dockerfile | github-distribution-distribution-library-dockerfile.md | 2026-11-26 |
| https://raw.githubusercontent.com/distribution/distribution-library-image/775973b.../config-example.yml (followed from the Dockerfile's COPY) | github-distribution-distribution-library-config-example.md | 2026-11-26 |
| https://raw.githubusercontent.com/distribution/distribution-library-image/775973b.../entrypoint.sh (followed) | github-distribution-distribution-library-entrypoint.md | 2026-11-26 |
| https://distribution.github.io/distribution/ | docs-distribution-github-io-home.md | 2026-11-26 |
| https://distribution.github.io/distribution/about/configuration/ (followed from the docs home) | github-distribution-distribution-docs-configuration.md | 2026-11-26 |
| https://hub.docker.com/_/registry | dockerhub-library-registry.md | 2026-11-26 |
| https://registry.hub.docker.com/_/registry | dockerhub-library-registry.md (same official image page; not separately fetched) | 2026-11-26 |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/dockerregistry (read via raw values.yaml) | truecharts-dockerregistry.md | 2026-11-26 |

## Skipped
- https://cla-assistant.io/trueforge-org/containerforge: CLA link.
- https://raw.githubusercontent.com/trueforge-org/forgetool/... (both schema URLs): forgetool schema.
- https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu: containerforge base app link.
- https://github.com/distribution/distribution/releases/download/${VERSION}/registry_${VERSION#v}_linux_${TARGETARCH}.tar.gz (and `.sha256`), and the v3.1.2 amd64/arm64 tarballs: direct archive/checksum downloads. Naming recorded in github-distribution-distribution.md.
- http://127.0.0.1:5000/v2/: localhost.

## Fetch failures
- releases/latest: asset list did not load; no sha256 shown on the page. Per-asset `.sha256` files not verified on the release page (upstream Dockerfile hard-codes hashes instead).

## plan.md corrections
- None made. Confirmed from context: v3.1.2 latest, alpine:3.24 upstream base, `/bin/registry` upstream, `config-example.yml` contents, entrypoint.sh behaviour, `OTEL_TRACES_EXPORTER=none`, `VOLUME /var/lib/registry`, `EXPOSE 5000`, Apache-2.0 code, amd64 and arm64 sha256 values (from the upstream Dockerfile), `delete.enabled` default false, health defaults, chart `registry:3`.
- Unverified (left as-is): plan.md's claim that per-asset `.sha256` files exist on the release (release asset list did not load); `GET /v2/` answering 200 `{}` (API spec not fetched); "registry binary has no NEEDED libraries" (not checked here).
