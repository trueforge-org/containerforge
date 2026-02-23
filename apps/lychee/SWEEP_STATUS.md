# Sweep Status

- Timestamp (UTC): 2026-02-23T18:46:21Z
- Build: ok
- Forgetool test: ok
- Run status: running
- Timeout for build/test: 120 seconds
- Forgetool path: /home/runner/go/bin/forgetool

## Last test log tail
```
18:45:26 ℹ️ [INFO] Loaded container test YAML: path=container-test.yaml runners=0 http=0 tcp=1
18:45:26 ℹ️ [INFO] 🧪 Combined health+wait checks: image=lychee:6.10.1 http=0 tcp=1 filePaths=0
18:45:26 ℹ️ [INFO] Adding TCP wait #1: port=80/tcp startupTimeout=2m0s
18:45:26 ℹ️ [INFO] 🚀 Starting container workflow: image=lychee:6.10.1 customizers=2
18:45:56 ✅ [OK] Container is up: image=lychee:6.10.1 totalElapsed=30.593s
18:45:56 ℹ️ [INFO] Combined health+wait checks completed successfully for image=lychee:6.10.1
```
