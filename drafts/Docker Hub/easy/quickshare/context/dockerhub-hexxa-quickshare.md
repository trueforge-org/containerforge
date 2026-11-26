# hexxa/quickshare (Docker Hub)

Source URL(s) + fetch date (2026-11-26):
- https://hub.docker.com/r/hexxa/quickshare (fetched)

## What it is
Docker image of the ihexxa/quickshare file sharing server. Image size about 73 MB, 50K+ pulls, last updated about 10 months before fetch.

## Tags
- Only `latest` visible (digest sha256:a47e01e8c...). Pull: `docker pull hexxa/quickshare`.

## Arch support
- Not stated on page.

## Run example (from page)
```
docker run \
    --name quickshare \
    -d -p :8686:8686 \
    -v `pwd`/quickshare/root:/quickshare/root \
    -e DEFAULTADMIN=qs \
    -e DEFAULTADMINPWD=1234 \
    hexxa/quickshare
```
- Ports: 8686 container. Serves at 8686, sign in user `qs` / password `1234` (example values).
- Volume: `/quickshare/root` (file root).
- Env: `DEFAULTADMIN`, `DEFAULTADMINPWD`.
- No compose example on the page.

## Gotchas
- Example credentials are placeholders on the page; set real values.
