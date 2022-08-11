#!/usr/bin/env bash

set -eo pipefail


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
    # - snapshotdir
    # - snapshotcompression
    [[-e "${farm_dir}/.container_env" ]] && source "${farm_dir}/.container_env"


    # We update the variables in case the user passed new values at
    # the command line.
    export daemon_pass="${MDB_DAEMONPASS:-${daemon_pass}}"
    export logfile="${MDB_LOGFILE:-${logfile}}"
    export snapshotdir="${MDB_SNAPSHOTDIR:-${snapshotdir}}"
    export snapshotcompression="${MDB_SNAPSHOTDIR:-${snapshotcompression}}"

    # Write everything back to the file.
    truncate -s 0 "${farm_dir}/.container_env"
    echo "export daemon_pass=${daemon_pass}" >> "${farm_dir}/.container_env"
    echo "export logfile=${logfile}" >> "${farm_dir}/.container_env"
    echo "export snapshotdir=${snapshotdir}" >> "${farm_dir}/.container_env"
    echo "export snapshotcompression=${snapshotcompression}" >> "${farm_dir}/.container_env"

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
monetdbd start -n "${farm_dir}"
