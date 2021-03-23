#!/bin/bash

# Add a monetdb config file to avoid prompts for username/password
printf "user=monetdb\npassword=${DB_PASSWORD}" > ~/.monetdb

monetdbd start ${DB_FARM}
monetdb create -p ${DB_PASSWORD} ${DB_NAME}
monetdb release ${DB_NAME}

# A dirty way to prevent the container from exiting
monetdbd stop ${DB_FARM}
monetdbd start -n ${DB_FARM}
