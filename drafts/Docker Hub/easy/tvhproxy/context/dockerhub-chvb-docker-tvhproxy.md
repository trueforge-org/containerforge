# chvb/docker-tvhproxy (Docker Hub, upstream community image)

**Source URL(s) + fetch date**
- https://hub.docker.com/r/chvb/docker-tvhproxy (fetched 2026-11-26)

**What it is**
Docker Hub listing for a Flask application between Plex Media Server and Tvheadend, which lets Plex DVR and Live TV use Tvheadend. Built on Alpine Linux. 100K+ pulls, 2 stars.

**Tags**
- `latest` only: last updated about 9 years ago (no exact date), size 19.3 MB, digest not captured.
- TrueCharts pins `latest@sha256:e27e4c750121fd95cb1d109c6802d3bdddf42f51c4dc4404cc0eec184397fd79`.

**Arch support**
Not listed.

**Usage**
`docker pull chvb/docker-tvhproxy`. The usage section says "Later...". No env, ports or volumes are documented on the page.

**Gotchas**
- Stale image (last update about 9 years ago). Its config comes from the source repo (see GitHub file), not the page.
- Image is alpine 3.6 per its Dockerfile (GitHub file); plan.md uses the ContainerForge Python base instead.
