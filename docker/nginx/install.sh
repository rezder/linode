#!/bin/bash
docker run --rm --volumes-from nginx -v $(pwd):/currdir ubuntu cp /currdir/nginx.conf /etc/nginx/;
docker kill --signal=HUP nginx
