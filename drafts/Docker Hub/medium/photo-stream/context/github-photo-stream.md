# GitHub: waschinski/photo-stream

## Source URL(s) + date
- https://api.github.com/repos/waschinski/photo-stream/releases/latest
- https://raw.githubusercontent.com/waschinski/photo-stream/4f4e0dd71bea2a1db063f03f6ba76ca1ffe02d29/Dockerfile
- Fetched 2026-11-27

## Latest release
- tag `1.5.0`, published 2023-03-16T15:43:38Z, no release assets.
- Source archive pattern (standard GitHub, not fetched): `archive/refs/tags/<tag>.tar.gz`.

## Upstream Dockerfile (commit 4f4e0dd71bea2a1db063f03f6ba76ca1ffe02d29)
- `ARG BASE_IMAGE=ruby:3.1.3-alpine3.17`; single stage `FROM ${BASE_IMAGE}`.
- RUN 1: `apk update && apk upgrade`; `apk add --update --no-cache build-base glib-dev exiftool libexif-dev expat-dev tiff-dev jpeg-dev libpng libgsf-dev vips git rsync lftp openssh perl`; `rm -rf /var/cache/apk/*`.
- RUN 2: `ruby -v && gem install bundler jekyll`; `bundle config --local build.sassc --disable-march-tune-native`; `bundle install`.
- `COPY ./ /photo-stream`; `WORKDIR /photo-stream`.
- `EXPOSE 4000`.
- `ENTRYPOINT bundle exec jekyll serve --host 0.0.0.0` (dev server, builds site at runtime).
- No ENV, USER, VOLUME, CMD, or copied scripts.

## Runtime deps
- Ruby 3.1.3 (Alpine 3.17), bundler, jekyll, exiftool, libvips, git, rsync, lftp, openssh, perl.

## Entrypoint/flags
- Jekyll dev server bound to 0.0.0.0 on port 4000.

## Ports
- 4000.

## User/UID
- Not set; runs as root.

## Gotchas
- Floating-era base (Ruby 3.1.3 on Alpine 3.17, EOL-era); upstream is a Jekyll dev server, not a static build.
- Release 1.5.0 has no binary assets; build must use the source archive.
- Not fetched: Gemfile, `_config.yml`, verbatim Dockerfile RUN text beyond the summary (fetch returned summary only).
