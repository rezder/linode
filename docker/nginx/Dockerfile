# Set the base image to Ubuntu
FROM ubuntu

# File Author / Maintainer
MAINTAINER Rene

# Install Nginx

# Install necessary tools
RUN apt-get update && apt-get install -y nano wget dialog net-tools software-properties-common

# Add application repository URL to the default sources
RUN add-apt-repository ppa:nginx/stable

# Download and Install Nginx
RUN apt-get install -y nginx


VOLUME ["/etc/nginx", "/var/log/nginx", "/var/www/html"]

# Expose ports this is info only the run command open the port
EXPOSE 80 443

# Set the default command to execute
# when creating a new container
CMD ["nginx", "-g", "daemon off;"]