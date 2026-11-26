# roipoussiere/cadquery-server Dockerfile @ fe63439

Source: https://raw.githubusercontent.com/roipoussiere/cadquery-server/fe634393ae00cb271aca935a119a560b01140362/Dockerfile (fetched 2026-11-26)

## Base
- `FROM python:3.10` (single stage); no ARG, ENV

## Steps
1. apt-get update; install `libgl1 libgl1-mesa-glx`; rm -rf /var/lib/apt/lists/*
2. COPY pyproject.toml -> /app/; mkdir /app/cq_server; touch placeholder `/app/cq_server/__init__.py` and `/app/README.md`; `pip install /app[cadquery]` (no pins)
3. COPY cq_server -> /app/cq_server/; rm `__pycache__`; `pip install /app[cadquery]` again

## Runtime
- VOLUME `data`; WORKDIR `data` (= /data)
- ENTRYPOINT `cq-server` (no CMD)
- No EXPOSE, USER, download URLs, conda
