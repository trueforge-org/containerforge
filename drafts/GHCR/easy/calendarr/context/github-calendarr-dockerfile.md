# GitHub calendarr Dockerfile (pinned commit 4da458f and main)

## Source URL(s) + date
- https://raw.githubusercontent.com/jordanlambrecht/calendarr/4da458fb9d59a787c6ae1819eb063ba91cfe83d1/Dockerfile (fetched 2026-11-27)
- https://raw.githubusercontent.com/jordanlambrecht/calendarr/main/Dockerfile (fetched 2026-11-27)

## Diff
- Only difference: base `FROM python:3.15.0-slim` (pinned commit) vs `FROM python:3.15.2-slim` (main).

## Dockerfile (main)
- `FROM python:3.15.2-slim`; `WORKDIR /app`
- LABEL source https://github.com/jordanlambrecht/calendarr; description "Calendar feeds from Sonarr/Radarr to Discord and Slack"; licenses GPL-3.0
- `COPY requirements.txt .`; `RUN pip install --no-cache-dir -r requirements.txt`
- `COPY src/ /app/src/`
- `COPY ./calendarr/custom_footers /app/default_footers/` (seed footers)
- `COPY entrypoint.sh /app/entrypoint.sh`; `RUN chmod +x`
- `RUN mkdir -p /app/logs`
- `ENV PYTHONUNBUFFERED=1`, `ENV PYTHONPATH=/app/src`
- `EXPOSE 5000`
- `HEALTHCHECK --interval=30s --timeout=10s --start-period=20s --retries=3 CMD python -c "urllib.request.urlopen('http://localhost:5000/health')"`
- `ENTRYPOINT ["/app/entrypoint.sh"]`; `CMD ["python", "-m", "calendarr"]`
- No USER line (runs as root upstream).

## Entrypoint/flags
- entrypoint.sh (upstream) seeds footers, then runs CMD.

## Runtime deps
- Python packages from requirements.txt. No system packages installed in Dockerfile.

## Ports
- 5000 (EXPOSE; health endpoint /health).

## Volumes/paths
- `/app/logs` (created), `/app/default_footers` (seed), `/app/custom_footers` (chart mount).
