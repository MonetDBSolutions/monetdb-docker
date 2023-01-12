#!/usr/bin/env bash

# This Source Code Form is subject to the terms of the Mozilla
# Public License, v. 2.0. If a copy of the MPL was not
# distributed with this file, You can obtain one at
# https://mozilla.org/MPL/2.0/.
#
# Copyright 1997 - July 2008 CWI, August 2008 - 2023 MonetDB B.V.

set -e -o pipefail -o nounset
set +x


farm_dir="${MDB_FARM_DIR-/var/monetdb5/dbfarm}"
if [[ -z "$farm_dir" ]]; then
    echo "MDB_FARM_DIR must not be empty"
    exit 1
fi

# Read the settings out of the environment. Place them in shell variables but do
# not export them so no secrets get exposed in the output of the 'ps' command.
configure () {
    logfile="${MDB_LOGFILE:-merovingian.log}"
    snapshotdir="${MDB_SNAPSHOT_DIR:-}"
    snapshotcompression="${MDB_SNAPSHOT_COMPRESSION:-}"
    show_vars="${MDB_SHOW_VARS:-}"

    if [[ -n "${MDB_DAEMON_PASS_FILE:-}" ]]; then
        passphrase="$(head -1 "$MDB_DAEMON_PASS_FILE")"
    else
        passphrase="${MDB_DAEMON_PASS:-}"
    fi
    if [[ -n "${MDB_DB_ADMIN_PASS_FILE:-}" ]]; then
        admin_pass="$(head -1 "$MDB_DB_ADMIN_PASS_FILE")"
    else
        admin_pass="${MDB_DB_ADMIN_PASS:-}"
    fi

    # Figure out which databases to create.
    tmp_dbs="${MDB_CREATE_DBS-monetdb}"
    if [[ -n "$tmp_dbs" && -z "$admin_pass" ]]; then
        echo "Please use MDB_DB_ADMIN_PASS or MBD_DB_ADMIN_PASS_FILE to set a database admin"
        echo "password for '$tmp_dbs'.  Alternatively, set MDB_CREATE_DBS to ''."
        exit 1
    fi
    # split on commas and store the result in create_dbs
    IFS=',' read -ra create_dbs <<< "$tmp_dbs"
}

create_dbfarm () {
    if [[ -f "$farm_dir"/.merovingian_properties ]]; then
        return
    fi
    echo "Creating db farm at ${farm_dir}"
    mkdir -p "${farm_dir}"
    monetdbd create "${farm_dir}"
}

set_properties () {
    # do not set listenaddr, control and passphrase here, this will happen later
    monetdbd set "logfile=$logfile" "$farm_dir"
    monetdbd set "snapshotdir=$snapshotdir" "$farm_dir"
    monetdbd set "snapshotcompression=$snapshotcompression" "$farm_dir"
}

create_databases () {
    monetdbd start "${farm_dir}"
    for db in "${create_dbs[@]}"; do
        echo "Creating database '$db'"
        monetdb create -p "$admin_pass" "$db"
    done
    monetdbd stop "${farm_dir}"
}

enable_control () {
    monetdbd set passphrase="$passphrase" "$farm_dir"
    monetdbd set control=true "$farm_dir"
}


configure

if [[ ! -f "$farm_dir"/.container_initialized ]]; then

    create_dbfarm

    set_properties

    if [[ -n "$admin_pass" ]]; then
        create_databases
    fi

    if [[ -n "$passphrase" ]]; then
        enable_control
    fi

    # only start listening to the outside world when all expected databases
    # have been created
    monetdbd set listenaddr=all "$farm_dir"

    touch "$farm_dir"/.container_initialized
fi

if [[ -n "$show_vars" ]]; then
    monetdbd get all "$farm_dir"
fi

echo "Starting MonetDB daemon"
monetdbd start -n "$farm_dir"
