<!-- markdownlint-disable MD013 -->

# Alternate names and excluded drafts

Several TrueCharts charts use an image that ContainerForge already packages, or that another draft covers, under a different name. Those drafts were removed from `drafts/` so that each application is packaged once. This page maps the name a chart or registry knows to the app that covers it.

A removed draft is not lost: its plan is in the git history of `drafts/<registry>/<difficulty>/<name>/`.

## Already packaged under another name

The chart can switch to the existing app. No new app is needed.

| Alternate name (removed draft) | Chart | Image the chart uses | Existing app | Note |
| --- | --- | --- | --- | --- |
| `memcached` (Docker Hub) | `memcached` | `docker.io/bitnamisecure/memcached:latest` | `apps/memcache` | Same memcached image; switch the chart to the existing app. |
| `wyoming-piper` (Docker Hub) | `wyoming-piper` | `docker.io/rhasspy/wyoming-piper:2.5.4` | `apps/piper` | `apps/piper` already ships Wyoming Piper. |
| `wyoming-whisper` (Docker Hub) | `wyoming-whisper` | `docker.io/rhasspy/wyoming-whisper:3.9.1` | `apps/faster-whisper` | `apps/faster-whisper` already installs `wyoming-faster-whisper` on port 10300. |
| `pyload` (GHCR (linuxserver)) | `pyload` | `ghcr.io/linuxserver/pyload:version-360b2295` | `apps/pyload-ng` | Same upstream (pyload-ng). |
| `changedetection-io` (GHCR) | `changedetection-io` | `ghcr.io/dgtlmoon/changedetection.io:0.70.4` | `apps/changedetection` | Same upstream (changedetection.io). |
| `minetest` (GHCR (linuxserver)) | `minetest` | `ghcr.io/linuxserver/minetest:5.10.0` | `apps/luanti` | Minetest was renamed to Luanti. |
| `mylar` (LSCR) | `mylar` | `lscr.io/linuxserver/mylar3:version-v0.11.0` | `apps/mylar3` | Same upstream (mylar3). |
| `mend-renovate` (GHCR) | `mend-renovate` | `ghcr.io/mend/renovate-ce:15.12.0` | `apps/renovate` | Mend Renovate is Renovate; `apps/renovate` ships the open-source image. |
| `grafana` (GHCR) | `grafana` | `ghcr.io/kiwigrid/k8s-sidecar:2.14.3` | `apps/k8s-sidecar` | The Grafana chart's sidecar row is `kiwigrid/k8s-sidecar`. |
| `multus-cni` (GHCR) | `multus-cni` | `ghcr.io/siderolabs/cni:v1.14.0` | `apps/cni-plugins` | The `siderolabs/cni` row ships the same CNI plugin tarballs. The Multus thick-plugin row (`GHCR/hard/multus-cni`) is a different image and stays a draft. |
| `unifi` (GHCR) | `unifi` | `ghcr.io/goofball222/unifi:10.6.109` | `apps/unifi-network-application` | Same software (UniFi Network Application), packaged by another project. |
| `redis` (Docker Hub) | `redis` | `docker.io/bitnamisecure/redis:latest` | `apps/valkey` | Valkey is the Redis-compatible drop-in already packaged. |
| `airsonic` (GHCR (linuxserver)) | `airsonic` | `ghcr.io/linuxserver/airsonic:version-v10.6.2` | `apps/airsonic-advanced` | Airsonic is unmaintained; Airsonic-Advanced is its maintained fork. |
| `plex-meta-manager` (Docker Hub) | `plex-meta-manager` | `docker.io/meisnate12/plex-meta-manager:v1.21.0` | `apps/kometa` | Plex Meta Manager was renamed to Kometa. |
| `clusterissuer` (Docker Hub) | `clusterissuer` | `hello-world:latest` | `apps/scratch` | Placeholder `hello-world` image that the chart never runs. |
| `metallb-config` (Docker Hub) | `metallb-config` | `hello-world:latest` | `apps/scratch` | Placeholder `hello-world` image that the chart never runs. |
| `external-service` (Docker Hub) | `external-service` | `alpine:3.24.4` | `apps/scratch` | Placeholder pod for the `external-service` chart. |

