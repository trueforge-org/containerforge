# DiscordGSM/GameServerMonitor Dockerfile (commit 17d2e12, tag 2.20.1)

Source URL(s) + fetch date:
- https://github.com/DiscordGSM/GameServerMonitor/blob/17d2e124a3d7a4b4cc4b64bada325f363fb162da/Dockerfile (fetched as raw) · 2026-11-26

## Contents
- `FROM python:3.13-alpine`
- `ENV PYTHONDONTWRITEBYTECODE=1`, `ENV PYTHONUNBUFFERED=1`
- `WORKDIR /usr/src/app`
- `COPY requirements.txt ./`, then `COPY . .`
- `RUN pip install --upgrade pip`, `RUN pip install --no-cache-dir -r requirements.txt`
- `CMD ["python", "main.py"]`
- No ARG, USER, EXPOSE, VOLUME, ENTRYPOINT, HEALTHCHECK.

## Notes
- Plan.md's description (`python:3.13-alpine`, env, `pip install -r requirements.txt`, `CMD`, no EXPOSE/VOLUME) matches.
- Plan.md states `mkdir /usr/src/app/data` in the upstream file; this fetch shows no mkdir. Plan.md's claim is not confirmed by this fetch (only the Dockerfile RUN steps listed above). Flag as a possible plan.md mismatch, not edited.
- Upstream runs as root (no USER).
