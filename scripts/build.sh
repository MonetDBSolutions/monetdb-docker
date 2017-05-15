#!/bin/bash

echo "Building version monetdb:fedora"

docker build \
    --tag "monetdb/monetdb:fedora" \
    --no-cache=true .
docker tag monetdb/monetdb:fedora monetdb/monetdb:latest
