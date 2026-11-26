# hauxir/imgpush: Dockerfile (commit 9a44956)
Source URL(s): https://github.com/hauxir/imgpush/blob/9a44956/Dockerfile = raw at 9a44956 (fetched 2026-11-26, 54 lines)

## Build stage (ubuntu:24.04 AS builder)
- apt: python3, python3-venv
- COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv (unpinned)
- COPY pyproject.toml uv.lock .python-version ./ and app ./app
- RUN uv sync --frozen --no-cache --no-dev --extra rembg  (venv at /.venv)

## Runtime stage (ubuntu:24.04)
- apt (no recommends): libmagickwand-dev, curl, nginx, python3, python3-venv
- COPY --from=builder /.venv /.venv; ENV PATH="/.venv/bin:$PATH"
- COPY nginx.conf -> /etc/nginx/conf.d/default.conf
- COPY ImageMagick-6/policy.xml -> /etc/ImageMagick-6/policy.xml
- COPY classifier_model.onnx -> /root/.NudeNet/classifier_model.onnx
- RUN /.venv/bin/python -c "from rembg import new_session; new_session('u2net')" (pre-download model)
- mkdir /images, /cache, /local_cache
- EXPOSE 5000; COPY app /app; WORKDIR /app
- CMD bash entrypoint.sh (runs as root, no USER)

## Gotchas
- Upstream runs as root; no HEALTHCHECK.
- Model/weights baked at build time (rembg u2net, NudeNet classifier) under /root.
