############################################################
# Dockerfile to build Battleline web server.
# Based on Ubuntu
############################################################

# Set the base image to Ubuntu
FROM ubuntu

# File Author / Maintainer
MAINTAINER Rene

# Install Battleline

# Add application repository URL to the default sources
RUN echo "deb http://archive.ubuntu.com/ubuntu/ raring main universe" >> /etc/apt/sources.list

# Update the repository
RUN apt-get update

# Install necessary tools
RUN apt-get install -y nano wget dialog net-tools

# Copy a tar.gz file from the current directory
ADD battup.tar.gz

# Extract
RUN tar -xzf batt.tar.gz

## When run set the port with -e BATTLINE_ENV_PORT='8181'
## Start the server
CMD battserver -port=BATTLINE_ENV_PORT  2>> /data/log.txt 
