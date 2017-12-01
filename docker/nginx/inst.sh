#!/bin/bash
cd ~/linode/docker/nginx
docker build -t imgnginx .
docker network create --driver bridge webnet
docker run -d --name nginx -p 80:80 --network webnet imgnginx
# Install pre cert pages and letsencrypt.conf snippet.
docker run --rm --volumes-from nginx ubuntu rm /etc/nginx/sites-enabled/default;

docker run --rm --volumes-from nginx -v /home/rho/linode/docker/nginx/rezder:/currdir ubuntu cp -r /currdir/html/rezder /var/www/html/;

docker run --rm --volumes-from nginx -v /home/rho/linode/docker/nginx/rezder:/currdir ubuntu cp -r /currdir/html/rezder /var/www/html/;
docker run --rm --volumes-from nginx -v /home/rho/linode/docker/nginx/rezder:/currdir ubuntu cp /currdir/rezderpre.conf /etc/nginx/sites-enabled/rezder.conf;

docker run --rm --volumes-from nginx -v /home/rho/linode/docker/battleline/nginx:/currdir ubuntu cp -r /currdir/html/battleline /var/www/html/;
docker run --rm --volumes-from nginx -v /home/rho/linode/docker/battleline/nginx:/currdir ubuntu cp /currdir/battlelinepre.conf /etc/nginx/sites-enabled/battleline/conf;

docker kill --signal=HUP cnginx

cd ~/linode/docker/letsencrypt
docker build -t imgletsencrypt .
# Make incrypt data volumes image.
docker run --name letsencrypt-data -v /etc/letsencrypt -v /var/log/letsencrypt imgletsencrypt ls
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

## Copy letsencrypt certs and dh certs rember to upload dhparam.pem from rho/dhparams/dhparam.pem
docker run --rm \
       --volumes-from nginx \
       --volumes-from letsencrypt-data \
       -v $(pwd):/currdir \
       ubuntu \
       "cp /etc/letsencrypt/live/rezder.com/privkey.pem  /etc/nginx/certs/rezder; cp /etc/letsencrypt/live/rezder.com/fullchain.pem  /etc/nginx/certs/rezder; cp /currdir/dhparam.pem etc/nginx/certs/dh/;"

docker stop nginx
## Start with new ports
docker run -d --name cnginx --volumes-from nginx -p 80:80 -p 443:443 --network webnet imgnginx
## New config file
docker run --rm --volumes-from cnginx -v /home/rho/linode/docker/nginx:/currdir ubuntu cp /currdir/nginx.conf /etc/nginx/;
## Install (www).rezder.com
docker run --rm --volumes-from cnginx -v /home/rho/linode/docker/nginx/rezder:/currdir ubuntu cp /currdir/rezderpost.conf /etc/nginx/sites-enabled/rezder.conf;
### setup battleline.rezder.com
docker run --rm --volumes-from nginx -v /home/rho/linode/docker/battleline/nginx:/currdir ubuntu cp /currdir/battlelinepost.conf /etc/nginx/sites-enabled/battleline.conf;
docker kill --signal=HUP cnginx
