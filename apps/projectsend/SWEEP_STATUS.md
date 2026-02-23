# Sweep Status

- Timestamp (UTC): 2026-02-23T18:48:31Z
- Build: ok
- Forgetool test: ok
- Run status: running
- Timeout for build/test: 120 seconds
- Forgetool path: /home/runner/go/bin/forgetool

## Last test log tail
```
18:47:50 ℹ️ [INFO] Loaded container test YAML: path=container-test.yaml runners=0 http=0 tcp=1
18:47:50 ℹ️ [INFO] 🧪 Combined health+wait checks: image=projectsend:r1945 http=0 tcp=1 filePaths=0
18:47:50 ℹ️ [INFO] Adding TCP wait #1: port=80/tcp startupTimeout=2m0s
18:47:50 ℹ️ [INFO] 🚀 Starting container workflow: image=projectsend:r1945 customizers=2
18:48:21 ✅ [OK] Container is up: image=projectsend:r1945 totalElapsed=30.561s
18:48:21 ℹ️ [INFO] Combined health+wait checks completed successfully for image=projectsend:r1945
```
