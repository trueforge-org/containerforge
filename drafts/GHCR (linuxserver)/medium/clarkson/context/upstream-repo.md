# Upstream: linuxserver/Clarkson (repo page)
Sources: https://api.github.com/repos/linuxserver/Clarkson (403, not retrieved); fallback https://github.com/linuxserver/Clarkson (fetched 2026-11-27)

## What it is
- "Web-based fuel logging dashboard": records fuel fill-ups for multiple vehicles, multi-user, spend/distance/consumption graphs
- License MIT; default branch master
- Latest release: none shown (Releases section empty)

## Stack and manual install (README)
- Angular front-end, ExpressJS back-end, MySQL 5.7.*, Flyway schema migrations
- Steps: npm install -g @angular/cli ts-node typescript; npm install; set apiBaseUrl in src/environments/environment.prod.ts; ng build --prod; run Flyway migration against MySQL (needs JRE); node clarkson.js
- Env: MYSQL_HOST, MYSQL_USERNAME, MYSQL_PASSWORD; optional ENABLE_REGISTRATIONS (default false), APP_PORT (default 3000)

## Status
- README: development stopped, code outdated, no new features or PRs; successor Hammond (github.com/akhilrex/hammond)
- Not flagged archived on page
