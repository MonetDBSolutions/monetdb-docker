#!/bin/bash
set -e
set -o pipefail

# argument list
# arg 1: db_farm
# arg 2: db_name
# arg 3: db_user
# arg 4: db_password
# arg 5: db_password_file

# create DB farm, create database
monetdbd create ${1}
monetdbd start ${1}
monetdbd set listenaddr=0.0.0.0 ${1}
monetdb create ${2}
monetdb release ${2}
monetdb start ${2}

# create a auth file to login as admin
printf "user=monetdb\npassword=monetdb\n" > $(pwd)/.monetdb

# initialize database with scripts
if [ -n "$(ls -A /initdb/*.sql 2> /dev/null)" ]; then 
    for filename in /initdb/*.sql; do
        mclient -d ${2} ${filename}
    done
fi

# change username of admin account
if [[ "$3" != "monetdb" ]]; then
    mclient -d ${2} -s "ALTER USER monetdb RENAME TO ${3}"
    printf "user=${3}\npassword=monetdb\n" > $(pwd)/.monetdb
fi

# change password of admin account
# password file has priority over text password
if [[ "$5" != "NO_FILE" ]]; then
    DB_PASSWORD=$(<${5})
    mclient -d ${2} -s "ALTER USER SET UNENCRYPTED PASSWORD '${DB_PASSWORD}' USING OLD PASSWORD 'monetdb'"
elif [[ "$4" != "monetdb" ]]; then
    mclient -d ${2} -s "ALTER USER SET UNENCRYPTED PASSWORD '${4}' USING OLD PASSWORD 'monetdb'"
fi

# remove the auth file
rm $(pwd)/.monetdb

# stop the daemon
monetdbd stop ${1}

echo "Initialization done"

monetdbd start -n ${1}
#mserver5 --dbpath=${1}/${2} --set monet_vault_key=${1}/${2}/.vaultkey --set mapi_listenaddr=0.0.0.0
