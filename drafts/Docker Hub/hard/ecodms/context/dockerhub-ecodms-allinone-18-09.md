# ecodms/allinone-18.09 (Docker Hub)

Source URL(s) + fetch date:
- https://hub.docker.com/r/ecodms/allinone-18.09
- Fetched 2026-11-26

## What it is
- Full ecoDMS 18.09 (apu) installation, aimed at QNAP and Synology. All services in one container; data in an external directory.
- 1M+ pulls, 45 stars. Last updated about 3 years before fetch.
- Only `latest` tag (digest `sha256:3530bbaf5...`, 729.5 MB).
- Architectures not shown.

## Run command (documented)
```
docker run --restart=always -it -d -p 17001:17001 -p 17004:8080 -p 17005:8180 --name "ecodms" \
  -v /volume2/ecodmsData:/srv/data -v /volume1/ecoDMS/scaninput:/srv/scaninput \
  -v /volume1/ecoDMS/backup:/srv/backup -v /volume1/ecoDMS/restore:/srv/restore -t ecodms/allinone-18.09
```
- Ports (host:container): 17001:17001, 17004:8080, 17005:8180.
- Volumes: `/srv/data`, `/srv/scaninput`, `/srv/backup`, `/srv/restore`.
- Env vars: none documented.

## Data directory rules
- Data directory can be chosen freely; its contents and permissions must not be changed by hand.
- Scanned documents go to scaninput (shareable via Samba). Backup and restore directories should be kept separate and backed up themselves.
- Direct upgrade from 16.09 or 14.08 is not possible; the installation manual covers those steps.

## Backup
1. Start container. 2. Close all Connection-Managers and other connections. 3. Open `backup` folder in the ecoDMS data dir. 4. Upload an empty file named `create`. 5. Backup starts a few seconds later; result appears in the same folder. 6. `create` is deleted after success.
- Built-in backup function inside the container only allows `/srv/data/backup` as target.

## Restore
1. Close connections. 2. Stop container. 3. Open `restore` folder in the data dir. 4. Copy a backup made with "OneClick Backup" or "ecoDMSBackupConsole". 5. Rename to `restore.zip` (lowercase). 6. Start container; restore runs (may take a while). 7. Success -> `restore-processed.zip`; failure -> `restore-failed.zip`.
