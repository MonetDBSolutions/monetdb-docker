monetdb docker
===========================
Docker container for MonetDB database

# Manual building
## Building
```
docker build .
```
## Running
```
docker run --rm -P --name monetdb monetdb/monetdb
```
The `-P` option will publish all exposed ports. Use the `-d` option will send the docker process to the background.

## Access
```
docker exec -it monetdb bash
```

## Tag and push
```
docker tag monetdb monetdb/monetdb
docker push monetdb/monetdb
```
This will push the built image(s) to the [Docker Hub Registry](https://registry.hub.docker.com/u/monetdb/monetdb/)

