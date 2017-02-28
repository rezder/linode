# Based on Ubuntu
############################################################

# Set the base image to Ubuntu
FROM ubuntu

# File Author / Maintainer
MAINTAINER Rene


# Install standard tools all batt use them for now.
RUN apt-get update && apt-get install -y nano wget dialog net-tools

# Install zero message queue
RUN apt-get update -y && apt-get install -y libtool autoconf automake make g++ uuid-dev

WORKDIR /tmp

RUN wget https://github.com/zeromq/libzmq/releases/download/v4.2.0/zeromq-4.2.0.tar.gz && tar -xvf zeromq-4.2.0.tar.gz && cd zeromq-* && ./configure && make install && ldconfig && cd .. && rm -rf zeromq*
RUN apt-get purge -y libtool autoconf automake make g++ uuid-dev

CMD ["/bin/bash"]