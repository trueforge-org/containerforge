# Sweep Status

- Timestamp (UTC): 2026-02-19T14:13:49Z
- Build: ok
- Forgetool test: fail
- Run status: not running
- Timeout for build/test: 120 seconds
- Forgetool path: /tmp/forgetool-bin/forgetool

## Last test log tail
```



  _______              ______                   
 |__   __|            |  ____|                  
    | |_ __ _   _  ___| |__ ___  _ __ __ _  ___ 
    | | '__| | | |/ _ \  __/ _ \| '__/ _` |/ _ \
    | | |  | |_| |  __/ | | (_) | | | (_| |  __/
    |_|_|   \__,_|\___|_|  \___/|_|  \__, |\___|
                                      __/ |     
        ____                ______   |___/  __      
       / __/__  _______ ___/_  __/__  ___  / /
      / _// _ \/ __/ _ `/ -_) / / _ \/ _ \/ / 
     /_/  \___/_/  \_, /\__/_/  \___/\___/_/  
                  /___/                       
                                     

---
Forgetool Version: dev
---
[90m2026-02-19T14:12:48Z[0m [33mWRN[0m [1mFailed to cache cluster-template release; verify FORGETOOL_CLUSTER_TEMPLATE_VERSION is a valid release tag or check network connectivity to GitHub[0m [36merror=[0m[31m[1m"unexpected status for latest release: 403 Forbidden"[0m[0m
[90m2026-02-19T14:12:48Z[0m [32mINF[0m [1mChecking if System Time is correct...[0m
[90m2026-02-19T14:12:48Z[0m [32mINF[0m [1mFailed to get NTP time: lookup pool.ntp.org on 127.0.0.53:53: server misbehaving[0m
[90m2026-02-19T14:12:48Z[0m [32mINF[0m [1mCluster name: main
[0m
14:12:48 [34mℹ️ [INFO][0m 🧪 Wait checks: image=monica:4.1.2 http=0 tcp=1
14:12:48 [34mℹ️ [INFO][0m Wait checks container config: env=none
14:12:48 [34mℹ️ [INFO][0m 🚀 Starting container: image=monica:4.1.2 customizers=2
14:13:49 [31m❌ [ERROR][0m Container start failed for image=monica:4.1.2: generic container: start container: started hook: wait until ready: internal check: container exec inspect: Get "http://%2Fvar%2Frun%2Fdocker.sock/v1.51/exec/3f7c6ac3d32147bcee562ff1f8e1e0c4903a61f05dccd56be4d4fbbd46c1d657/json": context deadline exceeded, host port waiting failed
check failed: generic container: start container: started hook: wait until ready: internal check: container exec inspect: Get "http://%2Fvar%2Frun%2Fdocker.sock/v1.51/exec/3f7c6ac3d32147bcee562ff1f8e1e0c4903a61f05dccd56be4d4fbbd46c1d657/json": context deadline exceeded, host port waiting failed
[90m2026-02-19T14:13:49Z[0m [31mFTL[0m [1mFailed to execute command[0m [36merror=[0m[31m[1m"check failed: generic container: start container: started hook: wait until ready: internal check: container exec inspect: Get \"http://%2Fvar%2Frun%2Fdocker.sock/v1.51/exec/3f7c6ac3d32147bcee562ff1f8e1e0c4903a61f05dccd56be4d4fbbd46c1d657/json\": context deadline exceeded, host port waiting failed"[0m[0m
```
