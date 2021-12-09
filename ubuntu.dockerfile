FROM ubuntu:20.04 as build

ARG BRANCH=default
ARG BUILD_THREADS=4
ENV DEBIAN_FRONTEND noninteractve

# install monetdb build dependencies
RUN apt-get update && \
    apt-get install -y cmake bison libpcre3-dev libssl-dev wget && \
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



FROM ubuntu:20.04 as runtime

# install monetdb build dependencies
RUN apt-get update && \
    apt-get install -y python3-pip libpcre3-dev libssl-dev && \
    rm -rf /var/lib/apt/lists/*


RUN pip3 install --upgrade pip pytest numpy pandas mypy pycodestyle

RUN rm -rf /usr/local
COPY --from=build /usr/local /usr/local

# add shared libraries to wheels
ENV LD_LIBRARY_PATH "${LD_LIBRARY_PATH}:/usr/local/lib"
