# Upstream Dockerfile: unpoller/unpoller @ efb5e52 (Dockerfile)

Source URL(s) + date: https://raw.githubusercontent.com/unpoller/unpoller/efb5e52aefb26f913cfc17f96d5d9c7ba4772ac2/Dockerfile (fetched 2026-11-27)

## Build (2 stages)
- Stage 1 `busybox:latest AS builder`: mkdir /etc/unpoller; COPY examples/up.conf.example -> /etc/unpoller/up.conf; COPY unpoller_manual.html -> /etc/unpoller/manual.html; COPY README.html -> /etc/unpoller/readme.html.
- Stage 2 `gcr.io/distroless/static-debian13`:
  - ARG TARGETPLATFORM; COPY `${TARGETPLATFORM}/unpoller` -> /usr/bin/unpoller (binary prebuilt per platform in build context, not compiled here).
  - COPY --from=builder /etc/unpoller -> /etc/unpoller.
  - HEALTHCHECK every 30s, timeout 10s, start-period 30s, retries 3: `["/usr/bin/unpoller", "--health"]`.
  - ENTRYPOINT ["/usr/bin/unpoller"]; no CMD; no EXPOSE; no USER (distroless static default is root unless overridden).

## Runtime
- No shell in final image (distroless). No writable paths set.
- Config defaults to /etc/unpoller/up.conf (copied from examples).

## Arch
- Per-platform directory naming `${TARGETPLATFORM}` (e.g. linux/amd64, linux/arm64). Binary must exist in build context.

## Gotchas
- busybox:latest and distroless debian13 are not pinned in this commit.
- Helper HTML files (manual, readme) are copied from repo root.
