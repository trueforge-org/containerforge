#!/usr/bin/env bash


if [[ -n "${ACCOUNT_TOKEN}" ]] && [[ -n "${MACHINE_NAME}" ]]; then
    TOKEN_AND_NAME="--account-token ${ACCOUNT_TOKEN} --machine-name ${MACHINE_NAME}"
else
    echo '
***************************************************************************
***************************************************************************
****                                                                   ****
****                                                                   ****
****    On first run, both the ACCOUNT_TOKEN and the MACHINE_NAME      ****
**** env vars are required. Please set them and recreate the container ****
****    unless the instance was previously added to online account.    ****
****                                                                   ****
****                                                                   ****
***************************************************************************
***************************************************************************
'
fi

cd /config
exec fah-client \
            --http-addresses 0.0.0.0:7396 --allow 0/0 ${TOKEN_AND_NAME} \
            ${CLI_ARGS} $"$@"

