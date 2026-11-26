# Context: gaseous-server

| Source URL | File |
| --- | --- |
| https://github.com/gaseous-project/gaseous-server/blob/139459c/build/Dockerfile (raw variant) | gaseous-project-gaseous-server-dockerfile.md |
| https://raw.githubusercontent.com/gaseous-project/gaseous-server/master/README.md | not retrieved (404) |
| https://raw.githubusercontent.com/gaseous-project/gaseous-server/main/README.md | not retrieved (404, alternative) |
| https://github.com/gaseous-project/gaseous-server/wiki | gaseous-project-wiki.md (Home only) |
| https://api.github.com/repos/gaseous-project/gaseous-server/releases/latest | gaseous-project-github-api-releases.md |
| https://dot.net/v1/dotnet-install.sh (+ redirect) | dotnet-install.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/gaseous-server (+ raw Chart.yaml, values.yaml) | truecharts-gaseous-server.md |
| https://hub.docker.com/r/gaseousgames/gaseousserver (+ v2 API repo and tags) | dockerhub-gaseousserver.md |

Skipped: urls.txt has no CLA, forgetool, containerforge, templated or image-ref URLs. Binary download https://cdn.emulatorjs.org/releases/4.2.1.7z not fetched (build-time asset; its URL and version are recorded from the Dockerfile). `http://+:5198` is an ASP.NET bind string, not a web source.

Failures: master and main README.md returned 404 (one alternative used). Wiki sub-pages did not load. hub.docker.com HTML not fetched; v2 JSON API used.

## plan.md corrections
- No edits. Consistent with fetched sources: v1.7.14 (GitHub release 2025-07-31), Dockerfile stages (sdk:8.0 / aspnet:8.0, `INDOCKER=1`, `/App`, ENTRYPOINT dotnet gaseous-server.dll, EmulatorJS 4.2.1.7z, no USER), container port 80 vs chart service 5198 (targetPort 80), `/root/.gaseous-server` paths, rc.5 on 2026-09-27 (Docker Hub).
- Still UNVERIFIED (not contradicted by fetched sources, left as-is): plan line 10 AGPL variant; plan line 20 v1.7.14 per-arch digests (v1.7.14 not on the first 10 Docker Hub tags fetched); plan line 18 app-side env names (app source not fetched).
- Note: plan line 8 says v2.0.0-preview.* exist; Docker Hub lists v2.0.0-rc.* only on page 1 (preview tags not checked).
