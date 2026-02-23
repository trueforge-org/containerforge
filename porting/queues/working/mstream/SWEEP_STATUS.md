# Sweep Status

- Timestamp (UTC): 2026-02-23T18:41:11Z
- Build: ok
- Forgetool test: ok
- Run status: running
- Timeout for build/test: 120 seconds
- Forgetool path: /home/runner/go/bin/forgetool

## Last test log tail
```
18:40:29 ℹ️ [INFO] Loaded container test YAML: path=container-test.yaml runners=0 http=0 tcp=1
18:40:29 ℹ️ [INFO] 🧪 Combined health+wait checks: image=mstream:5.13.1 http=0 tcp=1 filePaths=0
18:40:29 ℹ️ [INFO] Adding TCP wait #1: port=3000/tcp startupTimeout=2m0s
18:40:29 ℹ️ [INFO] 🚀 Starting container workflow: image=mstream:5.13.1 customizers=2
18:40:59 ✅ [OK] Container is up: image=mstream:5.13.1 totalElapsed=30.623s
18:40:59 ℹ️ [INFO] Combined health+wait checks completed successfully for image=mstream:5.13.1
```
