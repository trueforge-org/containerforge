# GitHub: DavidSpek/homelablabelmaker (application source)

Source URL(s) + fetch date: https://github.com/DavidSpek/homelablabelmaker ; README read from https://raw.githubusercontent.com/DavidSpek/homelablabelmaker/d52776c7bd405bf388f53a725a640f2c1a461ae4/README.md ; Dockerfile from https://raw.githubusercontent.com/DavidSpek/homelablabelmaker/d52776c7bd405bf388f53a725a640f2c1a461ae4/Docker%20Files/Dockerfile · fetched 2026-11-26

## What it is
DIY web tool to create and print labels for drive caddies. Supports Dell PowerEdge Gen11 and HP ProLiant G5 to G9 caddies, with Supermicro labels newer than the hosted version.

## Install/build steps and build deps
- Upstream Dockerfile (`Docker Files/Dockerfile`):
  - `FROM httpd:alpine`
  - `RUN apk add --no-cache git`
  - `WORKDIR /`
  - `RUN git clone https://github.com/DavidSpek/homelablabelmaker`
  - `RUN mv ./homelablabelmaker/* /usr/local/apache2/htdocs/`
- No COPY, EXPOSE, ENV, VOLUME, USER, CMD or ENTRYPOINT: startup is left to the httpd base image.
- README gives no build or run instructions.

## Runtime deps
- Static files only. Browser needs internet to load external assets (see the live page summary).

## Binaries/entrypoint/CLI flags
- None. Static site.

## Env vars (table)
- None mentioned.

## Ports
- None mentioned in the README. Upstream image serves on container port 80 (per Docker Hub and TrueCharts).

## Volumes/paths and persistent data
- None. Files are served from `/usr/local/apache2/htdocs/` in the upstream image.

## Version/release info and asset naming
- No releases or tags. Source archive pattern: `https://github.com/DavidSpek/homelablabelmaker/archive/<commit-sha>.tar.gz`. The draft's `.zip` archive link (`archive/d52776c7...zip`) is a direct archive download and was not fetched.
- Default branch `master`; the pinned commit is `d52776c7bd405bf388f53a725a640f2c1a461ae4`.

## Arch support
- Static content, arch-neutral.

## License
- README has no license statement. Plan.md notes no LICENSE file at the pinned commit. The hosted site shows a CC BY-SA 4.0 badge (see the live site summary), which is not in the repo.

## Gotchas
- Contradiction with plan.md: none on the Dockerfile. Plan.md says the upstream serves on 80, which agrees.
