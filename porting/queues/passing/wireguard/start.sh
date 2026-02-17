#!/usr/bin/env bash


mkdir -p /config/wg_confs

# migration to subfolder for wg confs
if [[ -z "$(ls -A /config/wg_confs)" ]] && [[ -f /config/wg0.conf ]]; then
    echo "**** Performing migration to new folder structure for confs. Please see the image changelog 2023-10-03 entry for more details. ****"
    cp /config/wg0.conf /config/wg_confs/wg0.conf
    rm -rf /config/wg0.conf || :
fi

# prepare templates
if [[ ! -f /config/templates/server.conf ]]; then
    cp /defaults/server.conf /config/templates/server.conf
fi
if [[ ! -f /config/templates/peer.conf ]]; then
    cp /defaults/peer.conf /config/templates/peer.conf
fi
# add preshared key to user templates (backwards compatibility)
if ! grep -q 'PresharedKey' /config/templates/peer.conf; then
    sed -i 's|^Endpoint|PresharedKey = \$\(cat /config/\${PEER_ID}/presharedkey-\${PEER_ID}\)\nEndpoint|' /config/templates/peer.conf
fi

generate_confs () {
    mkdir -p /config/server
    if [[ ! -f /config/server/privatekey-server ]]; then
        umask 077
        wg genkey | tee /config/server/privatekey-server | wg pubkey > /config/server/publickey-server
    fi
    eval "$(printf %s)
    cat <<DUDE > /config/wg_confs/wg0.conf
$(cat /config/templates/server.conf)

DUDE"
    for i in "${PEERS_ARRAY[@]}"; do
        if [[ ! "${i}" =~ ^[[:alnum:]]+$ ]]; then
            echo "**** Peer ${i} contains non-alphanumeric characters and thus will be skipped. No config for peer ${i} will be generated. ****"
        else
            if [[ "${i}" =~ ^[0-9]+$ ]]; then
                PEER_ID="peer${i}"
            else
                PEER_ID="peer_${i}"
            fi
            mkdir -p "/config/${PEER_ID}"
            if [[ ! -f "/config/${PEER_ID}/privatekey-${PEER_ID}" ]]; then
                umask 077
                wg genkey | tee "/config/${PEER_ID}/privatekey-${PEER_ID}" | wg pubkey > "/config/${PEER_ID}/publickey-${PEER_ID}"
                wg genpsk > "/config/${PEER_ID}/presharedkey-${PEER_ID}"
            fi
            if [[ -f "/config/${PEER_ID}/${PEER_ID}.conf" ]]; then
                CLIENT_IP=$(grep "Address" "/config/${PEER_ID}/${PEER_ID}.conf" | awk '{print $NF}')
                if [[ -n "${ORIG_INTERFACE}" ]] && [[ "${INTERFACE}" != "${ORIG_INTERFACE}" ]]; then
                    CLIENT_IP="${CLIENT_IP//${ORIG_INTERFACE}/${INTERFACE}}"
                fi
            else
                for idx in {2..254}; do
                PROPOSED_IP="${INTERFACE}.${idx}"
                if ! grep -q -R "${PROPOSED_IP}" /config/peer*/*.conf 2>/dev/null && ([[ -z "${ORIG_INTERFACE}" ]] || ! grep -q -R "${ORIG_INTERFACE}.${idx}" /config/peer*/*.conf 2>/dev/null); then
                    CLIENT_IP="${PROPOSED_IP}"
                    break
                fi
                done
            fi
            if [[ -f "/config/${PEER_ID}/presharedkey-${PEER_ID}" ]]; then
                # create peer conf with presharedkey
                eval "$(printf %s)
                cat <<DUDE > /config/${PEER_ID}/${PEER_ID}.conf
$(cat /config/templates/peer.conf)
DUDE"
                # add peer info to server conf with presharedkey
                cat <<DUDE >> /config/wg_confs/wg0.conf
[Peer]
# ${PEER_ID}
PublicKey = $(cat "/config/${PEER_ID}/publickey-${PEER_ID}")
PresharedKey = $(cat "/config/${PEER_ID}/presharedkey-${PEER_ID}")
DUDE
            else
                echo "**** Existing keys with no preshared key found for ${PEER_ID}, creating confs without preshared key for backwards compatibility ****"
                # create peer conf without presharedkey
                eval "$(printf %s)
                cat <<DUDE > /config/${PEER_ID}/${PEER_ID}.conf
$(sed '/PresharedKey/d' "/config/templates/peer.conf")
DUDE"
                # add peer info to server conf without presharedkey
                cat <<DUDE >> /config/wg_confs/wg0.conf
