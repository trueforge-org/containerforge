# cannery: source context (fetched 2026-11-26)

## Sources fetched

| Source URL | Summary file |
| --- | --- |
| https://gitlab.com/shibaobun/cannery (tags page) | gitlab-shibaobun-cannery.md |
| https://gitlab.com/shibaobun/cannery/-/raw/1.5.9/README.md | gitlab-shibaobun-cannery.md |
| https://gitlab.com/shibaobun/cannery/-/raw/1.5.9/LICENSE.md | gitlab-shibaobun-cannery.md |
| https://gitlab.com/shibaobun/cannery/-/raw/1.5.9/mix.exs | gitlab-shibaobun-cannery.md |
| https://gitlab.com/shibaobun/cannery/-/raw/1.5.9/.tool-versions | gitlab-shibaobun-cannery.md |
| https://gitlab.com/shibaobun/cannery/-/raw/1.5.9/config/runtime.exs | gitlab-shibaobun-cannery.md |
| https://gitlab.com/shibaobun/cannery/-/raw/1.5.9/Dockerfile | gitlab-shibaobun-cannery.md |
| https://gitlab.com/shibaobun/cannery/-/blob/1.5.8/Dockerfile (raw 1.5.8) | gitlab-shibaobun-cannery.md |
| https://gitlab.com/shibaobun/cannery/-/raw/1.5.9/priv/docker-entrypoint.sh | gitlab-shibaobun-cannery.md |
| https://hub.docker.com/r/shibaobun/cannery | dockerhub-shibaobun-cannery.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/cannery (values.yaml) | truecharts-cannery.md |
| https://gitlab.com/shibaobun/cannery (repo page, via tags and raw files) | gitlab-shibaobun-cannery.md |

## Skipped URLs

| URL | Reason |
| --- | --- |
| https://cla-assistant.io/trueforge-org/containerforge | CLA link (never fetched) |
| https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu | containerforge base app link |
| https://gitlab.com/shibaobun/cannery/-/archive/${VERSION}/cannery-${VERSION}.tar.gz | direct source archive; pattern recorded in gitlab-shibaobun-cannery.md |
| http://localhost:4000/ | localhost URL (not a source) |

## Fetch failures

- https://gitlab.com/shibaobun/cannery/-/raw/main/README.md: 404 (use the 1.5.9 tag raw README, fetched).
- https://gitea.bubbletea.dev/shibao/cannery: 301 to bubbletea.dev, which is now a parking page. See gitea-bubbletea-cannery.md.
- Raw Dockerfile on main/dev returned 404 per plan.md. Raw Dockerfile at tags 1.5.8 and 1.5.9 worked.

## plan.md corrections

- Section 1 License: "SPDX: `AGPL-3.0-or-later` UNVERIFIED (only-vs-or-later not checked in LICENSE.md)" -> `AGPL-3.0-or-later`; README states "AGPLv3 or later", LICENSE.md is the AGPL v3 text. Source: gitlab-shibaobun-cannery.md.
- Section 1 Upstream Dockerfile: "raw Dockerfile URLs returned 404 ... NOT reviewed" -> raw Dockerfile at 1.5.9 and 1.5.8 is available and was reviewed: Alpine/musl stages `node:26.13.1-alpine3.24`, `hexpm/elixir:1.20.5-erlang-29.1.2-alpine-3.24.3`, runtime `alpine:latest`, ENTRYPOINT `/app/priv/docker-entrypoint.sh`, CMD `bin/cannery start`. Source: gitlab-shibaobun-cannery.md.
- Section 3 Base image: "required Elixir/OTP versions UNVERIFIED (read `mix.exs` `elixir:` and `.tool-versions` at the tag)" -> Elixir `1.20.5` (exact pin in mix.exs), Erlang/OTP `29.1.2` (.tool-versions, `elixir 1.20.5-otp-29`); upstream asset build uses Node `26.13.1` with `npm ci` in `assets/`. Source: gitlab-shibaobun-cannery.md.
- Section 4 step 1: the tarball must keep `vendor/` (local path deps `cloak` and `cloak_ecto`); heroicons is fetched from GitHub at build. Source: gitlab-shibaobun-cannery.md (mix.exs, Dockerfile COPY vendor).
- Section 6 env: "`HOST` (default `localhost`, required)" -> `HOST` has **no default**; required in every environment (runtime.exs raises if unset). Source: gitlab-shibaobun-cannery.md (runtime.exs).
- Section 7 step 4: "Run migrations (command UNVERIFIED; ...)" -> no separate migrate command: prod sets `Cannery.Application` `automigrate: true`, so migrations run on app start. Source: gitlab-shibaobun-cannery.md (runtime.exs).
- Section 7 step 5: "`PHX_SERVER=true` if the release needs it (UNVERIFIED), binding 0.0.0.0 (UNVERIFIED...)" -> `PHX_SERVER` is presence-only (any value); prod endpoint binds the IPv6 any address `{0,0,0,0,0,0,0,0}`, which also accepts IPv4 on dual-stack. Source: gitlab-shibaobun-cannery.md.
- Section 10 bullet 1: "Upstream Dockerfile unreviewed (404 on raw paths); entrypoint, migrate command and bind address are UNVERIFIED." -> Dockerfile reviewed (tags 1.5.8/1.5.9); entrypoint known; migrations automatic; bind address verified. Source as above.
- Section 10 bullet 2: "Elixir/OTP version and asset toolchain UNVERIFIED" -> Elixir 1.20.5, OTP 29.1.2 verified; asset toolchain is npm (`assets/`) with Node 26.13.1, esbuild/tailwind via mix aliases. Source: gitlab-shibaobun-cannery.md.

## Unverified / notes (plan.md left as-is)

- Newer tag `1.5.10` (2026-11-26, pipeline still running at fetch). plan.md keeps `1.5.9`.
- Upstream uses Alpine/musl; plan.md uses Ubuntu 26.04 (glibc). The plan's choice is intentional but should be noted in the PR; the upstream `docker-entrypoint.sh` (chown + su-exec) is not needed for a non-root image.
- `UPLOADS_PATH/tmp` directory is created by upstream entrypoint and chart command; our start.sh (plan step 1) only creates the uploads dir.
- `RELEASE_TMP` and `RELEASE_COOKIE` (plan section 9) are not mentioned in any fetched source.
- Helper scripts `priv/random.sh` and `priv/cloak_key.sh` exist (documented in README); bodies not fetched.
- Gitea mirror is gone; GitLab is the only source.
