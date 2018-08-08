FROM fedora
MAINTAINER Svetlin Stalinov, svetlin.stalinov@monetdbsolutions.com

# Create users and groups
RUN groupadd -g 5000 monetdb && \
    useradd -u 5000 -g 5000 monetdb

# Update & upgrade
# RUN dnf update -y && \
#     dnf upgrade -y

# install MonetDB
RUN rpm --import http://dev.monetdb.org/downloads/MonetDB-GPG-KEY && \
    dnf install -y https://dev.monetdb.org/downloads/Fedora/MonetDB-release.noarch.rpm

# Install packages
RUN dnf install -y --best \
    supervisor \
    MonetDB-SQL-server5 MonetDB-client

ENV MDB_HOME=/home/monetdb/
ENV DB_FARM=/var/monetdb5/dbfarm

RUN chown -R monetdb:monetdb /var/monetdb5 && \
    chown -R monetdb:monetdb /var/log/monetdb && \
    chown -R monetdb:monetdb /var/run/monetdb 

#######################################################
# Create log dirs
#######################################################
RUN mkdir -p /var/log/supervisor

WORKDIR ${MDB_HOME}

#######################################################
# Setup MonetDB
#######################################################

# Add a monetdb config file to avoid prompts for username/password
COPY configs/.monetdb scripts/boot.sh ./
RUN chmod +x boot.sh

####################################################### 
 # Setup supervisord
#######################################################
COPY configs/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
 
#######################################################
# Cleanup
#######################################################
RUN dnf -y clean all
RUN rm -rf /tmp/* /var/tmp/*

RUN chown -R monetdb:monetdb ./
#USER monetdb

EXPOSE 50000

VOLUME /var/monetdb5

ENTRYPOINT ["./boot.sh"]
CMD [ "devdb" ]
