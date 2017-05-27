############################################################
# Dockerfile for Octave with libsvm
# Based on Ubuntu
############################################################

# Set the base image to Ubuntu
FROM ubuntu

# File Author / Maintainer
MAINTAINER Rene

# Install necessary standard tools
RUN apt-get update && apt-get install -y nano wget dialog net-tools

# Install libsvm
RUN apt-get update -y && apt-get install -y libtool autoconf automake make g++ uuid-dev

WORKDIR /tmp

RUN wget -O libsvm-3.22.tar.gz http://www.csie.ntu.edu.tw/~cjlin/cgi-bin/libsvm.cgi?+http://www.csie.ntu.edu.tw/~cjlin/libsvm+tar.gz && tar -xvf libsvm-3.22.tar.gz && cd libsvm-* && make && cd .. && rm -rf lidsvm*

# Install octave
RUN apt-get update -y && apt-get install -y octave liboctave-dev

# Install octave libsvm for some reason the make.m does not when run as a command.
# used --eval instead

Run cd /tmp/libsvm*/matlab && octave-cli --eval 'make()' && cd .. && cp -a matlab/. /octave/libsvm/
Run mkdir /octave && mkdir /octave/libsvm && cd /tmp/libsvm*/matlab && octave-cli --eval 'make()' && cd .. && cp -a matlab/. /octave/libsvm/

RUN apt-get purge -y libtool autoconf automake make g++ uuid-dev #comment out because it is need run make manauly

WORKDIR /octave
CMD ["/bin/bash"]
