FROM ubuntu:20.04 as build

ARG BRANCH=geo-update

# install monetdb build dependencies

RUN apt-get update && \
    DEBIAN_FRONTEND="noninteractive" \
    TZ="Europe/Amsterdam" \
    apt-get install -y cmake bison libpcre3-dev libssl-dev wget \
                       python3 libgdal-dev gdal-bin libgeos-dev \
                       libproj-dev unzip libcurl4-gnutls-dev readline-common && \
    rm -rf /var/lib/apt/lists/*

# download and extract monetdb

WORKDIR /tmp 
RUN wget --no-check-certificate --content-disposition -O MonetDB.zip \
    https://github.com/MonetDB/MonetDB/archive/refs/heads/branches/geo-update.zip 
RUN unzip MonetDB.zip

RUN mkdir /tmp/MonetDB-branches-${BRANCH}/build
WORKDIR /tmp/MonetDB-branches-${BRANCH}/build
RUN cmake .. \
    -DWITH_CRYPTO=OFF \
    -DINT128=ON \
    -DPY3INTEGRATION=OFF \
    -DCMAKE_BUILD_TYPE=RelWithDebInfo \
    -DASSERT=OFF \
    -DSTRICT=OFF \
    -DRINTEGRATION=OFF \
    -DGEOM=ON \
    -DSHP=ON
RUN cmake --build . -j
RUN cmake --build . --target install

FROM ubuntu:20.04 as runtime

# install monetdb runtime dependencies
# TODO: which of these dependencies is actually necessary?
RUN apt-get update && \
    DEBIAN_FRONTEND="noninteractive" \
    TZ="Europe/Amsterdam" \
    apt-get install -y libcurl4-gnutls-dev readline-common \
                       libpcre3 libssl1.1 libgdal-dev \
                       gdal-bin libgeos-dev  && \
    rm -rf /var/lib/apt

# copy MonetDB install from build container

RUN rm -rf /usr/local
COPY --from=build /usr/local /usr/local

# start init script directory
RUN mkdir /initdb

# set env variables defaults

ENV DB_FARM=/var/monetdb5/dbfarm
ENV DB_NAME=demo
ENV DB_USER=monetdb
ENV DB_PASSWORD=monetdb

# copy start script and run it

COPY scripts/boot_vesselai.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/boot_vesselai.sh

EXPOSE 50000

ENTRYPOINT /usr/local/bin/boot_vesselai.sh ${DB_FARM} \
           ${DB_NAME} ${DB_USER} ${DB_PASSWORD}
