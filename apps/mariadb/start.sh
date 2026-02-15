#!/usr/bin/env bash


# make folders if required
mkdir -p \
    "${DATADIR}" \
    /config/log/mysql \
    /run/mysqld

# copy custom cnf file
if [[ ! -f /config/custom.cnf ]]; then
    cp /defaults/custom.cnf /config/custom.cnf
fi

# remove orphan pid file
if [[ -f /run/mysqld/mysqld.pid ]]; then
    rm -f /run/mysqld/mysqld.pid
fi


# set start function used later
start_mariadb() {
    mariadbd --datadir="${DATADIR}" --init-file="${tempSqlFile}" --pid-file=/run/mysqld/mysqld.pid --user=apps &
    pid="$!"
    RET=1
    while [[ ${RET} -ne 0 ]]; do
        mariadb -uroot -e "status" >/dev/null 2>&1
        RET=$?
        sleep 1
    done
}

# test for existence of mysql folder in datadir and start initialise if not present
if [[ ! -d "${DATADIR}/mysql" ]]; then
    # load env file if it exists
    if [[ -f "/config/env" ]]; then

        source /config/env
    fi

    # make temp sql init file
    tempSqlFile=$(mktemp)

    # set basic sql command
    cat >"${tempSqlFile}" <<-EOSQL
DELETE FROM mysql.user WHERE user <> 'mariadb.sys' AND user <> 'root';
EOSQL

    if [[ "${#MYSQL_ROOT_PASSWORD}" -lt "4" ]]; then
        MYSQL_PASS="CREATE USER 'root'@'%' IDENTIFIED BY '' ;"
    else
        MYSQL_PASS="CREATE USER 'root'@'%' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}' ;"
    fi

    # Make sure all user and database settings are set and pass is more than 4 characters
    # At the end change to default database created with environment variables to run init and remote scripts there
    if [[ "${MYSQL_USER+x}" ]] &&
        [[ "${MYSQL_DATABASE+x}" ]] &&
        [[ "${MYSQL_PASSWORD+x}" ]] &&
        [[ "${#MYSQL_PASSWORD}" -gt "3" ]]; then
        read -r -d '' MYSQL_DB_SETUP <<-EOM
CREATE DATABASE \`${MYSQL_DATABASE}\`;
CREATE USER '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
USE \`${MYSQL_DATABASE}\`;
EOM
    fi

    # add rest of sql commands based on password set or not
    cat >>"${tempSqlFile}" <<-EONEWSQL
$MYSQL_PASS
GRANT ALL ON *.* TO 'root'@'%' WITH GRANT OPTION ;
DROP DATABASE IF EXISTS test ;
$MYSQL_DB_SETUP
EONEWSQL

    echo "Setting Up Initial Databases"

    # add all sql from a user defined directory on first init
    if [[ -e "/config/initdb.d" ]] && [[ -n "$(/bin/ls -A /config/initdb.d/*.sql 2>/dev/null)" ]]; then
        cat /config/initdb.d/*.sql >>"${tempSqlFile}"
    fi

    # ingest remote sql if REMOTE_SQL is set
    if [[ -n "${REMOTE_SQL+set}" ]]; then
        IFS=, read -ra URLS <<<"${REMOTE_SQL}"
        for URL in "${URLS[@]}"; do
            if [[ "$(curl -I -sL -w "%{http_code}" "${URL}" -o /dev/null)" == 200 ]]; then
                curl -sL "${URL}" >>"${tempSqlFile}"
            fi
        done
    fi

        chmod -R 777 /config/log/mysql /run/mysqld

    # initialise database structure

        mariadb-install-db --datadir="${DATADIR}" --user=apps --auth-root-authentication-method=normal

    # start mariadb and apply our sql commands we set above
    start_mariadb

    # shut down after apply sql commands, waiting for pid to stop
    mariadb-admin -u root shutdown
    wait "${pid}"
    echo "Database Setup Completed"

    # display a message about password if not set or too short
    if [[ "${#MYSQL_ROOT_PASSWORD}" -lt "4" ]]; then
        cat <<-EOFPASS



#################################################################
# No root password or too short a password, min of 4 characters #
#    No root password will be set, this is not a good thing     #
#   You shoud set one after initialisation with the commands:   #
#                           mariadb                             #
#      ALTER USER 'root'@'%' IDENTIFIED BY 'MyN3wP4ssw0rd';     #
#                      flush privileges;                        #
#################################################################



EOFPASS

        sleep 5s
    fi

    # clean up any old install files from /tmp
    rm -f "${tempSqlFile}"
fi

# check logrotate permissions
if mariadb-admin -uroot --local version >/dev/null 2>&1; then
    echo "Logrotate is enabled"
else
    cat <<-EOFPASS



#####################################################################################
#                                                                                   #
#                             Logrotate Instructions                                #
#                                                                                   #
#               Add the following to /config/custom.cnf under [mysqld]:             #
#                  log_error = /config/log/mysql/mariadb-error.log                  #
#                                                                                   #
#                 Login to the SQL shell inside the container using:                #
#                           mariadb -uroot -p<PASSWORD>                             #
#                          And run the following command:                           #
# GRANT ALL ON *.* TO root@localhost IDENTIFIED VIA unix_socket WITH GRANT OPTION ; #
#                                                                                   #
#                     Restart the container to apply the changes.                   #
#                                                                                   #
#              You can read more about root@localhost permissions here:             #
#             https://mariadb.com/kb/en/authentication-from-mariadb-10-4/           #
#                                                                                   #
#####################################################################################



EOFPASS
fi

# check for upgrades
if [[ "${#MYSQL_ROOT_PASSWORD}" -gt "3" ]]; then
    # display a message about upgrading database if needed
    if mariadb-upgrade -u root -p"${MYSQL_ROOT_PASSWORD}" --check-if-upgrade-is-needed >/dev/null 2>&1; then
        cat <<-EOF



#################################################################
#                                                               #
#           An upgrade is required on your databases.           #
#                                                               #
#         Stop any services that are accessing databases        #
#          in this container, and then run the command          #
#                                                               #
#                   mariadb-upgrade -u root                     #
#                                                               #
#################################################################



EOF
        sleep 5s
    fi
fi
/usr/bin/mariadbd-safe \
        --defaults-extra-file=/config/custom.cnf \
        --datadir="${DATADIR}" \
        --pid-file=/run/mysqld/mysqld.pid \
        --skip-networking=OFF \
        --user=apps &

    wait
