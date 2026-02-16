mkdir -p ./denied-apt-get ./denied-from ./denied-root ./good ./denied-dockerlines ./denied-startlines

for dir in ./post-processed/*/; do
    startlines=0
    dockerlines=0
    [ -f "$dir/start.sh" ] && startlines=$(wc -l < "$dir/start.sh")
    [ -f "$dir/Dockerfile" ] && dockerlines=$(wc -l < "$dir/Dockerfile")

    if [ -f "$dir/Dockerfile" ] && grep -q "apt-get " "$dir/Dockerfile"; then
        mv "$dir" ./denied-apt-get/
    elif [ -f "$dir/Dockerfile" ] && grep -q "FROM ghcr.io/linuxserver/" "$dir/Dockerfile"; then
        mv "$dir" ./denied-from/
    elif [ -d "$dir/root" ]; then
        mv "$dir" ./denied-root/
    elif [ "$startlines" -gt 100 ]; then
        mv "$dir" ./denied-startlines/
    elif [ "$dockerlines" -gt 150 ]; then
        mv "$dir" ./denied-dockerlines/
    else
        mv "$dir" ./good/
    fi
done
