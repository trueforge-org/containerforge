# Upstream Dockerfile: evan-buss/openbooks (commit 045410c)

Source URL(s) + date:
- https://raw.githubusercontent.com/evan-buss/openbooks/045410c2787860e3ce79ae66954e6c1723d185c1/Dockerfile (2026-11-27)
- https://github.com/evan-buss/openbooks/blob/045410c.../Dockerfile (HTML variant, not fetched; raw used)

What it is: three-stage build of the OpenBooks server (web UI plus Go binary).

Stages:
1. `web`: `FROM node:16`, `COPY . .`, `cd /web/server/app/`, `npm install`, `npm run build`
2. `build`: `FROM golang` (unpinned tag), `COPY . .`, `COPY --from=web /web/ .`, `CGO_ENABLED=0`, `go get -d -v ./...`, `go install -v ./...`, `go build` in `cmd/openbooks`
3. `app`: `FROM gcr.io/distroless/static`, `WORKDIR /app`, copies `/go/src/cmd/openbooks/openbooks` to `/app`

Runtime:
- `EXPOSE 80`
- `VOLUME [ "/books" ]`
- `ENV BASE_PATH=/`
- `ENTRYPOINT ["./openbooks", "server", "--dir", "/books", "--port", "80"]`
- No CMD, no USER (distroless static default is root unless set; no USER line here).

Entrypoint flags are fixed in the ENTRYPOINT: `--dir /books`, `--port 80`. `BASE_PATH` env is listed in the Dockerfile but the ENTRYPOINT does not pass `--basepath`; the docs say `BASE_PATH` env works in Docker.

Arch: multi-platform builds per Docker docs (see docs-openbooks.md). Distroless static base means no shell, no libc.

Gotchas:
- Builder stages use unpinned `node:16` and `golang` tags.
- Final image has no shell; runtime writes must go to `/books`.
