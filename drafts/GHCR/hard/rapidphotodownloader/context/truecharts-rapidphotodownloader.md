# TrueCharts chart: rapidphotodownloader

**Source URL(s):** https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/rapidphotodownloader/values.yaml , .../Chart.yaml · fetched 2026-11-27

## What it is
- Chart `rapidphotodownloader`, appVersion `latest` (no version pin), train stable, category MediaApp-Photos.
- Description: downloads and installs Rapid Photo Downloader.
- Dependency: `common` 32.8.5. kubeVersion >=1.33.0-0.

## Image
- repository: `ghcr.io/ich777/rapidphotodownloader`
- tag: `latest@sha256:fef9de67f31ace4d9eedd05c79159ec0aa1307cb2bffec38383778479d8e4154` (pullPolicy IfNotPresent)

## Ports
| name | port | target | proto |
| --- | --- | --- | --- |
| main | 8080 | 8080 | tcp (noVNC web) |

## Env (chart-set)
| var | value |
| --- | --- |
| CUSTOM_RES_W | 1024 |
| CUSTOM_RES_H | 881 |
| DL_URL | https://launchpad.net/rapid/pyqt/0.9.17/+download/install.py |
| FORCE_UPDATE | "" |

## Persistence
| name | mountPath |
| --- | --- |
| datadir | /rapidphotodownloader |
| destinantionfolder | /media/destination |
| sourcefolder | /media/source |

Note: chart key is spelled `destinantionfolder` (typo in upstream chart).

## Security context (chart)
- runAsUser 0, runAsGroup 0, readOnlyRootFilesystem false.

## Gotchas
- DL_URL pins Rapid Photo Downloader pyqt install.py to 0.9.17 while upstream latest release (HTML, see release file) is 0.9.37.
- Probes not set in values.
