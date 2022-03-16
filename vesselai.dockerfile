FROM ubuntu:20.04 as build

ARG BRANCH=geo-update
ENV DEBIAN_FRONTEND noninteractve

# install monetdb build dependencies

RUN apt-get update && \
    apt-get install -y cmake bison libpcre3-dev libssl-dev wget \
                       python3 libgdal-dev gdal-bin libgeos-dev \
                       libproj-dev unzip libcurl4-gnutls-dev && \
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
    -DGEOM=ON
RUN cmake --build . -j
RUN cmake --build . --target install

FROM ubuntu:20.04 as runtime

ENV DEBIAN_FRONTEND="noninteractive"
ENV TZ="Europe/Amsterdam" 

# install monetdb build dependencies

RUN apt-get update && \
    apt-get install -y python3-pip libpcre3 libssl1.1 libgdal-dev \
                       gdal-bin libgeos-dev libcurl4-gnutls-dev && \
    rm -rf /var/lib/apt

RUN pip3 install --no-cache --upgrade pip pytest numpy pandas mypy \
    pycodestyle

RUN rm -rf /usr/local
COPY --from=build /usr/local /usr/local

# add shared libraries to wheels

ENV LD_LIBRARY_PATH "${LD_LIBRARY_PATH}:/usr/local/lib"

# start monetdb deamon with database demo

ENV DB_FARM=/var/monetdb5/dbfarm

RUN rm -rf ${DB_FARM}
RUN monetdbd create ${DB_FARM}
RUN monetdbd set listenaddr=all /var/monetdb5/dbfarm
RUN monetdbd start ${DB_FARM} \
    && monetdb create demo \
    && monetdb release demo

EXPOSE 50000

CMD ["monetdbd", "start", "-n", "/var/monetdb5/dbfarm"]
