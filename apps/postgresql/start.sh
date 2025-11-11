#!/usr/bin/env bash
set -Eeo pipefail
# TODO swap to -Eeuo pipefail above (after handling all potentially-unset variables)

# used to create initial postgres directories
docker_create_db_directories() {
	mkdir -p "$PGDATA"
	chmod 00700 "$PGDATA" || :

	mkdir -p /var/run/postgresql || :
	chmod 03775 /var/run/postgresql || :

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
	: "${POSTGRES_DB:=$POSTGRES_USER}"
	: "${POSTGRES_INITDB_ARGS:=}"
	: "${POSTGRES_HOST_AUTH_METHOD:=}"

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
		docker_create_db_directories

		if [ ! -s "$PGDATA/PG_VERSION" ]; then
			docker_verify_minimum_env

			ls /docker-entrypoint-initdb.d/ > /dev/null || :

			docker_init_database_dir
			pg_setup_hba_conf "$@"
            ## Check if upgrade is needed
            UPGRADE_REQ=""  # empty initially
            PARENT_DIR=$(dirname "$PGDATA")
            echo "Checking for other PostgreSQL version directories in $PARENT_DIR..."
            # Loop over subdirectories in the parent folder
            for dir in "$PARENT_DIR"/*/; do
                # Remove trailing slash and get basename
                version_dir=$(basename "$dir")
                # Check if it's a number (major version)
                if [[ "$version_dir" =~ ^[0-9]+$ ]]; then
                    # Skip the current PGDATA directory itself
                    if [ "$dir" != "$PGDATA/" ]; then
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
            /upgrade.sh
            else
              export PGPASSWORD="${PGPASSWORD:-$POSTGRES_PASSWORD}"
			  docker_temp_server_start "$@"

			  docker_setup_db
			  docker_process_init_files /docker-entrypoint-initdb.d/*

			  docker_temp_server_stop
			  unset PGPASSWORD

			  echo "PostgreSQL init process complete; ready for start up."
            fi

		else
			cat <<-'EOM'

				PostgreSQL Database directory appears to contain a database; Skipping initialization

			EOM
		fi
	fi

	exec "$@"
}

_main "$@"
