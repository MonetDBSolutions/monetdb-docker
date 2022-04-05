## Pull the image

```
docker pull docker.io/monetdb/vessel_ai
```

## Start the container

```
docker run --rm -d -P -p <LOCAL_PORT>:50000 --name <NAME> monetdb/vessel_ai:latest
```

## Connect to the database server

```
mclient -p <LOCAL_PORT> -d demo -u monetdb
```

**NOTE**: the password of the _monetdb_ user is `monetdb`.