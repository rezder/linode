#!/bin/bash
cd ~/linode/docker/nginx
docker build -t imgnginx .
docker network create --driver bridge webnet
docker run -d --name nginx -p 80:80 --network webnet imgnginx


cd ~/linode/docker/letsencrypt
docker build -t imgletsencrypt .
# Make data volume
docker run --name letsencrypt-data -v /etc/letsencrypt -v /var/log/letsencrypt imgletsencrypt ls
# Create certs
docker run --rm \
       --volumes-from nginx \
       --volumes-from letsencrypt-data \
       imgletsencrypt \
       letsencrypt certonly \
       --webroot \
       -w /var/www/html/rezder \
       -d rezder.com \
       -d www.rezder.com \
       -w /var/www/html/battleline \
       -d battleline.rezder.com \
       -m wwwrene@runbox.com \
       --agree-tos \
       --dry-run \
       -n;
## Warning remove dry-run

## Copy letsencrypt certs and dh certs
docker run --rm \
       --volumes-from nginx \
       --volumes-from letsencrypt-data \
       -v $(pwd):/currdir
       ubuntu \
       cp /etc/letsencrypt/live/rezder.com/privkey.pem  /etc/nginx/certs/rezder; \
    cp /etc/letsencrypt/live/rezder.com/fullchain.pem  /etc/nginx/certs/rezder; \
    cp /currdir/dhparams.pem etc/nginx/certs/dh/;

docker stop nginx
## Start with new ports
docker run -d --name cnginx --volumes-from nginx -p 80:80 -p 443:443 --network webnet imgnginx
## New config file
docker run --rm --volumes-from cnginx -v $(pwd):/currdir ubuntu cp /currdir/nginx.conf /etc/nginx/;
docker kill --signal=HUP cnginx
## next install rezder
cd ~/linode/docker/nginx/rezder
bash install.sh
### setup battAll and install it with ~/linode/docker/battleline/nginx/install.sh


