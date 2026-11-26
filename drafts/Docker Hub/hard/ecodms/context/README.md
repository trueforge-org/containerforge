# ecodms context index

Fetched 2026-11-26. Summaries of every web source referenced by draft.md and plan.md.

## Sources

| Source URL | Summary file |
| --- | --- |
| https://www.ecodms.de/ | docs-ecodms-de.md |
| https://www.ecodms.de/de/ | docs-ecodms-de.md |
| https://www.ecodms.de/index.php/en | docs-ecodms-de.md |
| https://www.ecodms.de/de/download | docs-ecodms-de-download.md |
| https://ecodms.datamagic.at/download/ | docs-ecodms-datamagic-download.md (Linux repo lines, key, install) |
| http://www.ecodms.de/ecodms_260164/ | (not fetched; the repo lines and key are on the datamagic page above) |
| http://www.ecodms.de/ecodms_260164/noble | docs-ecodms-apt-noble-packages.md (directory 403; Packages index fetched instead) |
| http://www.ecodms.de/gpg/ecodms.key | docs-ecodms-gpg-key.md |
| https://hub.docker.com/r/ecodms/allinone-18.09 | dockerhub-ecodms-allinone-18-09.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/ecodms | truecharts-ecodms.md (directory not fetched; values.yaml fetched via raw URL) |

## Skipped URLs

| URL | Reason |
| --- | --- |
| https://cla-assistant.io/trueforge-org/containerforge | CLA link (not a source) |
| https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json | forgetool schema URL |
| https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu | containerforge apps/<base> link |
| https://github.com/trueforge-org/containerforge/tree/main/apps/java17 | containerforge apps/<base> link |

Note: the draft's `http://www.ecodms.de/ecodms_260164/` root and `/noble` are repository paths. The repo lines use `http`, which WebFetch upgrades to https; the plain-http URLs are recorded as in the source.

## Fetch failures

- http://www.ecodms.de/ecodms_260164/noble/ (directory): HTTP 403. One alternative tried: `.../noble/Packages` (plain text index), which succeeded and is summarised.
- Not fetched: `/de/support/systemvoraussetzungen` and `/de/support/changelog` (linked from the site, not draft URLs).

## plan.md corrections

- Section 1, Downloads row: the Linux repo and key lines were attributed to "the vendor's download page for Build 26.01"; they are on https://ecodms.datamagic.at/download/ (not `/de/download`). Edited to name the source. Source: docs-ecodms-datamagic-download.md.
- Section 1, Downloads row: the other packages named as "also ecodmsclient, ecodmspackages" are confirmed, and the index also lists ecodmsmailzplugin, ecodmsprinter and postgresql-ecodms-vectorizeimage; the current `ecodmsserver` version is 26.01-4; all six packages are amd64. Edited. Source: docs-ecodms-apt-noble-packages.md.
- Section 1, Manual notes row: "The server package bundles a PostgreSQL database and a container storage system" -> `ecodmsserver` declares apt dependencies on postgresql, postgresql-16-pgvector, postgresql-ecodms-vectorizeimage, samba, sudo, haveged (PostgreSQL not bundled). Edited. Source: docs-ecodms-apt-noble-packages.md.
- Section 3, base-image sentence: the noble Depends list has no Java package, so apt does not pull one; the JVM question stays UNVERIFIED. Edited. Source: docs-ecodms-apt-noble-packages.md.
- Section 4 step 2: apt version string `26.01-4` now known. Edited. Source: docs-ecodms-apt-noble-packages.md.
- Section 6, dependencies sentence: PostgreSQL is an apt dependency, not bundled. Edited. Source: docs-ecodms-apt-noble-packages.md.
- Section 10, upgrade-path sentence: "reportedly ... (UNVERIFIED, not re-read)" -> confirmed on the Hub page. Edited. Source: dockerhub-ecodms-allinone-18-09.md.

## plan.md unverified (not edited)

- Section 1, Downloads: "Ubuntu 26.04 repository: UNVERIFIED (not listed)" stays; the Linux page lists Ubuntu 24.04 (noble), Debian 12 and 13 only. Source: docs-ecodms-datamagic-download.md.
- Section 1, Downloads: arm64 still UNVERIFIED (the index lists amd64 only; no arm64 index found).
- Section 1, Checksum/key: the key fetch shows no user ID or fingerprint in text; verify with gpg before use. Source: docs-ecodms-gpg-key.md.
- Section 1, Manual notes: "haveged recommended on VMs" is consistent with `haveged` in the Depends list, but the "interactive dialogs" claim is not checked.
- Section 9 and 10: the Depends list includes `samba` and `sudo`, which the plan does not mention; Samba is what the Hub suggests for scaninput sharing. Source: docs-ecodms-apt-noble-packages.md, dockerhub-ecodms-allinone-18-09.md.
- Section 6: the Hub says ports 17001, 8080 (17004 host) and 8180 (17005 host); the plan's port list matches. No env vars documented anywhere.
