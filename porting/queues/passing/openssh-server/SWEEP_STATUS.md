# Sweep Status

- Timestamp (UTC): 2026-02-20T16:52:22Z
- Build: ok
- Forgetool test: fail
- Run status: not running
- Build command: docker buildx bake --set image-local.output=type=docker image-local
- Timeout for build/test: 1800/420 seconds
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
[90m2026-02-20T16:52:21Z[0m [32mINF[0m [1mChecking if System Time is correct...[0m
[90m2026-02-20T16:52:21Z[0m [32mINF[0m [1mSystem Time is correct...[0m
[90m2026-02-20T16:52:21Z[0m [32mINF[0m [1mCluster name: main
[0m
16:52:21 [34mℹ️ [INFO][0m 🧪 Health check: image=openssh-server:10.0_p1-r9
16:52:21 [34mℹ️ [INFO][0m Health check container config: env=none
16:52:21 [34mℹ️ [INFO][0m 🚀 Starting container: image=openssh-server:10.0_p1-r9 customizers=1
16:52:22 [31m❌ [ERROR][0m Container start failed for image=openssh-server:10.0_p1-r9: generic container: start container: started hook: wait until ready: container exited with code 127
check failed: generic container: start container: started hook: wait until ready: container exited with code 127
[90m2026-02-20T16:52:22Z[0m [31mFTL[0m [1mFailed to execute command[0m [36merror=[0m[31m[1m"check failed: generic container: start container: started hook: wait until ready: container exited with code 127"[0m[0m
```
