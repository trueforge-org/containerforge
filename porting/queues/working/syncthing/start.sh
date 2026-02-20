#!/usr/bin/env bash





exec \

         syncthing \
        --home=/config --no-browser --no-restart \
        --gui-address="0.0.0.0:8384"

