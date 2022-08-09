FROM fedora
MAINTAINER Svetlin Stalinov, svetlin.stalinov@monetdbsolutions.com

# Create users and groups
RUN groupadd -g 5000 monetdb && \
    useradd -u 5000 -g 5000 monetdb

# Update & upgrade
RUN dnf upgrade -y

# Install compression schemes
RUN dnf install -y xz bzip2 lz4 gzip

# install MonetDB
RUN dnf install -y https://dev.monetdb.org/downloads/Fedora/MonetDB-release.noarch.rpm

# Install MonetDB packages
RUN dnf install -y --best \
    MonetDB-SQL-server5 MonetDB-client \
    MonetDB-cfitsio MonetDB-geom-MonetDB5\
    MonetDB-python3

#######################################################
# Cleanup
#######################################################
RUN dnf -y clean all
RUN rm -rf /tmp/* /var/tmp/*

#######################################################
# Setup MonetDB
#######################################################
COPY entrypoint.sh /usr/local/bin
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 50000

ENTRYPOINT ["entrypoint.sh"]

STOPSIGNAL SIGINT
