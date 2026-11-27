# whisper-asr-webservice Dockerfile at tag v1.10.0

Source URL(s): https://raw.githubusercontent.com/ahmetoner/whisper-asr-webservice/v1.10.0/Dockerfile (fetched 2026-11-27; blob and releases/tag URLs not fetched, same tag)

## Stages
- `FROM onerahmet/ffmpeg:n7.1 AS ffmpeg` (ffmpeg source image).
- `FROM swaggerapi/swagger-ui:v5.9.1 AS swagger-ui` (assets only).
- Final: `FROM python:3.12-bookworm`.

## Build steps
- `LABEL org.opencontainers.image.source="https://github.com/ahmetoner/whisper-asr-webservice"`.
- `ENV POETRY_VENV=/app/.venv`; `python3 -m venv $POETRY_VENV`; `pip install -U pip setuptools`; `pip install poetry==2.1.3`.
- `ENV PATH="${PATH}:${POETRY_VENV}/bin"`, `WORKDIR /app`.
- `COPY . .` (repo source); `COPY --from=ffmpeg /usr/local/bin/ffmpeg /usr/local/bin/ffmpeg`.
- `COPY --from=swagger-ui` `swagger-ui.css` and `swagger-ui-bundle.js` into `swagger-ui-assets/`.
- `RUN poetry config virtualenvs.in-project true`; `RUN poetry install --extras cpu`.
- No apt step, no `USER`, no `VOLUME`, no `CMD`.

## Runtime
- `EXPOSE 9000`
- `ENTRYPOINT ["whisper-asr-webservice"]`

## Gotchas
- ffmpeg comes from a third-party image copy, not apt.
- Runs as root (no USER).
- Build installs CPU torch via the `cpu` extra; the index is `download.pytorch.org/whl/cpu` (pyproject not fetched).