[Peer]
# ${PEER_ID}
PublicKey = $(cat "/config/${PEER_ID}/publickey-${PEER_ID}")
DUDE
            fi
            SERVER_ALLOWEDIPS=SERVER_ALLOWEDIPS_PEER_${i}
            # add peer's allowedips to server conf
            if [[ -n "${!SERVER_ALLOWEDIPS}" ]]; then
                echo "Adding ${!SERVER_ALLOWEDIPS} to wg0.conf's AllowedIPs for peer ${i}"
                cat <<DUDE >> /config/wg_confs/wg0.conf
AllowedIPs = ${CLIENT_IP}/32,${!SERVER_ALLOWEDIPS}
DUDE
            else
                cat <<DUDE >> /config/wg_confs/wg0.conf
AllowedIPs = ${CLIENT_IP}/32
DUDE
            fi
            # add PersistentKeepalive if the peer is specified
            if [[ -n "${PERSISTENTKEEPALIVE_PEERS_ARRAY}" ]] && ([[ "${PERSISTENTKEEPALIVE_PEERS_ARRAY[0]}" = "all" ]] || printf '%s\0' "${PERSISTENTKEEPALIVE_PEERS_ARRAY[@]}" | grep -Fxqz -- "${i}"); then
                cat <<DUDE >> /config/wg_confs/wg0.conf
PersistentKeepalive = 25

DUDE
            else
                cat <<DUDE >> /config/wg_confs/wg0.conf

DUDE
            fi
            if [[ -z "${LOG_CONFS}" ]] || [[ "${LOG_CONFS}" = "true" ]]; then
                echo "PEER ${i} QR code (conf file is saved under /config/${PEER_ID}):"
                qrencode -t ansiutf8 < "/config/${PEER_ID}/${PEER_ID}.conf"
            else
                echo "PEER ${i} conf and QR code png saved in /config/${PEER_ID}"
            fi
            qrencode -o "/config/${PEER_ID}/${PEER_ID}.png" < "/config/${PEER_ID}/${PEER_ID}.conf"
        fi
    done
}

save_vars () {
    cat <<DUDE > /config/.donoteditthisfile
ORIG_SERVERURL="$SERVERURL"
ORIG_SERVERPORT="$SERVERPORT"
ORIG_PEERDNS="$PEERDNS"
ORIG_PEERS="$PEERS"
ORIG_INTERFACE="$INTERFACE"
ORIG_ALLOWEDIPS="$ALLOWEDIPS"
ORIG_PERSISTENTKEEPALIVE_PEERS="$PERSISTENTKEEPALIVE_PEERS"
DUDE
}

if [[ -n "$PEERS" ]]; then
    echo "**** Server mode is selected ****"
    if [[ "$PEERS" =~ ^[0-9]+$ ]] && ! [[ "$PEERS" = *,* ]]; then
        mapfile -t PEERS_ARRAY < <(seq 1 "${PEERS}")
    else
        mapfile -t PEERS_ARRAY < <(echo "${PEERS}" | tr ',' '\n')
    fi
    if [[ -n "${PERSISTENTKEEPALIVE_PEERS}" ]]; then
        echo "**** PersistentKeepalive will be set for: ${PERSISTENTKEEPALIVE_PEERS/,/ } ****"
        mapfile -t PERSISTENTKEEPALIVE_PEERS_ARRAY < <(echo "${PERSISTENTKEEPALIVE_PEERS}" | tr ',' '\n')
    fi
    if [[ -z "$SERVERURL" ]] || [[ "$SERVERURL" = "auto" ]]; then
        SERVERURL=$(curl -s icanhazip.com)
        echo "**** SERVERURL var is either not set or is set to \"auto\", setting external IP to auto detected value of $SERVERURL ****"
    else
        echo "**** External server address is set to $SERVERURL ****"
    fi
    SERVERPORT=${SERVERPORT:-51820}
    echo "**** External server port is set to ${SERVERPORT}. Make sure that port is properly forwarded to port 51820 inside this container ****"
    INTERNAL_SUBNET=${INTERNAL_SUBNET:-10.13.13.0}
    echo "**** Internal subnet is set to $INTERNAL_SUBNET ****"
    INTERFACE=$(echo "$INTERNAL_SUBNET" | awk 'BEGIN{FS=OFS="."} NF--')
    ALLOWEDIPS=${ALLOWEDIPS:-0.0.0.0/0, ::/0}
    echo "**** AllowedIPs for peers $ALLOWEDIPS ****"
    if [[ -z "$PEERDNS" ]] || [[ "$PEERDNS" = "auto" ]]; then
        PEERDNS="${INTERFACE}.1"
        echo "**** PEERDNS var is either not set or is set to \"auto\", setting peer DNS to ${INTERFACE}.1 to use wireguard docker host's DNS. ****"
    else
        echo "**** Peer DNS servers will be set to $PEERDNS ****"
    fi
    if [[ ! -f /config/wg_confs/wg0.conf ]]; then
        echo "**** No wg0.conf found (maybe an initial install), generating 1 server and ${PEERS} peer/client confs ****"
        generate_confs
        save_vars
    else
        echo "**** Server mode is selected ****"
        if [[ -f /config/.donoteditthisfile ]]; then
            . /config/.donoteditthisfile
        fi
        if [[ "$SERVERURL" != "$ORIG_SERVERURL" ]] || [[ "$SERVERPORT" != "$ORIG_SERVERPORT" ]] || [[ "$PEERDNS" != "$ORIG_PEERDNS" ]] || [[ "$PEERS" != "$ORIG_PEERS" ]] || [[ "$INTERFACE" != "$ORIG_INTERFACE" ]] || [[ "$ALLOWEDIPS" != "$ORIG_ALLOWEDIPS" ]] || [[ "$PERSISTENTKEEPALIVE_PEERS" != "$ORIG_PERSISTENTKEEPALIVE_PEERS" ]]; then
            echo "**** Server related environment variables changed, regenerating 1 server and ${PEERS} peer/client confs ****"
            generate_confs
            save_vars
        else
            echo "**** No changes to parameters. Existing configs are used. ****"
        fi
    fi
