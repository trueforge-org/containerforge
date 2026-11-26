# obs-ndi context

| Source URL | File |
| --- | --- |
| https://github.com/DistroAV/DistroAV (raw README) | distroav-readme.md |
| https://api.github.com/repos/DistroAV/DistroAV/releases/latest | distroav-release-latest.md |
| https://github.com/DistroAV/DistroAV/wiki | distroav-wiki-home.md |
| https://distroav.org | distroav-org.md |
| https://github.com/patrickstigler/docker-obs-ndi (raw README) | patrickstigler-docker-obs-ndi-readme.md |
| https://github.com/patrickstigler/docker-obs-ndi/blob/400fc92a0a6953feef3bee371f5e0c2cd23991e2/Dockerfile | patrickstigler-docker-obs-ndi-dockerfile.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/obs-ndi (values.yaml) | truecharts-obs-ndi-values.md |
| https://hub.docker.com/r/patrickstigler/obs-ndi | dockerhub-patrickstigler-obs-ndi.md |

Skipped: none. Notes: the DistroAV README and release URL are fetched as the main sources (distroav-readme.md, distroav-release-latest.md).

Failures: DistroAV wiki Installation/Development subpages not retrievable (wiki home only; within follow-up budget not retried).

## plan.md corrections
- None made. Plan's DistroAV 6.2.2 version, sha256 for the .deb, OBS 31.1.1 / NDI 6.3 requirements and the wrapper's ports (5901/6901/4455) agree with fetched content.
- Unverified (no edit): wrapper Dockerfile summary reports a trailing `\` before VOLUME; Docker Hub run example conflicts with README (ports and password).
