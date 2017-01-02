# Based on Ubuntu
############################################################

# Set the base image to Ubuntu
FROM ubuntu

# File Author / Maintainer
MAINTAINER Rene

# Install Battbot

# Install necessary tools
RUN apt-get update && apt-get install -y nano wget dialog net-tools

# Copy a tar.gz file from the current directory
# It is automaticly extracted by docker
ADD botup.tar.gz /

## Start the server
##-addr=battserver -port=8181 -name=username -pw=password
ENTRYPOINT ["./battbot"] 
