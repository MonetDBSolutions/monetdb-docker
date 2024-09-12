# This Source Code Form is subject to the terms of the Mozilla
# Public License, v. 2.0. If a copy of the MPL was not
# distributed with this file, You can obtain one at
# https://mozilla.org/MPL/2.0/.
#
# Copyright 1997 - July 2008 CWI, August 2008 - 2024 MonetDB B.V.

ARG UBUNTU_VERSION=22.04

FROM ubuntu:${UBUNTU_VERSION} as build

ARG BRANCH=default
ARG BUILD_THREADS=4
ENV DEBIAN_FRONTEND noninteractve

# install monetdb build dependencies
RUN apt-get update && \
    apt-get install -y cmake bison libpcre3-dev libssl-dev curl python3 bzip2 && \
    rm -rf /var/lib/apt/lists/*

# download and extract monetdb
WORKDIR /tmp 
RUN curl -o MonetDB.tar.bz2 https://www.monetdb.org/hg/MonetDB/archive/${BRANCH}.tar.bz2
RUN tar jxf MonetDB.tar.bz2

RUN mkdir /tmp/MonetDB-${BRANCH}/build
WORKDIR /tmp/MonetDB-${BRANCH}/build
RUN cmake .. \
    -DWITH_CRYPTO=OFF \
    -DINT128=ON \
    -DPY3INTEGRATION=OFF \
    -DCMAKE_BUILD_TYPE=Release \
    -DASSERT=OFF \
    -DSTRICT=OFF \
    -DRINTEGRATION=OFF
RUN cmake --build . -j ${BUILD_THREADS}
RUN cmake --build . --target install



FROM ubuntu:${UBUNTU_VERSION} as runtime

# install monetdb build dependencies
RUN apt-get update && \
    apt-get install -y python3-pip libpcre3 libssl1.1 && \
    rm -rf /var/lib/apt


RUN pip3 install --no-cache --upgrade pip pytest numpy pandas mypy pycodestyle

RUN rm -rf /usr/local
COPY --from=build /usr/local /usr/local

# add shared libraries to wheels
ENV LD_LIBRARY_PATH "${LD_LIBRARY_PATH}:/usr/local/lib"

COPY scripts/entrypoint.sh /usr/local/bin

EXPOSE 50000

CMD [ "entrypoint.sh" ]
