# Upstream: joemccann/dillinger README and project site
Sources: https://raw.githubusercontent.com/joemccann/dillinger/master/README.md; https://dillinger.io (fetched 2026-11-27)

## What it is
- Markdown editor: Next.js based, Monaco editor (VS Code core), live preview, scroll sync, Vim/Emacs keybindings, dark mode, zen mode
- Local auto-save; drafts in browser local storage; offline editing after first load
- Export: Markdown, HTML, PDF
- Cloud sync via OAuth: GitHub, Google Drive, Dropbox, OneDrive, Bitbucket
- License MIT, open source on GitHub

## Install (README)
- Node.js 18 or newer; npm, yarn, pnpm or bun
- Dev: npm install; npm run dev (default port 3000)
- Production: npm run build; npm start
- Provider credentials in .env.local; OAuth callback URLs must point to own domain

## Gotchas
- Site gives no version/release info and no self-hosting requirements beyond the README
- Upstream is Next.js (Node 18+), not the AngularJS build the linuxserver image's description refers to
