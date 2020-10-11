# substitute BRANCH with your branch
FROM ubuntu:20.04
ENV DEBIAN_FRONTEND noninteractve

# install monetdb build dependencies
RUN apt-get update && \
    apt-get install -y cmake python3-dev python3-pip curl bison libpcre3-dev libssl-dev mercurial

# download and extract monetdb
WORKDIR /tmp 
RUN wget https://www.monetdb.org/hg/MonetDB/archive/BRANCH.tar.bz2 -O MonetDB.tar.bz2 
RUN tar jxf MonetDB.tar.bz2

RUN mkdir /tmp/MonetDB-BRANCH/build
WORKDIR /tmp/MonetDB-BRANCH/build 
RUN cmake .. -DWITH_CRYPTO=OFF -DINT128=OFF -DPY3INTEGRATION=OFF -DCMAKE_BUILD_TYPE=Release -DASSERT=OFF -DSTRICT=OFF -DRINTEGRATION=OFF
RUN cmake --build .
RUN cmake --build . --target install

# preinstall dependencies
RUN pip3 install --upgrade pip pytest numpy pandas mypy pycodestyle

# add shared libraries to wheels
ENV LD_LIBRARY_PATH "${LD_LIBRARY_PATH}:/usr/local/lib"

