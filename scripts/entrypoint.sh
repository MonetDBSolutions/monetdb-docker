#!/bin/bash

# Add a monetdb config file to avoid prompts for username/password
# Only if it doesn't exist - this allows users to mount their own file, or overwrite 
if [ ! -e ~/.monetdb ]
then
    printf "user=monetdb\npassword=${DB_PASSWORD}" > ~/.monetdb
fi

monetdbd start ${DB_FARM}
monetdb create -p ${DB_PASSWORD} ${DB_NAME}
monetdb release ${DB_NAME}

# A dirty way to prevent the container from exiting
monetdbd stop ${DB_FARM}
monetdbd start -n ${DB_FARM}
