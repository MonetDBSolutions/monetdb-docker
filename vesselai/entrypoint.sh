#!/bin/bash

set -e
set -o pipefail

if [ "$#" -ne 5 ]; then
    echo "Usage: $0 <db_farm> <db_name> <db_user> <db_pass> <db_passfile>"
    exit 1
fi

db_farm=${1}
db_name=${2}
db_user=${3}
db_pass=${4}
db_passfile=${5}

create_farm () {
    local db_farm=${1}

    monetdbd create ${db_farm}
    monetdbd set listenaddr=0.0.0.0 ${db_farm}
}

create_db () {
    local db_farm=${1} 
    local db_name=${2}

    monetdb create ${db_name}
    monetdb release ${db_name}
}

setup_admin () {
    local db_name=${1}
    local db_user=${2}
    local db_pass=${3}
    local db_passfile=${4}
    
    # create a auth file to login as admin
    printf "user=monetdb\npassword=monetdb\n" > $(pwd)/.monetdb

    # initialize database with scripts
    local init_scripts=$(ls -A /initdb/*.sql 2> /dev/null)
    if [ -n "${init_scripts}" ]; then 
        for filename in /initdb/*.sql; do
            mclient -d ${db_name} ${filename}
        done
    else
        echo "No database init scripts found"
    fi

    # change username of admin account
    if [[ "${db_user}" != "monetdb" ]]; then
        mclient -d ${db_name} -s "ALTER USER monetdb RENAME TO ${db_user}"
        printf "user=${db_user}\npassword=monetdb\n" > $(pwd)/.monetdb
    fi

    # change password of admin account
    # password file has priority over text password
    if [[ "${db_passfile}" != "NO_FILE" ]]; then
        # make sure that `\` and `'` characters in the password are 
        # properly escaped 
        local DB_PASSWORD=$(sed 's/\\/\\\\/g' ${db_passfile} | sed "s/'/''/g")
        mclient -d ${db_name} -s "ALTER USER SET UNENCRYPTED PASSWORD '${DB_PASSWORD}' USING OLD PASSWORD 'monetdb'"
    elif [[ "${db_pass}" != "monetdb" ]]; then
        mclient -d ${db_name} -s "ALTER USER SET UNENCRYPTED PASSWORD '${db_pass}' USING OLD PASSWORD 'monetdb'"
    fi

    # remove the auth file
    rm $(pwd)/.monetdb
}

# create DBfarm
if [ ! -e "${db_farm}/.merovingian_properties" ];
then
    echo "Creating dbfarm ${db_farm}"
    create_farm ${db_farm}
else
    echo "Existing dbfarm named ${db_farm} found"
fi

# create DB and set up admin account
if [ ! -s "${db_farm}/${db_name}" ];
then
    monetdbd start ${db_farm}
    echo "Creating database ${db_name}"
    create_db ${db_farm} ${db_name}
    echo "Setting up admin account" 
    setup_admin ${db_name} ${db_user} ${db_pass} ${db_passfile}
    monetdbd stop ${db_farm}
else
    echo "Database ${db_name} already exists"
fi

echo "Initialization done! - Starting mserver5 daemon"
monetdbd start -n ${db_farm}
#mserver5 --dbpath=${1}/${2} --set monet_vault_key=${1}/${2}/.vaultkey --set mapi_listenaddr=0.0.0.0
