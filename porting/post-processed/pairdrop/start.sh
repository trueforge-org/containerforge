#!/usr/bin/env bash





    
        /config
fi





if [[ ${RATE_LIMIT,,} = "true" ]]; then
    OPT_RATE_LIMIT="--rate-limit"
fi

if [[ ${WS_FALLBACK,,} = "true" ]]; then
    OPT_WS_FALLBACK="--include-ws-fallback"
fi


    HOME=/config exec \
        
        cd /app/pairdrop  npm start -- "${OPT_RATE_LIMIT}" "${OPT_WS_FALLBACK}"
else
    HOME=/config exec \
        
        cd /app/pairdrop npm start -- "${OPT_RATE_LIMIT}" "${OPT_WS_FALLBACK}"
fi

