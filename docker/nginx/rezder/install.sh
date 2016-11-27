#!/bin/bash
docker run --rm --volumes-from vnginx -v $(pwd):/currdir ubuntu cp -r /currdir/html/rezder /var/www/html/;
docker run --rm --volumes-from vnginx -v $(pwd):/currdir ubuntu cp /currdir/rezder.conf /etc/nginx/sites-enabled;
docker run --rm --volumes-from vnginx ubuntu rm /etc/nginx/sites-enabled/default;
docker kill --signal=HUP vnginx
