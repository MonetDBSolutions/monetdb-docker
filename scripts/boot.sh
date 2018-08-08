#!/bin/bash

set -e

runuser -l  monetdb -c 'monetdbd start /var/monetdb5/dbfarm'

if [ ! -d "/var/monetdb5/dbfarm/${1}" ]; then
    runuser -l  monetdb -c "monetdb create ${1} && \
        monetdb set embedr=true ${1} && \
        monetdb release ${1}"
else
    echo "Existing database found in /var/monetdb5/dbfarm/${1}"
fi

runuser -l  monetdb -c 'monetdbd stop /var/monetdb5/dbfarm'
runuser -l  monetdb -c "monetdbd set listenaddr=0.0.0.0 /var/monetdb5/dbfarm"

echo "Initialization done"

exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf