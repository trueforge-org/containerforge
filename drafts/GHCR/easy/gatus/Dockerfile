# UNVERIFIED: the golang:1.27 tag and digest must be confirmed (go.mod declares go 1.27.0). Pin the digest before merge.
FROM golang:1.27@sha256:5f1b98fa02fe396ebce2a0227a0e08309e11792915b9dd2e1f71053d7e7e6666 AS build

ARG VERSION
ARG REVISION

# UNVERIFIED: the release tag is assumed to be plain "0.6.1" with no "v" prefix
RUN git clone --depth 1 --branch "${VERSION}" https://github.com/home-operations/gatus-sidecar.git /src

WORKDIR /src

RUN go mod download && \
    CGO_ENABLED=0 go build -trimpath \
        -ldflags "-s -w -X main.Version=${VERSION} -X main.Gitsha=${REVISION:-unknown}" \
        -o /out/gatus-sidecar ./cmd/gatus-sidecar

# UNVERIFIED: base digest is taken from the plan (Ubuntu 26.04)
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

USER root

COPY --from=build /out/gatus-sidecar /app/gatus-sidecar
# UNVERIFIED: LICENSE is assumed to be in the repo root
COPY --from=build /src/LICENSE /usr/share/licenses/gatus/LICENSE

RUN chown -R apps:apps /app && chmod -R 755 /app

USER apps
COPY --chmod=0755 . /

CMD ["/start.sh"]
