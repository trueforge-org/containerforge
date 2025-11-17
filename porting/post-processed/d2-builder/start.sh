#!/usr/bin/env bash




set -e

IFS="|" read -r -a CLI_OPTIONS <<< "$CLI_OPTIONS_STRING"
IMAGENAME=${CLI_OPTIONS[0]%%:*}
if [[ ${CLI_OPTIONS[0]} == *":"* ]]; then
    TAGNAME=${CLI_OPTIONS[0]##*:}
else
    TAGNAME="latest"
fi

if [[ -n ${LOCAL} ]]; then
    OUTPUTNAME="${IMAGENAME}-${TAGNAME}-LOCAL.d2"
else
    OUTPUTNAME="${IMAGENAME}-${TAGNAME}.d2"
fi

mkdir -p "/work/merge"

if [[ ! ${IMAGENAME} == "baseimage"* ]]; then
    if [[ -n ${LOCAL} ]]; then
        mkdir -p "/tmp/${IMAGENAME}"
        cp -R "/input/docker-${IMAGENAME}/"* "/tmp/${IMAGENAME}/"
    else
        git clone --depth=1 "https://github.com/linuxserver/docker-${IMAGENAME}" "/tmp/${IMAGENAME}"
        IMAGEBRANCH=$(grep -Po "/tmp/${IMAGENAME}/jenkins-vars.yml" -e "^release_tag: \K(.*)$" | tr -d '"')
        if [[ "${IMAGEBRANCH}" != "${TAGNAME}" ]]; then
            cd "/tmp/${IMAGENAME}" || exit
            git remote set-branches origin "${TAGNAME}"
            git fetch --depth=1
            git checkout "${TAGNAME}"
        fi
    fi

    BASEIMAGE=$(grep "/tmp/${IMAGENAME}/Dockerfile" -e "^FROM" | tail -l)
    BASEIMAGE=${BASEIMAGE##*/}
    BASEIMAGENAME=${BASEIMAGE%%:*}
    BASEIMAGETAG=${BASEIMAGE##*:}

    BASELIST="\"${BASEIMAGE}\""
else
    BASEIMAGENAME=${IMAGENAME}
    BASEIMAGETAG=${TAGNAME}
fi

if [[ ${BASEIMAGENAME} =~ "baseimage" ]]; then
    if [[ -n ${LOCAL} ]]; then
        mkdir -p "/tmp/${BASEIMAGENAME}"
        cp -R "/input/docker-${BASEIMAGENAME}/"* "/tmp/${BASEIMAGENAME}/"
    else
        git clone --depth=1 "https://github.com/linuxserver/docker-${BASEIMAGENAME}" "/tmp/${BASEIMAGENAME}"
        BASEBRANCH=$(grep -Po "/tmp/${BASEIMAGENAME}/jenkins-vars.yml" -e "^release_tag: \K(.*)$" | tr -d '"')
        if [[ "${BASEBRANCH}" != "${BASEIMAGETAG}" ]]; then
            cd "/tmp/${BASEIMAGENAME}" || exit
            git remote set-branches origin "${BASEIMAGETAG}"
            git fetch --depth=1
            git checkout "${BASEIMAGETAG}"
        fi
    fi
fi

BASEIMAGE=$(grep "/tmp/${BASEIMAGENAME}/Dockerfile" -e "^FROM" | tail -1)
BASEIMAGE=${BASEIMAGE##*/}
BASEIMAGENAME=${BASEIMAGE%%:*}
BASEIMAGETAG=${BASEIMAGE##*:}

while [[ ${BASEIMAGENAME} =~ "baseimage" ]]; do
    if [[ -n ${BASELIST} ]]; then
        BASELIST="${BASELIST} <- \"${BASEIMAGE}\""
    else
        BASELIST="\"${BASEIMAGE}\""
    fi
    if [[ -n ${LOCAL} ]]; then
        mkdir -p "/tmp/${BASEIMAGENAME}"
        cp -R "/input/docker-${BASEIMAGENAME}/"* "/tmp/${BASEIMAGENAME}/"
    else
        git clone --depth=1 "https://github.com/linuxserver/docker-${BASEIMAGENAME}" "/tmp/${BASEIMAGENAME}"
        BASEBRANCH=$(grep -Po "/tmp/${BASEIMAGENAME}/jenkins-vars.yml" -e "^release_tag: \K(.*)$" | tr -d '"')
        if [[ "${BASEBRANCH}" != "${BASEIMAGETAG}" ]]; then
            cd "/tmp/${BASEIMAGENAME}" || exit
            git remote set-branches origin "${BASEIMAGETAG}"
            git fetch --depth=1
            git checkout "${BASEIMAGETAG}"
        fi
    fi
    BASEIMAGE=$(grep "/tmp/${BASEIMAGENAME}/Dockerfile" -e "^FROM" | tail -1)
    BASEIMAGE=${BASEIMAGE##*/}
    BASEIMAGENAME=${BASEIMAGE%%:*}
    BASEIMAGETAG=${BASEIMAGE##*:}
done

for i in /tmp/*; do
    if [[ -d "${i}/root" ]];then
        cp -R "${i}/root" "/work/merge"
    fi
done

shopt -s globstar

if [[ -z ${RAW} ]]; then
cat <<EOF > "/output/${OUTPUTNAME}"
vars: {
  d2-config: {
    layout-engine: elk
    theme-id: 1
    dark-theme-id: 200
  }
}

EOF
fi

echo "\"${IMAGENAME}:${TAGNAME}\": {" >> "/output/${OUTPUTNAME}"

cat <<EOF >> "/output/${OUTPUTNAME}"
  docker-mods
  base {
    fix-attr +\nlegacy cont-init
  }
  docker-mods -> base
  legacy-services
  custom services
  init-services -> legacy-services
  init-services -> custom services
  custom services -> legacy-services
EOF

for i in /work/merge/root/etc/s6-overlay/s6-rc.d/*; do
    if [[ ! $(basename "${i}") == "user"* ]]; then
        if [[ ! -d /work/merge/root/etc/s6-overlay/s6-rc.d/$(basename "${i}")/dependencies.d ]]; then
            echo "  base -> $(basename "${i}")" >> "/output/${OUTPUTNAME}"
        else
            for d in "/work/merge/root/etc/s6-overlay/s6-rc.d/$(basename "${i}")/dependencies.d/"*; do
                echo "  $(basename "${d}") -> $(basename "${i}")" >> "/output/${OUTPUTNAME}"
            done
        fi
        if [[ $(basename "${i}") == "svc-"* ]]; then
            echo "  $(basename "${i}") -> legacy-services" >> "/output/${OUTPUTNAME}"
        fi
    fi
done

echo "}" >> "/output/${OUTPUTNAME}"

if [[ -n ${BASELIST} ]]; then
cat <<EOF >> "/output/${OUTPUTNAME}"
Base Images: {
  ${BASELIST}
}
"${IMAGENAME}:${TAGNAME}" <- Base Images
EOF
fi

shopt -u globstar


    /output \
    "/output/${OUTPUTNAME}"





IFS="|" read -r -a CLI_OPTIONS <<< "$CLI_OPTIONS_STRING"
IMAGENAME=${CLI_OPTIONS[0]%%:*}
if [[ ${CLI_OPTIONS[0]} == *":"* ]]; then
    TAGNAME=${CLI_OPTIONS[0]##*:}
else
    TAGNAME="latest"
fi

if [[ -n ${LOCAL} ]]; then
    OUTPUTNAME="${IMAGENAME}-${TAGNAME}-LOCAL"
else
    OUTPUTNAME="${IMAGENAME}-${TAGNAME}"
fi

if [[ -z ${RAW} ]]; then
     d2 "/output/${OUTPUTNAME}.d2" "/output/${OUTPUTNAME}.svg"
    chmod 644 "/output/${OUTPUTNAME}.d2" "/output/${OUTPUTNAME}.svg"
else
    chmod 644 "/output/${OUTPUTNAME}.d2"
fi

