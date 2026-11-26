# GitHub: muety/mininote (README facts)

Source URL(s): https://raw.githubusercontent.com/muety/mininote/master/README.md (fetched 2026-11-26)

## What it is
- Self-hosted note app for Markdown with client-side encryption. Vue 3 frontend, Express backend. MIT license.
- Note title and content encrypted in browser with AES-GCM (Web Crypto). Key derived from notebook password. Not true E2E: server could capture password on notebook creation.

## Requirements
- Node.js 22.12.0 LTS or newer

## Env vars
| Var | Purpose | Default |
| --- | --- | --- |
| HTTPS_CERT | TLS cert path | none documented |
| HTTPS_KEY | TLS key path | none documented |

## Ports / paths (Docker example)
- `-p 3000:3000`
- `-v mininote-data:/app/data` (persistent data)
- cert/key mounted read-only at /etc/mininote.crt and /etc/mininote.key
- Image example: ghcr.io/muety/mininote:latest

## Local run
- `yarn` in root; `yarn` then `yarn build` in webapp; `yarn start`

## Gotchas
- TLS mandatory for non-localhost hosts since v1.0.0.
- Database options not documented.
