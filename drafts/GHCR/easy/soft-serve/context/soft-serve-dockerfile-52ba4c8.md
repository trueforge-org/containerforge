# soft-serve upstream Dockerfile (commit 52ba4c8)

## Source URL(s) + date
- https://raw.githubusercontent.com/charmbracelet/soft-serve/52ba4c852667ff464675b0876fcb1ca2da257dce/Dockerfile (from blob URL in urls.txt)
- Fetched 2026-11-27

## Facts
- Same as v0.12.4: `FROM alpine:latest`; apk git/bash/openssh; ENV `SOFT_SERVE_DATA_PATH=/soft-serve`, `SOFT_SERVE_INITIAL_ADMIN_KEYS=""`, `CI=1`; WORKDIR/VOLUME `/soft-serve`; EXPOSE 23231, 23232, 23233, 9418 (tcp); ENTRYPOINT `["/usr/local/bin/soft", "serve"]`; no USER, no HEALTHCHECK.
- Differences from v0.12.4: none reported by the fetch summary.
