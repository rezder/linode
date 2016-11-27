############################################################
# Dockerfile to build Battleline web server.
# Based on Ubuntu
############################################################

# Set the base image to Ubuntu
FROM ubuntu

# File Author / Maintainer
MAINTAINER Rene

# Install Battleline

# Install necessary tools
RUN apt-get update && apt-get install -y nano wget dialog net-tools

# Copy a tar.gz file from the current directory
# It is automaticly extracted by docker
ADD battup.tar.gz /

EXPOSE $BATTLINE_ENV_PORT 

## When run set the port with -e BATTLINE_ENV_PORT='8181'
## Start the server
CMD ./battserver -port=$BATTLINE_ENV_PORT 2>> /data/log.txt 
