############################################################
# Dockerfile to build Battleline web server.
# Based on Ubuntu
############################################################

# Set the base image to Ubuntu
FROM ubuntu

# File Author / Maintainer
MAINTAINER Rene

# Install Battleline

# Install necessary standard tools
RUN apt-get update && apt-get install -y nano wget dialog net-tools

# Install zero message queue
RUN apt-get update && apt-get zeromq

# Copy a tar.gz file from the current directory
# It is automaticly extracted by docker
ADD battup.tar.gz /

EXPOSE 8181

# Volumes data logs and user and html pages
VOLUME ["/data", "/html"]

## Start the server
CMD ["./battserver"]
