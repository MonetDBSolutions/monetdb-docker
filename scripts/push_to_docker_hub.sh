#!/bin/bash

TAG=$1
if [ "${TAG}" == "" ]; then
    TAG="fedora"
fi

echo "pushing monetdb/monetdb:${TAG} ..."

docker push monetdb/monetdb:${TAG}
docker push monetdb/monetdb:latest
