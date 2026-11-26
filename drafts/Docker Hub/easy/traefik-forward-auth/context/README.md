# context/ for traefik-forward-auth

Fetched 2026-11-26.

## Sources

| Source URL | Summary file |
| --- | --- |
| https://github.com/thomseddon/traefik-forward-auth (README, Dockerfile @83f06df, cmd/main.go and internal/config.go @v2.3.0, releases page) | github-thomseddon-traefik-forward-auth.md |
| https://hub.docker.com/r/thomseddon/traefik-forward-auth | dockerhub-thomseddon-traefik-forward-auth.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/traefik-forward-auth (values.yaml) | truecharts-traefik-forward-auth.md |

## Skipped

- https://cla-assistant.io/trueforge-org/containerforge: CLA page, not a source.
- https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json: forgetool schema URL.
- https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json: forgetool schema URL.
- https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu: containerforge base link.
- https://github.com/thomseddon/traefik-forward-auth/archive/refs/tags/v${VERSION}.tar.gz and https://github.com/thomseddon/traefik-forward-auth/archive/refs/tags/v2.3.0.tar.gz: direct source archives (pattern recorded in the GitHub summary).
- https://github.com/thomseddon/traefik-forward-auth/releases/download/v2.3.0/traefik-forward-auth_amd64: direct binary download (name recorded in the GitHub summary).
- https://github.com/thomseddon/traefik-forward-auth/blob/83f06df/Dockerfile: fetched raw instead.
- Local reference `docs/project-fireball.md` is not a web source.

## Fetch failures

- Releases asset list for v2.3.0: did not load (fetch error). Asset names and checksum presence unconfirmed.
- Upstream `go.mod`, `LICENSE.md` and the provider package (`Setup()` behaviour): not fetched, so these are unverified.

## plan.md corrections

None made. Items left as unverified (not edited):
- Plan section 6: `MATCH_WHITELIST_OR_DOMAIN` env entry. The README table gives no env name for `match-whitelist-or-domain` (its env column is "–"). Unverified whether the env name exists.
- Plan section 1: release assets are "`traefik-forward-auth_amd64` and `traefik-forward-auth_arm` only". The v2.3.0 page reports "Assets 4" with no list, which fits two binaries plus two auto source archives. Unverified.
- Plan section 1: `go.mod` `go 1.22` / `toolchain go1.22.2`, commit `26e7995`, MIT `LICENSE.md`. Not fetched.
- Plan section 8: the claim that the Google provider `Setup()` only checks client ID and secret, and that the image exits without a provider. `internal/config.go` confirms `Validate()` log.Fatals on setup failure, but the provider package was not fetched.
- Plan section 10: "The Docker Hub `latest` tag used by TrueCharts is unpinned". TrueCharts pins `latest` by digest (`sha256:b364aa6a...`). Left as is; a note rather than an error.
