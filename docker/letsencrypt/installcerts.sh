#!/bin/bash
docker run --rm --volumes-from cnginx --volumes-from letsencrypt-data ubuntu \
       "cp /etc/letsencrypt/live/rezder.com/fullchain.pem /etc/nginx/certs/rezder/; cp /etc/letsencrypt/live/rezder.com/privkey.pem /etc/nginx/certs/rezder/;"
docker kill --signal=HUP cnginx

