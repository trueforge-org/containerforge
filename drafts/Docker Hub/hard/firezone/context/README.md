# Context for firezone

Fetched 2026-11-26.

## Source URL -> file

| Source URL | Summary file |
| --- | --- |
| https://github.com/firezone/firezone | github-firezone-firezone.md (repo root, current master) |
| https://github.com/firezone/firezone/blob/dc71329fa007942ed32c69bd820f66b94cf5a5cc/Dockerfile.prod | github-firezone-firezone.md (raw file at the same commit) |
| https://github.com/firezone/firezone/archive/refs/tags/${VERSION}.tar.gz | not fetched (binary archive); pattern in github-firezone-firezone.md |
| https://www.firezone.dev | firezone-dev.md |
| https://www.firezone.dev/kb | firezone-dev.md |
| https://hub.docker.com/r/firezone/firezone | dockerhub-firezone-firezone.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/firezone | truecharts-firezone.md |

Extra sources (plan references, followed one level from the Dockerfile): `rel/overlays/bin/server`, `rel/overlays/bin/bootstrap`, `LICENSE` at the pinned commit (all in github-firezone-firezone.md).

## Skipped URLs

| URL | Reason |
| --- | --- |
| https://cla-assistant.io/trueforge-org/containerforge | CLA link |
| https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json | forgetool schema URL |
| https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu | containerforge apps/<base> link |
| http://localhost:13000 | localhost |
| ghcr.io/trueforge-org/ubuntu (and :26.04@sha256 variant) | ghcr image refs, not web pages |
| https://github.com/firezone/firezone/blob/main/docs/README.md#frequently-asked-questions-faq | cited by the Hub page; not fetched (FAQ anchor; the Hub summary covers it) |
| https://docs.firezone.dev/deploy/docker/ | cited by Hub page; not fetched separately (0.7 Docker docs, plan does not depend on it) |

## Fetch failures

- None.

## plan.md corrections

- Section 4 step 6, ENV line: `PHOENIX_PORT=13000` -> `PHOENIX_HTTP_PORT=13000` (chart env name, see truecharts-firezone.md).
- Section 7 step 2: the port variable name was UNVERIFIED; chart confirms `PHOENIX_HTTP_PORT`. Edited to reflect that.
- Unverified (not changed): builder image choice (`hexpm/elixir` in plan vs upstream `firezone/elixir:${ELIXIR_VERSION}-otp-${OTP_VERSION}`); `TELEMETRY_ENABLED` default `false` (plan says upstream default is true; not confirmed here); `.tool-versions` Node 18.16.0 (not fetched).
