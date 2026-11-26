# khlieng/dispatch Dockerfile (commit d3d8323)

Source URL(s) + fetch date:
- https://github.com/khlieng/dispatch/blob/d3d8323/Dockerfile (fetched as raw) · 2026-11-26

## Contents
- Build stage: `FROM golang:alpine AS build`; `apk add --update git make build-base`; WORKDIR `/go/src/github.com/khlieng/dispatch`; `COPY . /go/src/github.com/khlieng/dispatch`; `chmod +x install.sh && ./install.sh`.
- Runtime stage: `FROM alpine`; `apk add --update ca-certificates`; `COPY --from=build /go/bin/dispatch /dispatch`.
- `EXPOSE 80/tcp`, `VOLUME ["/data"]`, `ENTRYPOINT ["/dispatch"]`, `CMD ["--dir=/data"]`.
- No ARG, ENV or USER.

## Notes
- Matches plan.md section 4 summary (golang:alpine build, alpine runtime, EXPOSE 80, VOLUME /data, ENTRYPOINT, CMD).
- Runs as root (no USER) upstream.
