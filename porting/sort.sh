mkdir -p ./denied-apk ./denied-from ./denied-root ./good ./denied-dockerlines/  ./denied-startlines/

for dir in ./post-processed/*/; do
startlines=$(wc -l < "$dir/start.sh")
dockerlines=$(wc -l < "$dir/Dockerfile")
# Check if more than 200
    if [ -f "$dir/Dockerfile" ] && grep -q "apk " "$dir/Dockerfile"; then
        mv "$dir" ./denied-apk/
    elif [ -f "$dir/Dockerfile" ] && grep -q "FROM ghcr.io/linuxserver/" "$dir/Dockerfile"; then
        mv "$dir" ./denied-from/
    elif [ -d "$dir/root" ]; then
        mv "$dir" ./denied-root/
    elif [ "$startlines" -gt 100 ]; then
        mv "$dir" ./denied-dockerlines/
    elif [ "$dockerlines" -gt 150 ]; then
        mv "$dir" ./denied-startlines/
    else
        mv "$dir" ./good/
fi
done
