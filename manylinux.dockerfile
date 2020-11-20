# substitute BRANCH with your branch
FROM quay.io/pypa/manylinux2014_x86_64

# install monetdb build dependencies
RUN yum update
RUN yum install -y cmake3 openssl-devel wget

# download and extract monetdb
WORKDIR /tmp 
RUN wget https://www.monetdb.org/hg/MonetDB/archive/BRANCH.tar.bz2 -O MonetDB.tar.bz2 
RUN tar jxf MonetDB.tar.bz2

RUN mkdir /tmp/MonetDB-BRANCH/build
WORKDIR /tmp/MonetDB-BRANCH/build 
RUN cmake3 .. -DWITH_CRYPTO=OFF -DINT128=ON -DPY3INTEGRATION=OFF -DCMAKE_BUILD_TYPE=Release -DASSERT=OFF -DSTRICT=OFF -DRINTEGRATION=OFF
RUN cmake3 --build . 
RUN cmake3 --build . --target install 
RUN rm -rf /tmp/MonetDB-BRANCH

# preinstall dependencies
RUN pip3 install --upgrade pip pytest numpy pandas mypy pycodestyle

# add shared libraries to wheels
ENV LD_LIBRARY_PATH "${LD_LIBRARY_PATH}:/usr/local/lib"

