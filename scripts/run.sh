#!/bin/bash

docker run \
  -it \
  -d \
  -p 50000:50000 \
  --rm \
  --name monetdb \
  monetdb/monetdb:latest