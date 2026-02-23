# Sweep Status

- Timestamp (UTC): 2026-02-19T23:36:39Z
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
[90m2026-02-19T23:35:39Z[0m [33mWRN[0m [1mFailed to cache cluster-template release; verify FORGETOOL_CLUSTER_TEMPLATE_VERSION is a valid release tag or check network connectivity to GitHub[0m [36merror=[0m[31m[1m"unexpected status for latest release: 403 Forbidden"[0m[0m
[90m2026-02-19T23:35:39Z[0m [32mINF[0m [1mChecking if System Time is correct...[0m
[90m2026-02-19T23:35:39Z[0m [32mINF[0m [1mFailed to get NTP time: lookup pool.ntp.org on 127.0.0.53:53: server misbehaving[0m
[90m2026-02-19T23:35:39Z[0m [32mINF[0m [1mCluster name: main
[0m
23:35:39 [34mℹ️ [INFO][0m 🧪 Wait checks: image=wireguard:1.0.20250521-r0 http=0 tcp=1
23:35:39 [34mℹ️ [INFO][0m Wait checks container config: env=none
23:35:39 [34mℹ️ [INFO][0m 🚀 Starting container: image=wireguard:1.0.20250521-r0 customizers=2
23:36:39 [31m❌ [ERROR][0m Container start failed for image=wireguard:1.0.20250521-r0: generic container: start container: started hook: wait until ready: internal check: container exec inspect: Get "http://%2Fvar%2Frun%2Fdocker.sock/v1.48/exec/54327ab543d91d05aaf7f9b8adf8535854319c24f84e756220759f1d3f2742ee/json": context deadline exceeded, host port waiting failed
check failed: generic container: start container: started hook: wait until ready: internal check: container exec inspect: Get "http://%2Fvar%2Frun%2Fdocker.sock/v1.48/exec/54327ab543d91d05aaf7f9b8adf8535854319c24f84e756220759f1d3f2742ee/json": context deadline exceeded, host port waiting failed
[90m2026-02-19T23:36:39Z[0m [31mFTL[0m [1mFailed to execute command[0m [36merror=[0m[31m[1m"check failed: generic container: start container: started hook: wait until ready: internal check: container exec inspect: Get \"http://%2Fvar%2Frun%2Fdocker.sock/v1.48/exec/54327ab543d91d05aaf7f9b8adf8535854319c24f84e756220759f1d3f2742ee/json\": context deadline exceeded, host port waiting failed"[0m[0m
```
