# TrueCharts chart: arksurvivalevolved

**Source URL(s) + fetch date**
- https://github.com/trueforge-org/truecharts/tree/master/charts/stable/arksurvivalevolved (listed in draft)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/arksurvivalevolved/values.yaml (fetched 2026-11-26)

**Config (values.yaml)**
- Image `docker.io/drpsychick/arkserver:latest`, digest `sha256:3393d8c81dc97da7ae8670f7af68fa7df9b51d5c141c8608c602b914d9239e7c`, pullPolicy `IfNotPresent`.
- Ports: `main` 7777/udp; `game` 7778/udp ("should always be main + 1"); `query` 27015/udp; `rcon` 27020/tcp.
- Persistence: `game` `/arkserver`; `ark` `/ark`; `backup` `/ark/backup`; `staging` `/ark/staging`; `steamapps` `/home/steam/.steam/steamapps`; `cluster` `/arkserver/ShooterGame/Saved/clusters`; `save` `/arkserver/ShooterGame/Saved`; `shootergame` `/arkserver/ShooterGame`; `gameinis` configmap at `/arkconfig`; `crontab` emptyDir at `/var/spool/cron/crontabs/`; `crontabfile` configmap at `/ark/config/crontab`. No sizes.
- securityContext: pod `fsGroup: 1001`. Container `runAsUser: 1001`, `runAsGroup: 1001`, `runAsNonRoot: false`, `readOnlyRootFilesystem: false`, `allowPrivilegeEscalation: true`, `capabilities add: AUDIT_WRITE, CHOWN, FOWNER, DAC_OVERRIDE, SETGID, SETUID`, privileged not set.
- Env: `am_arkNoPortDecrement` "true"; `am_arkGameIniFile` `/arkconfig/Game.ini`; `am_arkGameUserSettingsIniFile` `/arkconfig/GameUserSettings.ini`; `ARKSERVER_SHARED` `/arkserver`; `am_ark_QueryPort` 27015; `am_ark_Port` 7777; `am_ark_RCONPort` 27020; `am_ark_GameModIds` empty; `am_arkBackupPreUpdate` true; `ARKCLUSTER` "true"; `am_arkopt_clusterid` "arkserver"; `am_arkStagingDir` "/ark/staging"; `am_arkAutoUpdateOnStart` true; `am_ark_SessionName` "arkserver"; `am_serverMap` "TheIsland"; `am_ark_MaxPlayers` "10"; `am_ark_RCONEnabled` "True"; `am_arkflag_USECACHE` "true". Passwords come from secret `env-secrets` (sample placeholder values, not reproduced here).
- Probes: liveness, readiness and startup are TCP on the rcon port (27020), initial delay 60 s.

**Gotchas**
- The chart enables cluster mode (`ARKCLUSTER` "true") and an auto-update on start; the draft does not state this.
- The chart's probe on TCP 27020 means the RCON port is expected to be open; plan.md's test deviation (UDP-only ports, no probe) differs from the chart and is a deliberate ContainerForge choice.
- The chart's `am_ark_MaxPlayers` (10) differs from the SickHub default (70).
