# This Source Code Form is subject to the terms of the Mozilla
# Public License, v. 2.0. If a copy of the MPL was not
# distributed with this file, You can obtain one at
# https://mozilla.org/MPL/2.0/.
#
# Copyright 1997 - July 2008 CWI, August 2008 - 2023 MonetDB B.V.

FROM fedora:latest

LABEL org.opencontainers.image.authors="svetlin.stalinov@monetdbsolutions.com"


ARG enablerepo

# Create users and groups
RUN groupadd -g 5000 monetdb && \
    useradd -u 5000 -g 5000 monetdb

# Update & upgrade
RUN dnf upgrade -y

# Install compression schemes
RUN dnf install -y xz bzip2 lz4 gzip

# Temporary fix for missing numpy.
RUN dnf install -y python3-numpy

# install MonetDB
RUN dnf install -y https://dev.monetdb.org/downloads/Fedora/MonetDB-release.noarch.rpm

# Install MonetDB packages
RUN dnf install -y --best \
    $(if [ -n "$enablerepo" ]; then echo "--enablerepo=${enablerepo}"; fi) \
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
COPY scripts/entrypoint.sh /usr/local/bin

EXPOSE 50000

CMD [ "entrypoint.sh" ]

STOPSIGNAL SIGINT
