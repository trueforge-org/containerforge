# hkalexling/mango (GitHub, old name, redirects to getmango/Mango)

Source URL(s) + fetch date:
- https://github.com/hkalexling/mango (repo page; displayed as getmango/Mango, see github-getmango-mango.md)
- https://raw.githubusercontent.com/hkalexling/mango/7a7d9eb/Dockerfile (draft/plan blob link)
- Fetched 2026-11-26

## Status
- Old repo name. Redirects to `getmango/Mango`. README badges and links still point to `hkalexling/Mango`.
- Archived 23 Mar 2025 (read-only). Default branch `master`. License MIT.

## Upstream Dockerfile at 7a7d9eb (verbatim)
```
FROM crystallang/crystal:1.0.0-alpine AS builder

WORKDIR /Mango

COPY . .
RUN apk add --no-cache yarn yaml-static sqlite-static libarchive-dev libarchive-static acl-static expat-static zstd-static lz4-static bzip2-static libjpeg-turbo-dev libpng-dev tiff-dev
RUN make static || make static

FROM library/alpine

WORKDIR /

COPY --from=builder /Mango/mango /usr/local/bin/mango

CMD ["/usr/local/bin/mango"]
```
- Builder: Crystal 1.0.0 on Alpine, `make static`. Final stage: `library/alpine`, copies `/Mango/mango` to `/usr/local/bin/mango`.
- No ENV, ARG, ENTRYPOINT, VOLUME, USER, EXPOSE. CMD runs the binary.

## Relevance
- Plan's claim "crystal 1.0.0 alpine `make static`, then `FROM alpine`, COPY binary to `/usr/local/bin/mango`, CMD" is confirmed.
- Compose volumes (`/root/mango`, `/root/.config/mango`) are documented on Docker Hub, not in this Dockerfile.