## Covered by another draft

One app is built; the other chart or registry name is an alternate name for it.

| Alternate name (removed draft) | Chart | Image the chart uses | Kept draft | Note |
| --- | --- | --- | --- | --- |
| `rdtclient` (GHCR) | `rdtclient` | `ghcr.io/p3terx/aria2-pro:latest` | `drafts/GHCR/easy/aria2` | Same `p3terx/aria2-pro` image (aria2 sidecar of the rdtclient chart). |
| `guacamole` (Docker Hub) | `guacamole` | `docker.io/guacamole/guacd:1.6.0` | `drafts/Docker Hub/easy/guacd` | Same `guacamole/guacd` image (guacd sidecar of the guacamole chart). |
| `fsm` (Docker Hub) | `fsm` | `docker.io/ofsm/ofsm:latest` | `drafts/Docker Hub/hard/factorioservermanager` | Same `ofsm/ofsm` image. |
| `bitcoin-node` (Docker Hub) | `bitcoin-node` | `docker.io/kylemanna/bitcoind:latest` | `drafts/Docker Hub/easy/bitcoind` | Same software (Bitcoin Core), same ports. The binary is `bitcoind`. |
| `reg` (Docker Hub) | `reg` | `registry:3` | `drafts/Docker Hub/easy/dockerregistry` | Same `registry:3` image (distribution/distribution). |
| `teedy-docs` (Docker Hub) | `teedy-docs` | `docker.io/sismics/docs:latest` | `drafts/Docker Hub/medium/teedy` | Same `sismics/docs` image. |
| `app-template` (GHCR) | `app-template` | `ghcr.io/miguelndecarvalho/speedtest-exporter:v3.5.4` | `drafts/GHCR/easy/speedtest-exporter` | Same `speedtest-exporter` image. |
| `hastebin` (Docker Hub) | `hastebin` | `docker.io/flippinturt/hastebin:latest` | `drafts/GHCR/hard/haste-server` | Same software (haste-server). |
| `plexripper` (Docker Hub) | `plexripper` | `docker.io/plexripper/plexripper:0.32.0` | `drafts/Docker Hub/hard/reaparr` | PlexRipper was renamed to Reaparr. |
| `core-keeper-dedicated-server` (Docker Hub) | `core-keeper-dedicated-server` | `docker.io/escaping/core-keeper-dedicated:latest` | `drafts/GHCR/medium/corekeeper` | Same game server (Steam app 1963720). |
| `blender-desktop-g3` (Docker Hub) | `blender-desktop-g3` | `docker.io/accetto/ubuntu-vnc-xfce-blender-g3:latest` | `drafts/LSCR/hard/blender` | Same software in a KasmVNC desktop. |
| `kdenlive-vnc` (Docker Hub) | `kdenlive-vnc` | `docker.io/tessypowder/docker-kdenlive:latest` | `drafts/LSCR/hard/kdenlive` | Same software in a KasmVNC desktop. |
| `firefox-desktop-g3` (Docker Hub) | `firefox-desktop-g3` | `docker.io/accetto/ubuntu-vnc-xfce-firefox-g3:latest` | `drafts/GHCR (linuxserver)/hard/firefox` | Same software in a KasmVNC desktop. |
| `chromium-desktop-g3` (Docker Hub) | `chromium-desktop-g3` | `docker.io/accetto/ubuntu-vnc-xfce-chromium-g3:latest` | `drafts/GHCR (linuxserver)/hard/chromium` | Same software in a KasmVNC desktop. |

## Excluded: full operating system images

Full OS images are not accepted as ContainerForge apps. These drafts were removed.

| Draft (removed) | Why |
| --- | --- |
| `raspberrymatic` (GHCR), image `ghcr.io/jens-maus/raspberrymatic:latest` | Whole buildroot OS root filesystem with its own init (RaspberryMatic/OpenCCU). |
| `debian-bullseye` (GHCR), image `ghcr.io/ich777/debian-bullseye:latest` | A full Debian bullseye desktop image; the 'app' is the operating system. |
| `android-8-0` (Docker Hub), image `docker.io/ulisses1478/docker-android:latest` | Android 8 emulator image that bundles a full guest OS and needs KVM. |
