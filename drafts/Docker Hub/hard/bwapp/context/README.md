# bwapp: source context (fetched 2026-11-26)

## Sources fetched

| Source URL | Summary file |
| --- | --- |
| https://www.itsecgames.com/ | itsecgames-com.md |
| https://www.itsecgames.com/download.htm | itsecgames-com.md |
| https://sourceforge.net/projects/bwapp | sourceforge-bwapp.md |
| https://sourceforge.net/projects/bwapp/files/bWAPP/ | sourceforge-bwapp-files.md |
| https://hub.docker.com/r/raesene/bwapp | dockerhub-raesene-bwapp.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/bwapp (values.yaml) | truecharts-bwapp.md |

## Skipped URLs

| URL | Reason |
| --- | --- |
| https://cla-assistant.io/trueforge-org/containerforge | CLA link (never fetched) |
| https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu | containerforge base app link |
| https://sourceforge.net/projects/bwapp/files/bWAPP/ (zip "binary") | zip archive download; file name and version recorded in sourceforge-bwapp-files.md (`bWAPPv2.2/bWAPPv2.2.zip`) |
| https://sourceforge.net/projects/bwapp/files/bee-box/ | not referenced by draft or plan as a source; only mentioned on the download page (itsecgames-com.md) |

## Fetch failures

- https://sourceforge.net/projects/bwapp/files/bWAPP/INSTALL.txt/download, and the same file via https://downloads.sourceforge.net/project/bwapp/bWAPP/INSTALL.txt: both 302-redirect to a SourceForge download mirror (direct download). Not followed. Default credentials, PHP/MySQL/Apache requirements and config file layout therefore remain UNVERIFIED.

## plan.md corrections

- Section 1 Version: "UNVERIFIED: ... (commonly `bWAPP_latest.zip`, believed 2.2)" -> version 2.2, zip `bWAPPv2.2.zip` at `bWAPP/bWAPPv2.2/bWAPPv2.2.zip` (15.1 MB, 2014-11-02); `bWAPP_latest.zip` also at folder root. Source: sourceforge-bwapp.md, sourceforge-bwapp-files.md.
- Section 1 Checksum: "SourceForge shows MD5/SHA1 per file (UNVERIFIED)" -> no MD5/SHA1 shown on the folder page. Source: sourceforge-bwapp-files.md.
- Section 5 VERSION: "from the pinned zip (UNVERIFIED, e.g. `2.2`)" -> `2.2` (verified).
- Section 1 License: CC BY-NC-ND 4.0 confirmed by homepage footer (no change needed; now verified). Source: itsecgames-com.md.

## Unverified (plan.md left as-is)

- Section 1 Env/Ports: default login `bee`/`bug`, `admin/settings.php` keys, `install.php` behaviour. Not confirmed (INSTALL.txt not retrievable).
- Section 3/4: Apache/PHP package names (not sourced).

## Notes (not edited into plan.md)

- SourceForge shows "Malware detected" warnings on the bWAPP folder and the download link. Verify the zip checksum before use.
- raesene/bwapp Docker Hub image is archived, old (`tutum/lamp` base), root-based, port 80, run with `/install.php`. Plan's rebuild stands.
- itsecgames.com does not say archived or maintained; Docker Hub says the community image is archived. SourceForge last update 2018-05-21.
