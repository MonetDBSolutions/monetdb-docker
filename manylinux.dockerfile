FROM quay.io/pypa/manylinux2014_x86_64 as build

ARG BRANCH=Jul2021
ARG BUILD_THREADS=4

# install monetdb build dependencies
RUN yum update -y
RUN yum install -y cmake3 openssl-devel wget python3

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
RUN rm -rf /tmp/MonetDB-BRANCH

# add shared libraries to wheels
ENV LD_LIBRARY_PATH "${LD_LIBRARY_PATH}:/usr/local/lib"

FROM quay.io/pypa/manylinux2014_x86_64 as runtime

RUN yum update -y
RUN yum install -y openssl-devel

RUN rm -rf /usr/local
COPY --from=build /usr/local /usr/local

# add shared libraries to wheels
ENV LD_LIBRARY_PATH "${LD_LIBRARY_PATH}:/usr/local/lib"

# preinstall dependencies
RUN pip3 install --upgrade pip pytest numpy pandas mypy pycodestyle