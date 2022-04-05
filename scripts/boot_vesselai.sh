#!/bin/bash
set -e
set -o pipefail

# argument list
# arg 1: db_farm
# arg 2: db_name
# arg 3: db_user
# arg 4: db_password

# create DB farm, create database
monetdbd create ${1}
monetdbd start ${1}
monetdbd set listenaddr=0.0.0.0 ${1}
monetdb create ${2}
monetdb release ${2}
monetdb start ${2}

# create a auth file to login as admin
printf "user=monetdb\npassword=monetdb\n" > $(pwd)/.monetdb

if [ -n "$(ls -A /initdb/*.sql 2> /dev/null)" ]; then 
    for filename in /initdb/*.sql; do
        mclient -d ${2} ${filename}
    done
fi


if [[ "$3" != "monetdb" && "$4" != "monetdb" ]]; then
    mclient -d ${2} -s "ALTER USER monetdb RENAME TO ${3}"
    printf "user=${3}\npassword=monetdb\n" > $(pwd)/.monetdb
    mclient -d ${2} -s "ALTER USER SET UNENCRYPTED PASSWORD '${4}' USING OLD PASSWORD 'monetdb'"

    #mclient -d ${2} -s "CREATE USER ${3} WITH UNENCRYPTED PASSWORD '${4}' NAME '${3}' SCHEMA sys"
    # schema auth strategy: have a default schema where the user has full permissions (BUT he only has it for this particular schema)
    #mclient -d ${2} -s "CREATE SCHEMA vesselai AUTHORIZATION ${3}"
    # role strategy: either allow the user sysadmin rights, or create a new role in a new schema and assign it
    #mclient -d ${2} -s "GRANT sysadmin TO ${3}"
    # mclient -d ${2} -s "CREATE ROLE vessel_ai_user; CREATE SCHEMA vessel_ai AUTHORIZATION vessel_ai_user; GRANT vessel_ai_user TO ${3}"
    # BUT, we'd need to assign the role everytime?
    # mclient -d ${2} -s "SET ROLE ${3} sysadmin"

    echo "Created user ${3}"
else
    echo "Using default user and password 'monetdb'/'monetdb'"
fi

# remove the auth file
rm $(pwd)/.monetdb

# stop the daemon
monetdbd stop ${1}

echo "Initialization done"

monetdbd start -n ${1}
#mserver5 --dbpath=${1}/${2} --set monet_vault_key=${1}/${2}/.vaultkey --set mapi_listenaddr=0.0.0.0
