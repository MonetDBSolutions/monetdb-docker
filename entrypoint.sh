#!/usr/bin/env bash

set -eo pipefail

docker_create_dbfarm () {
    local farm_dir="${MDB_DBFARM:-/var/monetdb5/dbfarm}"
    local daemon_pass="${MDB_DAEMONPASS:-monetdb}"

    if [[ ! -e "$farm_dir/.merovingian_properties" ]]; then
        mkdir -p "$farm_dir"
        monetdbd create "$farm_dir"
    fi

    monetdbd set listenaddr=all "$farm_dir"
    monetdbd set control=true "$farm_dir"
    monetdbd set passphrase="$daemon_pass" "$farm_dir"

    monetdbd get all "$farm_dir"

    echo "Created db farm at ${farm_dir}"
}

docker_create_dbfarm
echo "Starting MonetDB daemon"
monetdbd start -n "${MDB_DBFARM:-/var/monetdb5/dbfarm}"
