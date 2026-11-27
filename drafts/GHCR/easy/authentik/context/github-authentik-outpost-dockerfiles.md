# goauthentik/authentik: outpost Dockerfiles (commit 98ec4a7)
Source URL(s): https://raw.githubusercontent.com/goauthentik/authentik/98ec4a7684fcb0cccfe78888a12df1df1ad938be/lifecycle/container/{ldap,proxy,radius}.Dockerfile (fetched; blob variants same)

## Build pattern (all three)
- Builder: Go outposts (ldap, radius) on `golang:1.27-trixie` with `CGO_ENABLED=1 GOFIPS140=latest`; proxy is Rust (cargo, rust-toolchain.toml, aws-lc FIPS, `AWS_LC_FIPS_SYS_CC=clang`) on `ghcr.io/goauthentik/fips-debian:trixie-slim-fips`
- Runtime: `ghcr.io/goauthentik/fips-debian:trixie-slim-fips` (ldap, radius, proxy)
- Runtime RUN: `apt-get update && apt-get upgrade -y && apt-get clean && rm -rf /tmp/* /var/lib/apt/lists/*`
- Labels: source https://github.com/goauthentik/authentik, licenses link to repo LICENSE, `version=${VERSION}`, `revision=${GIT_BUILD_HASH}`
- All three: `USER 1000`, `ENV TMPDIR=/dev/shm/`

## Per image
| Image | Binary (in /) | ENTRYPOINT | EXPOSE | HEALTHCHECK | Extra ENV |
| --- | --- | --- | --- | --- | --- |
| ldap | /ldap (from /go/ldap) | ["/ldap"] | 3389 6636 9300 | ["/ldap","healthcheck"] | GOFIPS=1 |
| proxy | /authentik (from /bin/authentik) | ["/authentik","proxy"] | 9000 9300 9443 | ["/authentik","healthcheck","proxy"] | RUST_BACKTRACE=full |
| radius | /radius (from /go/radius) | ["/radius"] | 1812/udp 9300 | ["/radius","healthcheck"] | GOFIPS=1 |

- HEALTHCHECK interval 5s, retries 20, start-period 3s (all three)
- No VOLUME in any; no config files baked in

## Gotchas
