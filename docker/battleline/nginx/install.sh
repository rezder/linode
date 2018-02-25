#!/bin/bash
#install the nginx part of battleline
cd ~/linode/docker/battleline/nginx
docker run --rm --volumes-from cnginx -v $(pwd):/currdir ubuntu cp -r /currdir/html/battleline /var/www/html/;
docker run --rm --volumes-from cnginx -v $(pwd):/currdir ubuntu cp /currdir/battlelinepost.conf /etc/nginx/sites-enabled/battleline.conf;
docker kill --signal=HUP nginx
