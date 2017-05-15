FROM fedora
MAINTAINER Svetlin Stalinov, svetlin.stalinov@monetdbsolutions.com

#######################################################
# Expose ports
#######################################################
EXPOSE 50000

#############################################################
# Enables repos, update system, install packages and clean up
#############################################################
# Create users and groups
RUN groupadd -g 5000 monetdb && \
    useradd -u 5000 -g 5000 monetdb

# Update & upgrade
RUN dnf update -y && \
    dnf upgrade -y

# Enable MonetDB
RUN rpm --import http://dev.monetdb.org/downloads/MonetDB-GPG-KEY && \
    dnf install -y https://dev.monetdb.org/downloads/Fedora/MonetDB-release-1.1-1.monetdb.noarch.rpm

# Install packages
RUN dnf install -y \
    supervisor \
    MonetDB-SQL-server5 MonetDB-client

ENV MDB_HOME=/home/monetdb/
ENV DB_FARM=${MDB_HOME}/dbfarm

#######################################################
# Create log dirs
#######################################################
RUN mkdir -p /var/log/supervisor
    
#######################################################
# Setup MonetDB
#######################################################

# Add a monetdb config file to avoid prompts for username/password
COPY configs/.monetdb /home/monetdb/.monetdb

# Copy the init script
COPY scripts/init-db.sh /home/monetdb/init-db.sh
 
#######################################################
# Cleanup
#######################################################
RUN dnf -y clean all
RUN rm -rf /tmp/* /var/tmp/*

####################################################### 
 # Setup supervisord and set CMD
#######################################################
COPY configs/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

CMD  ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
