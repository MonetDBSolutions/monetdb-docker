==============
MonetDB docker
==============
Docker container for MonetDB_.

.. _MonetDB: https://www.monetdb.org/

-----
Usage
-----
The simplest way to start a MonetDB container is to use the images
published on `Docker Hub`_::

  docker run -P -it monetdb/monetdb:latest

This command will start a container from the latest tagged image on
docker hub and it will map a random port on localhost to the port
50000 where the MonetDB daemon is listening for connections (the
effect of the ``-P`` flag). Alternatively you can specify the port on
the local host using the flag ``-p``.

The docker image creates the database farm on the directory
``/var/monetdb5/dbfarm/`` in the container the first time it
starts. You can mount a local directory on that path in the container
in order to have access to the data from the local host.

The image accepts a number of parameters in the form of environment
variables (i.e. passed using the ``-e`` docker flag) that will
configure the behavior of the container.

MDB_FARM_DIR
   The location of the database farm. Defaults to ``/var/monetdb5/dbfarm``.

MDB_DAEMON_PASS
   This is the passphrase used to manage the farm from outside the container.
   For example::

    monetdb -h localhost -P <passphrase> create SF-1

   See also MDB_DAEMON_PASS_FILE, which may be more secure.

   If neither MDB_DAEMON_PASS nor MDB_DAEMON_PASS_FILE are set,
   the farm cannot be managed from outside the container

MDB_DAEMON_PASS_FILE
   Variant of MDB_DAEMON_PASS. Path to a file inside the container that contains
   the daemon password on the first line.

   This can be used for example with `Docker swarm secrets`_ or `Kubernetes
   secrets management`_, or manually by mounting a volume that contains
   the password file.

MDB_LOGFILE
   The file where the daemon should write the log messages. By default
   it's the file ``merovingian.log`` in the database farm directory
   in the container.

MDB_SNAPSHOT_DIR
   This is the directory in the container where database snapshots
   will be written. If no value is given the daemon will not produce
   any snapshots. You can mount a local directory in order to have
   access to the snapshots from the local host.

MDB_SNAPSHOT_COMPRESSION
   This specifies the compression algorithm to be used for snapshot
   files. Default value is ``.tar.lz4``, other possible values are
   ``.tar``, ``.tar.gz``, ``.tar.xz`` and ``.tar.bz2``.

MDB_CREATE_DBS
   This specifies databases to be created the first time the container
   comes up. You can specify multiple databases by separating their
   names with a single comma character (no spaces between them)::

     [...] -e MDB_CREATE_DBS=db1,db2,db3 [...]

   The default is ``monetdb``.

   If this variable is not empty, MDB_DB_ADMIN_PASS must also be set.

MDB_DB_ADMIN_PASS
   The password to use for the ``monetdb`` (admin) user in the
   databases created through MDB_CREATE_DBS. Note that all the databases
   get the same admin password.

   See also MDB_DB_ADMIN_PASS_FILE, which may be more secure.

   If neither MDB_DB_ADMIN_PASS nor MDB_DB_ADMIN_PASS_FILE are set,
   MDB_CREATE_DBS must be set to the empty string.

MDB_DB_ADMIN_PASS_FILE
   Variant of MDB_DB_ADMIN_PASS. Path to a file inside the container that contains
   the daemon password on the first line.

   This can be used for example with `Docker swarm secrets`_ or `Kubernetes
   secrets management`_, or manually by mounting a volume that contains
   the password file.

.. note::

   There are situations where error messages produced at the startup
   of the container are not immediately visible. For example when
   using Github Actions, any error messages are shown at the end of
   the job in the section ``Stop containers``.

   Another similar situation is at the command line when the container
   is created in two steps using the commands `docker create` and
   `docker start`. In that case you can access the error messages
   using the command `docker logs <container name>`.

Access
------
Once the image is running you can get a shell in it::

  docker exec -it <image_name> bash

---------------------------
Building the image manually
---------------------------

Clone this git repository_ and run::

  docker build . -t <local tag>

Then you can use the image you just built as described in section
`Usage`_ above.

.. _repository: https://github.com/MonetDBSolutions/monetdb-docker

.. _Docker Hub: https://hub.docker.com/repository/docker/monetdb/monetdb/tags

.. _Docker swarm secrets: https://docs.docker.com/engine/swarm/secrets/#how-docker-manages-secrets

.. _Kubernetes secrets management: https://kubernetes.io/docs/concepts/configuration/secret/#using-secrets-as-files-from-a-pod

