# ArchiveTeam/warrior-dockerfile (Dockerfile and entrypoint at pinned commit 061524d)

## Source URL(s) + date
- https://raw.githubusercontent.com/ArchiveTeam/warrior-dockerfile/061524dc03515df50bc0c45bd96af907f401cf39/Dockerfile (fetched 2026-11-27)
- https://raw.githubusercontent.com/ArchiveTeam/warrior-dockerfile/061524dc03515df50bc0c45bd96af907f401cf39/entrypoint.sh (fetched 2026-11-27)
- https://github.com/ArchiveTeam/warrior-dockerfile/blob/061524dc.../Dockerfile: same file as raw.

## Dockerfile
- `FROM atdr.meo.ws/archiveteam/grab-base`; `LABEL version="20261118.01"`.
- apt: `bash` (no-install-recommends).
- `COPY --from=gcr.io/go-containerregistry/crane:v0.22.1 /ko-app/crane /usr/local/bin/crane`.
- Copies `/usr/local/lib`, `/etc/ssl/certs`, `/usr/local/etc/wgetrc` from `grab-base:nss`; `ldconfig`.
- `useradd -m warrior --uid 1000`; sudoers `warrior ALL=(ALL) NOPASSWD: ALL`.
- `COPY entrypoint.sh /entrypoint.sh`; `WORKDIR /home/warrior`; `USER 1000`.
- `mkdir data projects`; `ln -fs /usr/local/bin/wget-lua /home/warrior/data/wget-at`.
- wget-lua variants copied to `data/`: `wget-at-openssl` (from grab-base:openssl), `wget-at-gnutls`, `wget-at-nss`.
- `RUN git clone --depth 1 --recurse-submodules https://github.com/ArchiveTeam/warrior-code2.git` (unpinned clone at build).
- `COPY --chown=warrior:warrior start.py .` (start.py not in the fetched sources; it is in the build context).
- `EXPOSE 8001`; `STOPSIGNAL SIGINT`.
- `ENTRYPOINT ["/entrypoint.sh"]`.
- `HEALTHCHECK --interval=5s --timeout=3s CMD /home/warrior/data/wget-at -nv -t1 'http://localhost:8001/index.html' -O /dev/null || exit 1`.

## entrypoint.sh
```
#!/bin/sh
ulimit -c 0
exec /usr/bin/tini -- python start.py
```
- Runs `python start.py` under tini.

## Ports / user / paths
- Port 8001 (web UI).
- User `warrior` uid 1000; workdir `/home/warrior`; data `/home/warrior/data`, `projects`.
- No VOLUME declared in Dockerfile.

## Env vars
- Not defined in these two files. Env (`SELECTED_PROJECT`, `DOWNLOADER`, item concurrency) are documented in the ArchiveTeam wiki (see archiveteam-wiki-warrior.md); the Docker env reference page 404s.

## Gotchas
- Build clones `warrior-code2` master (no pin) at build time.
- Dockerfile `USER 1000` and `warrior` sudo rule (passwordless sudo inside container).
- Image is not read-only-friendly by default: writes under `/home/warrior/data` and `projects`.
