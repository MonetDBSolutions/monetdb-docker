# This Source Code Form is subject to the terms of the Mozilla
# Public License, v. 2.0. If a copy of the MPL was not
# distributed with this file, You can obtain one at
# https://mozilla.org/MPL/2.0/.
#
# Copyright 1997 - July 2008 CWI, August 2008 - 2024 MonetDB B.V.

FROM quay.io/pypa/manylinux_2_28_x86_64 as build

ARG BRANCH=default
ARG BUILD_THREADS=4

# install monetdb build dependencies
RUN yum install -y cmake3 openssl-devel wget python3  \
  	&& yum clean all \
  	&& rm -rf /var/cache/yum

# download and extract monetdb
WORKDIR /tmp 
RUN curl -o MonetDB.tar.bz2 https://www.monetdb.org/hg/MonetDB/archive/${BRANCH}.tar.bz2
RUN tar jxf MonetDB.tar.bz2

RUN mkdir /tmp/MonetDB-${BRANCH}/build
WORKDIR /tmp/MonetDB-${BRANCH}/build
RUN cmake3 .. \
    -DWITH_CRYPTO=OFF \
    -DINT128=ON \
    -DPY3INTEGRATION=OFF \
    -DCMAKE_BUILD_TYPE=Release \
    -DASSERT=OFF -DSTRICT=OFF \
    -DRINTEGRATION=OFF
RUN cmake3 --build .  -j ${BUILD_THREADS}
RUN cmake3 --build . --target install



FROM quay.io/pypa/manylinux_2_28_x86_64 as runtime

RUN rm -rf /usr/local
COPY --from=build /usr/local /usr/local

# add shared libraries to wheels
ENV LD_LIBRARY_PATH "${LD_LIBRARY_PATH}:/usr/local/lib"

COPY scripts/entrypoint.sh /usr/local/bin

EXPOSE 50000

CMD [ "entrypoint.sh" ]
