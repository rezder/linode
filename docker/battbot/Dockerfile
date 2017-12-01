# Based on Ubuntu
############################################################

# Set the base image to Ubuntu
FROM ubuntu

# File Author / Maintainer
MAINTAINER Rene

# Install Battbot

# Install standard tools all batt use them for now.
RUN apt-get update && apt-get install -y nano wget dialog net-tools

# Install zero message queue
RUN apt-get update -y && apt-get install -y libtool autoconf automake make g++ uuid-dev

WORKDIR /tmp

RUN wget https://github.com/zeromq/libzmq/releases/download/v4.2.0/zeromq-4.2.0.tar.gz && tar -xvf zeromq-4.2.0.tar.gz && cd zeromq-* && ./configure && make install && ldconfig && cd .. && rm -rf zeromq*
RUN apt-get purge -y libtool autoconf automake make g++ uuid-dev

RUN mkdir /bot
WORKDIR /bot

# Copy a tar.gz file from the current directory
# It is automaticly extracted by docker
ADD botup.tar.gz /bot

## Start the server
##-gameurl=batt:8282 -name=username -pw=password
ENTRYPOINT ["/bot/battbot2"]

