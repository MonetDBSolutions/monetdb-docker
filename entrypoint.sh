#!/usr/bin/env bash

set -eo pipefail

setup_environment () {
    truncate -s 0 /.env
    echo "export farm_dir=${MDB_DBFARM:-/var/monetdb5/dbfarm}" >> /.env
    echo "export daemon_pass=${MDB_DAEMONPASS:-monetdb}" >> /.env
    echo "export logfile=${MDB_LOGFILE:-merovingian.log}" >> /.env
    echo "export snapshotdir=${MDB_SNAPSHOTDIR:-}" >> /.env
    echo "export snapshotcompression=${MDB_SNAPSHOTCOMPRESSION:-}" >> /.env

    cat /.env
}

create_dbfarm () {
    source /.env
    if [[ ! -e "$farm_dir/.merovingian_properties" ]]; then
        mkdir -p "$farm_dir"
        monetdbd create "$farm_dir"
        echo "Created db farm at ${farm_dir}"
    fi
}

setup_properties () {
    source /.env

    monetdbd set listenaddr=all "$farm_dir"
    monetdbd set control=true "$farm_dir"
    monetdbd set passphrase="$daemon_pass" "$farm_dir"
    monetdbd set logfile="$logfile" "$farm_dir"
    monetdbd set snapshotdir="$snapshotdir" "$farm_dir"
    monetdbd set snapshotcompression="$snapshotcompression" "$farm_dir"

    if [[ "${MDB_SHOW_VARS:-}" ]]; then
        monetdbd get all "$farm_dir"
    fi

}

setup_environment
create_dbfarm
setup_properties
echo "Starting MonetDB daemon"
monetdbd start -n "${MDB_DBFARM:-/var/monetdb5/dbfarm}"
