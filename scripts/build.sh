#!/bin/bash

TAG=$1
if [ "${TAG}" == "" ]; then
    TAG="fedora"
fi

echo "Building version monetdb:${TAG}"

docker build \
    --tag "monetdb/monetdb:${TAG}" \
    --no-cache=true .
docker tag monetdb/monetdb:${TAG} monetdb/monetdb:latest