else
    echo "**** Client mode selected. ****"
    USE_COREDNS="${USE_COREDNS,,}"
    printf %s "${USE_COREDNS:-false}" > /run/s6/container_environment/USE_COREDNS
fi

# set up CoreDNS
if [[ ! -f /config/coredns/Corefile ]]; then
    cp /defaults/Corefile /config/coredns/Corefile
fi

mkdir -p /config/{templates,coredns}

echo "Uname info: $(uname -a)"
# check for wireguard module
ip link del dev test 2>/dev/null
if ip link add dev test type wireguard; then
    ip link del dev test
    if capsh --current | grep "Current:" | grep -q "cap_sys_module"; then
        echo "**** As the wireguard module is already active you can remove the SYS_MODULE capability from your container run/compose. ****"
        echo "****     If your host does not automatically load the iptables module, you may still need the SYS_MODULE capability.     ****"
    fi
else
    echo "**** The wireguard module is not active. If you believe that your kernel should have wireguard support already, make sure that it is activated via modprobe! ****"
    sleep infinity
fi

if netstat -apn | grep -q ":53 " && [[ -z "${USE_COREDNS}" ]]; then
    USE_COREDNS="false"
fi

if [[ ${USE_COREDNS} == "false" ]]; then

        sleep infinity
else
    if grep -q "health" /config/coredns/Corefile; then
        exec \

            cd /config/coredns \
            /usr/bin/coredns -dns.port=53
    else
        exec \

            cd /config/coredns \
            /usr/bin/coredns -dns.port=53
    fi
fi

unset WG_CONFS
rm -rf /run/activeconfs
# Enumerate interfaces
for wgconf in /config/wg_confs/*.conf; do
    if grep -q "\[Interface\]" "${wgconf}"; then
        echo "**** Found WG conf ${wgconf}, adding to list ****"
        WG_CONFS+=("${wgconf}")
    else
        echo "**** Found WG conf ${wgconf}, but it doesn't seem to be valid, skipping. ****"
    fi
done

if [[ -z "${WG_CONFS[*]}" ]]; then
    echo "**** No valid tunnel config found. Please create a valid config and restart the container ****"
    ip route del default
    exit 0
fi

unset FAILED
for tunnel in "${WG_CONFS[@]}"; do
    echo "**** Activating tunnel ${tunnel} ****"
    if ! wg-quick up "${tunnel}"; then
        FAILED="${tunnel}"
        break
    fi
done

if [[ -z "${FAILED}" ]]; then
    declare -p WG_CONFS > /run/activeconfs
    echo "**** All tunnels are now active ****"
else
    echo "**** Tunnel ${FAILED} failed, will stop all others! ****"
    for tunnel in "${WG_CONFS[@]}"; do
        if [[ "${tunnel}" = "${FAILED}" ]]; then
            break
        else
            echo "**** Disabling tunnel ${tunnel} ****"
            wg-quick down "${tunnel}" || :
        fi
    done
    ip route del default
    echo "**** All tunnels are now down. Please fix the tunnel config ${FAILED} and restart the container ****"
fi

## TODO: figure out exec
