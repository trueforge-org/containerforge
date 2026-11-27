# coderaiser/cloudcmd docker/Dockerfile (pinned ddf4726e4565ad8151aa391294a60ef3385d26b7)
Source URL(s): https://raw.githubusercontent.com/coderaiser/cloudcmd/ddf4726e4565ad8151aa391294a60ef3385d26b7/docker/Dockerfile (also github blob URL, same content)

## Build steps
- Base: `FROM node` (unpinned, Docker Hub node image).
- LABEL org.opencontainers.image.source=https://github.com/coderaiser/cloudcmd
- mkdir /usr/src/cloudcmd; WORKDIR /usr/src/cloudcmd; COPY package.json
- RUN curl -fsSL https://bun.com/install | bash && ln -s /root/.bun/bin/bun /usr/local/bin/bun && chmod +x ... && bun r gritty --omit dev && bun i gritty --omit dev && bun pm cache rm
- COPY . /usr/src/cloudcmd; WORKDIR /

## Build deps
- curl, bash (bun installer needs unzip; bun installs to /root/.bun).
- Installs `gritty` terminal module via bun.

## Runtime
- ENTRYPOINT ["/usr/src/cloudcmd/bin/cloudcmd.js"] (no CMD)
- EXPOSE 8000

## Env vars (set in image)
| Name | Value |
| --- | --- |
| cloudcmd_terminal | true |
| cloudcmd_terminal_path | gritty |
| cloudcmd_open | false |

## Ports
- 8000

## Volumes/paths
- Runs as root (no USER). Home /root (config read from home). Image code at /usr/src/cloudcmd.

## Gotchas
- Bun is fetched at build time from bun.com/install (network at build).
- Build runs as root; no USER directive.
