cp -n "/app/config.edn" "/config/config.edn"

config="/config/config.edn" && export config

exec java -jar "/app/doplarr.jar"
