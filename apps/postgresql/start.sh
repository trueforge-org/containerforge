#!/usr/bin/env bash
set -Eeo pipefail
# TODO swap to -Eeuo pipefail above (after handling all potentially-unset variables)

check_writeable() {
    echo "Checking main dir write..."
    echo "PGDATA set to ${PGDATA}"
    echo "Data root folder is set to $PGDATA_PARENT, testing write access..."

    local testfile="$PGDATA_PARENT/.write_test_$$"

    if ! touch "$testfile" 2>/dev/null; then
        echo "Error: Cannot write to '$PGDATA_PARENT'" >&2
        return 1
    fi

    rm -f "$testfile"
    echo "Parent directory is writable."
}

# used to create initial postgres directories
docker_create_db_directories() {

    # Create PGDATA directory
    mkdir -p "$PGDATA" || :
    chmod 00700 "$PGDATA" || :

    chmod 03775 "/var/run/postgresql" || :

    local testfile="$PGDATA/.write_test_$$"

    if ! touch "$testfile" 2>/dev/null; then
        echo "Error: PGDATA directory '$PGDATA' is not writable" >&2
        return 1
    fi

    rm -f "$testfile"
    echo "PGDATA directory is writable."

    if [ -n "${POSTGRES_INITDB_WALDIR:-}" ]; then
        mkdir -p "$POSTGRES_INITDB_WALDIR"
        chmod 700 "$POSTGRES_INITDB_WALDIR"
    fi
}


docker_init_database_dir() {
	local uid; uid="$(id -u)"
	if ! getent passwd "$uid" &> /dev/null; then
		local wrapper
		for wrapper in {/usr,}/lib{/*,}/libnss_wrapper.so; do
			if [ -s "$wrapper" ]; then
				NSS_WRAPPER_PASSWD="$(mktemp)"
				NSS_WRAPPER_GROUP="$(mktemp)"
				export LD_PRELOAD="$wrapper" NSS_WRAPPER_PASSWD NSS_WRAPPER_GROUP
				local gid; gid="$(id -g)"
				printf 'postgres:x:%s:%s:PostgreSQL:%s:/bin/false\n' "$uid" "$gid" "$PGDATA" > "$NSS_WRAPPER_PASSWD"
				printf 'postgres:x:%s:\n' "$gid" > "$NSS_WRAPPER_GROUP"
				break
			fi
		done
	fi

	if [ -n "${POSTGRES_INITDB_WALDIR:-}" ]; then
		set -- --waldir "$POSTGRES_INITDB_WALDIR" "$@"
	fi

	eval 'initdb --username="$POSTGRES_USER" --pwfile=<(printf "%s\n" "$POSTGRES_PASSWORD") '"$POSTGRES_INITDB_ARGS"' "$@"'

	if [[ "${LD_PRELOAD:-}" == */libnss_wrapper.so ]]; then
		rm -f "$NSS_WRAPPER_PASSWD" "$NSS_WRAPPER_GROUP"
		unset LD_PRELOAD NSS_WRAPPER_PASSWD NSS_WRAPPER_GROUP
	fi
}

docker_verify_minimum_env() {
	if [ -z "$POSTGRES_PASSWORD" ] && [ 'trust' != "$POSTGRES_HOST_AUTH_METHOD" ]; then
		cat >&2 <<-'EOE'
			Error: Database is uninitialized and superuser password is not specified.
		EOE
		exit 1
	fi
	if [ 'trust' = "$POSTGRES_HOST_AUTH_METHOD" ]; then
		cat >&2 <<-'EOWARN'
			WARNING: POSTGRES_HOST_AUTH_METHOD has been set to "trust".
		EOWARN
	fi
}

docker_process_init_files() {
	psql=( docker_process_sql )

	printf '\n'
	local f
	for f; do
		case "$f" in
			*.sh)
				if [ -x "$f" ]; then
					printf '%s: running %s\n' "$0" "$f"
					"$f"
				else
					printf '%s: sourcing %s\n' "$0" "$f"
					. "$f"
				fi
				;;
			*.sql)     printf '%s: running %s\n' "$0" "$f"; docker_process_sql -f "$f"; printf '\n' ;;
			*.sql.gz)  printf '%s: running %s\n' "$0" "$f"; gunzip -c "$f" | docker_process_sql; printf '\n' ;;
			*.sql.xz)  printf '%s: running %s\n' "$0" "$f"; xzcat "$f" | docker_process_sql; printf '\n' ;;
			*.sql.zst) printf '%s: running %s\n' "$0" "$f"; zstd -dc "$f" | docker_process_sql; printf '\n' ;;
			*)         printf '%s: ignoring %s\n' "$0" "$f" ;;
		esac
		printf '\n'
	done
}

