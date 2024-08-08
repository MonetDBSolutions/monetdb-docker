# This Source Code Form is subject to the terms of the Mozilla
# Public License, v. 2.0. If a copy of the MPL was not
# distributed with this file, You can obtain one at
# https://mozilla.org/MPL/2.0/.
#
# Copyright 1997 - July 2008 CWI, August 2008 - 2024 MonetDB B.V.

ARG ALPINE_VERSION=latest

FROM alpine:${ALPINE_VERSION} as build

ARG BRANCH=default
ARG BUILD_THREADS=4

RUN apk update && \
    apk add --no-cache \
    cmake \
    bison \
    pcre-dev \
    openssl-dev \
    build-base \
    readline-dev \
    bzip2-dev \
    lz4-dev \
    xz-dev \
    zlib-dev \
    curl \
    python3

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


FROM alpine:${ALPINE_VERSION} as runtime

RUN apk update && \
    apk add --no-cache \
    libbz2 \
    lz4-libs \
    xz-libs \
    pcre \
    py3-pip \
    py3-cryptography

COPY --from=build /usr/local /usr/local

COPY scripts/entrypoint.sh /usr/local/bin

EXPOSE 50000
STOPSIGNAL SIGINT

CMD [ "entrypoint.sh" ]
