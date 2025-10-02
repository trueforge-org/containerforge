#!/usr/bin/env bash

unset UV_SYSTEM_PYTHON

mkdir -p "${VENV_FOLDER}"
uv venv --system-site-packages --link-mode=copy --allow-existing "${VENV_FOLDER}"
source "${VENV_FOLDER}/bin/activate"

site_packages=$(python -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())")
uv pip install --no-index --find-links="${site_packages}" uv

ln -sf /proc/self/fd/1 /config/home-assistant.log

exec \
    python3 -m homeassistant \
        --config /config \
        "$@"
