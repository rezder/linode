# Based on Ubuntu
############################################################

# Set the base image to Ubuntu
FROM ubuntu

# File Author / Maintainer
MAINTAINER Rene

# Install Battarchiver

# Install necessary tools
RUN apt-get update && apt-get install -y nano wget dialog net-tools

# Install zeromq
RUN apt-get update -y && apt-get install -y libtool autoconf automake make g++ uuid-dev

WORKDIR /tmp

RUN wget https://github.com/zeromq/libzmq/releases/download/v4.2.0/zeromq-4.2.0.tar.gz && tar -xvf zeromq-4.2.0.tar.gz && cd zeromq-* && ./configure && make install && ldconfig && cd .. && rm -rf zeromq*
RUN apt-get purge -y libtool autoconf automake make g++ uuid-dev

# Copy a tar.gz file from the current directory
# It is automaticly extracted by docker
RUN mkdir /arch
WORKDIR /arch
ADD archup.tar.gz /arch

VOLUME ["/arch/data"] #I this create dir if it does not exist
## Start the server
## battarchiver -client="batt:7171" -addr="arch" -backupport="8282" -dbfile="/arch/data/bdb.db"
ENTRYPOINT ["./battarchiver"]
