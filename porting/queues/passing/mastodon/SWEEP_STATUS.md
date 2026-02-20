# Sweep Status

- Timestamp (UTC): 2026-02-20T14:09:00Z
- Build: ok
- Forgetool test: fail
- Run status: not running
- Timeout for test: 300 seconds
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
[90m2026-02-20T14:08:49Z[0m [32mINF[0m [1mChecking if System Time is correct...[0m
[90m2026-02-20T14:08:49Z[0m [32mINF[0m [1mSystem Time is correct...[0m
[90m2026-02-20T14:08:49Z[0m [32mINF[0m [1mCluster name: main
[0m
14:08:49 [34mℹ️ [INFO][0m 🧪 Wait checks: image=mastodon:4.5.1 http=0 tcp=1
14:08:49 [34mℹ️ [INFO][0m Wait checks container config: env=none
14:08:49 [34mℹ️ [INFO][0m 🚀 Starting container: image=mastodon:4.5.1 customizers=2
14:09:00 [31m❌ [ERROR][0m Container start failed for image=mastodon:4.5.1: generic container: start container: started hook: wait until ready: internal check: container exited with code 1
check failed: generic container: start container: started hook: wait until ready: internal check: container exited with code 1
[90m2026-02-20T14:09:00Z[0m [31mFTL[0m [1mFailed to execute command[0m [36merror=[0m[31m[1m"check failed: generic container: start container: started hook: wait until ready: internal check: container exited with code 1"[0m[0m
```
