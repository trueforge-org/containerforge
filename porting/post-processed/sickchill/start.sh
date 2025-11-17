#!/usr/bin/env bash




# create symlinks
sitepackages=$(python -c "import site; print(site.getsitepackages()[0])")

symlinks=(
    "${sitepackages}"/sickchill/gui/slick/cache
)
for i in "${symlinks[@]}"; do
    rm -rf "$i"
    ln -s /config/"$(basename "$i")" "$i"
done

# permissions
echo "Setting permissions"

    /config





exec \
    
     python3 /lsiopy/bin/SickChill --datadir /config

