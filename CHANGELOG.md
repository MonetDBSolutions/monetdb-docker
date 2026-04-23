# CHANGELOG

## monetdb-docker NEXT_RELEASE - YYYY-MM-DD

- Change user to `monetdb` before running entrypoint.sh script.
  Before attaching a volume that was started with the previous image you need
  to change the ownership of the dbfarm `chown -R monetdb dbfarm`.

