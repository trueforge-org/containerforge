# Docker Hub pawelmalak/snippet-box

Source URL(s) + date:
- https://hub.docker.com/v2/repositories/pawelmalak/snippet-box/
- https://hub.docker.com/v2/repositories/pawelmalak/snippet-box/tags?page_size=10
- Fetched 2026-11-27

## What it is
- name `snippet-box`, namespace `pawelmalak`
- Description: "Snippet Box is a simple self-hosted app for organizing your code snippets."
- last_updated 2021-11-18; pull_count 2643819; star_count 30

## Tags (count 3)
| tag | last_updated | arch |
| --- | --- | --- |
| latest | 2021-10-14 | amd64 |
| dev | 2021-11-18 | amd64, arm64, arm |
| arm | 2021-10-14 | arm64, arm |

## Description (full_description, summarized)
- Stack: Node.js, Express.js, Sequelize ORM + SQLite; React + TypeScript + Bootstrap frontend; Docker deployment.
- Build: `docker build -t snippet-box .`
- Run: `docker run -p 5000:5000 -v /path/to/data:/app/data snippet-box`
- Dev: `npm run init` (once), `npm run dev`

## Runtime
- Port 5000 (Dockerfile EXPOSE)
- Data volume `/app/data` (docs example)
- Chart and docs agree on `/app/data`.

## Gotchas
- `latest` last updated 2021-10-14; repo last pushed 2023-04-05 (see github-snippet-box.md).
