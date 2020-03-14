FROM fedora
MAINTAINER Svetlin Stalinov, svetlin.stalinov@monetdbsolutions.com

# Create users and groups
RUN groupadd -g 5000 monetdb && \
    useradd -u 5000 -g 5000 monetdb

# Update & upgrade
RUN dnf update -y && \
    dnf upgrade -y

# install MonetDB
RUN rpm --import http://dev.monetdb.org/downloads/MonetDB-GPG-KEY && \
    dnf install -y https://dev.monetdb.org/downloads/Fedora/MonetDB-release.noarch.rpm

# Install packages
RUN dnf install -y --best \
    MonetDB-SQL-server5 MonetDB-client

ENV MDB_HOME=/home/monetdb/
ENV DB_FARM=/var/monetdb5/dbfarm

#######################################################
# Cleanup
#######################################################
RUN dnf -y clean all
RUN rm -rf /tmp/* /var/tmp/*

#######################################################
# Setup MonetDB
#######################################################
WORKDIR ${MDB_HOME}
# Add a monetdb config file to avoid prompts for username/password
COPY configs/.monetdb ./

RUN rm -rf ${DB_FARM}
RUN monetdbd create ${DB_FARM}
RUN monetdbd set listenaddr=0.0.0.0 /var/monetdb5/dbfarm

RUN chown -R monetdb:monetdb ${MDB_HOME}
RUN chown -R monetdb:monetdb /var/monetdb5 && \
    chown -R monetdb:monetdb /var/log/monetdb && \
    chown -R monetdb:monetdb /var/run/monetdb 

EXPOSE 50000

CMD ["monetdbd", "start", "-n", "/var/monetdb5/dbfarm"]
