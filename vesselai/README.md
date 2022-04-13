## Pull the image

```sh
docker pull docker.io/monetdb/vessel_ai
```

## Container configuration

You can configure database name, user and password, store the database
data in a docker volume and start the database with initialization
scripts present in the host system.

### Environment variables

- **DB_NAME**: Set the database name (default is **"vesselai"**)
- **DB_USER**: Set the user name for database access (default is
  **"monetdb"**)
- **DB_PASSWORD**: Set the password for database access (default is
  **"monetdb"**)
- **DB_FARM**: Set where data is stored in the container's filesystem.
  The default is **"/var/monetdb5/dbfarm"**. **NOTE**:  If you want to
  store the database data in a Docker Volume, you should set the
  target/destination of the volume to this DB_FARM directory.

### Store data in a volume

To keep database data after the container is removed, use a docker
volume to store your data. Examples on how to use volumes with `docker
run` and `docker compose` can be found below.

By default, the database is stored in `/var/monetdb5/dbfarm` on the
container's filesystem. However, if you change the value of *DB_FARM*,
data will be stored at the set location.

### Database init scripts

You can use SQL scripts to initialize the database before use. By using
a bind mount, you can specify a directory in the host system's
filesystem containing the scripts to be executed. The directory to mount
to in the container's filesystem is `/initdb/`.

You can find examples on how to use bind mounts with `docker run` and
`docker compose` below.

## Start the container

### Docker Compose example
_NOTE_: If you are a Mac or Windows user, use docker-compose to be able to connect to the dat
abase from the host machine. If you use docker run, you will only be able to connect through
docker exec (connecting from the container).
Run container with custom _username_ and _password_, without using docker volumes and no database initialization scripts.
```yml
services:
    database:
        image: monetdb/vessel_ai:latest
        ports: 
            - <LOCAL_PORT>:50000
        environment:
            DB_USER: "<USERNAME>"
            DB_PASSWORD: "<PASSWORD>"
```

Run container with custom database configuration, using a docker volume
to store the database data and database initialization scripts in the
current working directory.
```yml
services:
    database:
        image: monetdb/vessel_ai:latest
        ports: 
            - <LOCAL_PORT>:50000
        environment:
            DB_NAME: "<DATABASE_NAME>"
            DB_USER: "<USERNAME>"
            DB_PASSWORD: "<PASSWORD>"
        volumes:
            - database_storage:/var/monetdb5/dbfarm
            - type: bind
            source: ./
            target: /initdb/
    volumes:
        database_storage:

```

### Docker Run examples

Run container with default database options, without using docker
volumes and no database initialization scripts.
```sh
docker run -d -p <LOCAL_PORT>:50000 \
           --name <CONTAINER_NAME> \
           monetdb/vessel_ai:latest
```

Run container with custom _username_ and _password_, and use a docker
volume to store the data. **Note:** the target value for the mount must
be the same value as _DB_FARM_ (default is `/var/monetdb5/dbfarm`).

```sh
docker run -d -p <LOCAL_PORT>:50000 \
           --name <CONTAINER_NAME> \
           -e DB_USER='<USERNAME>' \
           -e DB_PASSWORD='<PASSWORD>' \
           ---mount source=db_storage,target=/var/monetdb5/dbfarm \
           monetdb/vessel_ai:latest
```

Run container with a custom database name and execute database
initialization scripts in the current working directory. **Note:** the
`/initdb/` directory in the container is always used to store init
scripts.

```sh
docker run -d -p <LOCAL_PORT>:50000 \
           --name <NAME> \
           -e DB_NAME='<DATABASE_NAME>' \
           --mount type=bind,source="$(pwd)",target=/initdb/ \
           monetdb/vessel_ai:latest
```

## Connect to the database server

### From the host machine

You can use all the different clients available for MonetDB to connect
to the server and use the database.

Using the mclient CLI tool:
```sh
mclient -p <LOCAL_PORT> -d <DATABASE_NAME> -u <USERNAME>
```

TODO: pymonetdb example

### Using docker exec
Using _docker exec_ or _docker-compose exec_ you can connect to the
container and use the client on the container itself. This can be useful
if using Docker Desktop for Mac and Windows, which have limited capacity
for connection from the host machine.

```sh
docker exec -it <CONTAINER_NAME> mclient -d <DATABASE_NAME> -u <USERNAME>
# or for compose
docker-compose exec <SERVICE_NAME> mclient -d <DATABASE_NAME> -u <USERNAME>
```
