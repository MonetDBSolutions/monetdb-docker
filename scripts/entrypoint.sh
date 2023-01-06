#!/usr/bin/env bash

# This Source Code Form is subject to the terms of the Mozilla
# Public License, v. 2.0. If a copy of the MPL was not
# distributed with this file, You can obtain one at
# https://mozilla.org/MPL/2.0/.
#
# Copyright 1997 - July 2008 CWI, August 2008 - 2023 MonetDB B.V.

set -eo pipefail
set +x


# We need to set a number of properties, but we also need to remember
# them next time the container comes up. The consequence is that we
# need to keep them in a constant location. We will have the
# convention that the dbfarm is always located at
# /var/monetdb5/dbfarm/ inside the container and we will save the
# values in the file /var/monetdb5/dbfarm/.container_env. We will
# source it at startup in order to define them in the environment.

export farm_dir=/var/monetdb5/dbfarm/

setup_environment () {
    # First we source the env file if it exists. This will define the variables:
    # - daemon_pass
    # - logfile
    # - snapshot_dir
    # - snapshot_compression
    # - db_admin_pass
    [[ -e "${farm_dir}/.container_env" ]] && source "${farm_dir}/.container_env"


    # We update the variables in case the user passed new values at
    # the command line.
    export daemon_pass="${MDB_DAEMON_PASS:-${daemon_pass:-monetdb}}"
    export logfile="${MDB_LOGFILE:-${logfile:-merovingian.log}}"
    export snapshot_dir="${MDB_SNAPSHOT_DIR:-${snapshot_dir}}"
    export snapshot_compression="${MDB_SNAPSHOT_COMPRESSION:-${snapshot_compression}}"

    # Write everything back to the file.
    truncate -s 0 "${farm_dir}/.container_env"
    echo "export daemon_pass=${daemon_pass}" >> "${farm_dir}/.container_env"
    echo "export logfile=${logfile}" >> "${farm_dir}/.container_env"
    echo "export snapshot_dir=${snapshot_dir}" >> "${farm_dir}/.container_env"
    echo "export snapshot_compression=${snapshot_compression}" >> "${farm_dir}/.container_env"
    # We do not record the variables created_dbs and db_admin_pass
}

create_dbfarm () {
    source "${farm_dir}/.container_env"

    if [[ ! -e "${farm_dir}/.merovingian_properties" ]]; then
        mkdir -p "${farm_dir}"
        monetdbd create "${farm_dir}"
        echo "Created db farm at ${farm_dir}"
    fi
}

setup_properties () {
    source "${farm_dir}/.container_env"
    echo "${MDB_DB_ADMIN_PASS}"

    monetdbd set listenaddr=all "$farm_dir"
    monetdbd set control=true "$farm_dir"
    monetdbd set passphrase="$daemon_pass" "$farm_dir"
    monetdbd set logfile="$logfile" "$farm_dir"
    monetdbd set snapshotdir="$snapshot_dir" "$farm_dir"
    monetdbd set snapshotcompression="$snapshot_compression" "$farm_dir"

    if [[ "${MDB_SHOW_VARS:-}" ]]; then
        monetdbd get all "$farm_dir"
    fi

}

create_dbs () {
    if [[ -n "${MDB_CREATED_DBS}" && ! -e "${farm_dir}/.docker_initialized" ]];
    then
        db_admin_pass="${MDB_DB_ADMIN_PASS:-monetdb}"
        monetdbd start "${farm_dir}"
        IFS=','
        read -ra dbs <<< "${MDB_CREATED_DBS}"
        for db in "${dbs[@]}";
        do
            monetdb create -p "${db_admin_pass}" "${db}"
        done
        monetdbd stop "${farm_dir}"
        touch "${farm_dir}/.docker_initialized"
    fi
}

setup_environment
create_dbfarm
setup_properties
create_dbs
echo "Starting MonetDB daemon"
monetdbd start -n "${farm_dir}"
