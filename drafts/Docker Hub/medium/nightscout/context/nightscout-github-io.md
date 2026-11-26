# Nightscout documentation site (nightscout.github.io)

## Source URL(s) + date
- https://nightscout.github.io (2026-11-26)

## What it is
Nightscout Documentation index page. Sections: Supported Uploaders, create database (MongoDB Atlas, Railway, Northflank), create web app (Azure Docker, Northflank, Render, Railway, Heroku, Fly.io, Google Cloud), Setup Nightscout, Use, Advanced DIY ("Building Nightscout with Docker", "Advanced Nightscout deployments", Synology, Raspberry Pi).

## Relevance to container build
- Only pointer to the "Building Nightscout with Docker" guide (page not fetched; out of budget and not in list).
- Update/downgrade guides referenced from the upstream README: nightscout.github.io/update/update/ and /update/downgrade/ (not fetched).

## Gotchas
- Index page only; no env, port or build facts. Use the upstream README (see github-cgm-remote-monitor.md) for config.