docker_process_sql() {
	local query_runner=( psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --no-password --no-psqlrc )
	if [ -n "$POSTGRES_DB" ]; then
		query_runner+=( --dbname "$POSTGRES_DB" )
	fi

	PGHOST= PGHOSTADDR= "${query_runner[@]}" "$@"
}

docker_setup_db() {
	local dbAlreadyExists
	dbAlreadyExists="$(
		POSTGRES_DB= docker_process_sql --dbname postgres --set db="$POSTGRES_DB" --tuples-only <<-'EOSQL'
			SELECT 1 FROM pg_database WHERE datname = :'db' ;
		EOSQL
	)"
	if [ -z "$dbAlreadyExists" ]; then
		POSTGRES_DB= docker_process_sql --dbname postgres --set db="$POSTGRES_DB" <<-'EOSQL'
			CREATE DATABASE :"db" ;
		EOSQL
		printf '\n'
	fi
}

docker_setup_env() {
	: "${POSTGRES_USER:=postgres}"
	: "${PGUSER:=$POSTGRES_USER}"
	: "${POSTGRES_DB:=$POSTGRES_USER}"
	: "${POSTGRES_INITDB_ARGS:=}"
	: "${POSTGRES_HOST_AUTH_METHOD:=}"
    : "${POSTGRES_PASSWORD:=$POSTGRES_USER}"
    : "${POSTGRES_CHECKSUMS:="true"}"

	declare -g DATABASE_ALREADY_EXISTS
	: "${DATABASE_ALREADY_EXISTS:=}"
}

pg_setup_hba_conf() {
	if [ "$1" = 'postgres' ]; then
		shift
	fi
	local auth
	auth="$(postgres -C password_encryption "$@")"
	: "${POSTGRES_HOST_AUTH_METHOD:=$auth}"
	{
		printf '\n'
		if [ 'trust' = "$POSTGRES_HOST_AUTH_METHOD" ]; then
			printf '# warning trust is enabled for all connections\n'
		fi
		printf 'host all all all %s\n' "$POSTGRES_HOST_AUTH_METHOD"
	} >> "$PGDATA/pg_hba.conf"
}

set_checksums() {
  # Determine current checksum status via exit code
  if pg_checksums --check >/dev/null 2>&1; then
    STATUS="enabled"
  else
    STATUS="disabled"
  fi
  echo "Checking checksums setting..."
  echo "Checksums enabled set to: $POSTGRES_CHECKSUMS"
  echo "Checking DB checksum setting..."
  # Enable or disable if needed
  if [[ "$POSTGRES_CHECKSUMS" == "true" && "$STATUS" == "disabled" ]]; then
    pg_checksums --enable -P
    echo "Not set, Checksums now enabled."
  elif [[ "$POSTGRES_CHECKSUMS" == "false" && "$STATUS" == "enabled" ]]; then
    pg_checksums --disable -P
    echo "Set, Checksums now disabled."
  else
    echo "Checksums setting match."
  fi
}

docker_temp_server_start() {
	if [ "$1" = 'postgres' ]; then
		shift
	fi
	set -- "$@" -c listen_addresses='' -p "${PGPORT:-5432}"
	NOTIFY_SOCKET= \
	PGUSER="${PGUSER:-$POSTGRES_USER}" \
	pg_ctl -D "$PGDATA" \
		-o "$(printf '%q ' "$@")" \
		-w start
}

create_additional_dbs() {
    if [[ -z "$ADDITIONAL_DBS" ]]; then
        echo "No additional databases specified in ADDITIONAL_DBS."
        return 0
    fi

    # Split the ADDITIONAL_DBS variable into an array (comma-separated)
    IFS=',' read -ra DBS <<< "$ADDITIONAL_DBS"

    for db in "${DBS[@]}"; do
        db=$(echo "$db" | xargs)  # Trim whitespace
        if [[ -n "$db" ]]; then
            echo "Creating database: $db"
            # You can optionally set PGUSER, PGPASSWORD, PGHOST, PGPORT before running
            createdb "$db" 2>/dev/null || echo "Database $db already exists or could not be created."
        fi
    done
}

