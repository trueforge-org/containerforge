mkdir -p ./denied-apk ./denied-from

for dir in ./processed/*/; do
    if [ -f "$dir/Dockerfile" ] && grep -q "apk " "$dir/Dockerfile"; then
        mv "$dir" ./denied-apk/
    fi
    if [ -f "$dir/Dockerfile" ] && grep -q "FROM ghcr.io/linuxserver/" "$dir/Dockerfile"; then
        mv "$dir" ./denied-from/
    fi

done