create_pg_user() {
    if [[ -z "$DB_USER" || -z "$DB_PASSWORD" ]]; then
        echo "No user to be created..."
        return 0
    fi

    # Create the user if it doesn't exist
    psql -v ON_ERROR_STOP=1 -U postgres -d postgres -tc "SELECT 1 FROM pg_roles WHERE rolname='$DB_USER'" | grep -q 1
    if [[ $? -eq 0 ]]; then
        echo "User '$DB_USER' already exists."
    else
        echo "Creating PostgreSQL user '$DB_USER'..."
        psql -U postgres -d postgres -c "CREATE USER $DB_USER WITH PASSWORD '$DB_PASSWORD';"
    fi

    # Grant CONNECT on all existing databases
    DB_LIST=$(psql -U postgres -d postgres -Atc "SELECT datname FROM pg_database WHERE datistemplate = false;")
    for db in $DB_LIST; do
        echo "Granting privileges on database '$db' to '$DB_USER'..."
        psql -U postgres -d "$db" -c "GRANT ALL PRIVILEGES ON DATABASE $db TO $DB_USER;"
    done

    echo "User '$DB_USER' created with access to all databases (non-superuser)."
}

docker_temp_server_stop() {
	PGUSER="${PGUSER:-postgres}" \
	pg_ctl -D "$PGDATA" -m fast -w stop
}

_pg_want_help() {
	local arg
	for arg; do
		case "$arg" in
			-'?'|--help|--describe-config|-V|--version)
				return 0
				;;
		esac
	done
	return 1
}

_main() {
	if [ "${1:0:1}" = '-' ]; then
		set -- postgres "$@"
	fi

	if [ "$1" = 'postgres' ] && ! _pg_want_help "$@"; then
		docker_setup_env
        check_writeable
        source /compatibility.sh
		docker_create_db_directories

		if [ ! -s "$PGDATA/PG_VERSION" ]; then
			docker_verify_minimum_env

			ls /docker-entrypoint-initdb.d/ > /dev/null || :

			docker_init_database_dir
			pg_setup_hba_conf "$@"
            set_checksums
            ## Check if upgrade is needed
            UPGRADE_REQ=""  # empty initially
            shopt -s nullglob   # optional, avoids literal glob if no dirs exist
            echo "Checking for other PostgreSQL version directories in $PGDATA_PARENT..."
            # Loop over subdirectories in the parent folder
            for dir in "$PGDATA_PARENT"/*/; do
                # Remove trailing slash and get basename
                version_dir=$(basename "$dir")
                # Check if it's a number (major version)
                if [[ "$version_dir" =~ ^[0-9]+$ ]]; then
                    # Skip the current PGDATA directory itself
                    if [ "$(realpath "$dir")" != "$(realpath "$PGDATA")" ]; then
                        if [ -s "$dir/PG_VERSION" ]; then
                            echo "Found old PostgreSQL version: $version_dir"
                            # If UPGRADE_REQ is empty or current version is higher, update it
                            if [ -z "$UPGRADE_REQ" ] || [ "$version_dir" -gt "$UPGRADE_REQ" ]; then
                                UPGRADE_REQ="$version_dir"
                            fi
                        fi
                    fi
                fi
            done


            if [ -n "$UPGRADE_REQ" ]; then
            echo "Major Upgrade required, executing upgrade..."
            source /upgrade.sh
            UPGRADECHECK="true"
            else
              export PGPASSWORD="${PGPASSWORD:-$POSTGRES_PASSWORD}"
			  docker_temp_server_start "$@"

			  docker_setup_db
              create_additional_dbs
              create_pg_user
			  docker_process_init_files /docker-entrypoint-initdb.d/*

			  docker_temp_server_stop
			  unset PGPASSWORD

			  echo "PostgreSQL init process complete; ready for start up."
            fi

		else
            set_checksums
			cat <<-'EOM'

				PostgreSQL Database directory appears to contain a database; Skipping initialization

			EOM
		fi
	fi
    if [ "$PREPTEST" = "true" ]; then
      echo "Only generating test-data, not starting..."
    elif [ "$UPGRADECHECK" = "false" ]; then
      echo "The system seems to have been running an upgrade test, which failed to run upgrade."
      exit 1
    else
	  exec "$@"
    fi
}
PREPTEST=${PREPTEST:="false"}
PGDATA_PARENT=$(dirname "$PGDATA")
UPGRADECHECK="true"
if [ "$PREPTEST" = "true" ]; then
UPGRADECHECK="false"
    (
        ## TODO: Remove this hardcode
        PREV_MAJOR=$(cat /PREV_MAJOR)
        PGDATA="$PGDATA_PARENT/$PREV_MAJOR"
        PATH="/usr/lib/postgresql/$PREV_MAJOR/bin:$PATH"
        _main "$@"
    )
    export PREPTEST="false"
else
    export PATH="$PATH:/usr/lib/postgresql/$PG_MAJOR/bin"
fi
_main "$@"
