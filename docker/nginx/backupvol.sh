#!/bin/bash
mv nginxdata.tar.gz nginxdata.old.tar.gz

docker run --rm --volumes-from cnginx -v $(pwd):/backup ubuntu \
       tar cvf /backup/nginxdata.tar /etc/nginx/sites-enabled \
       /etc/nginx/certs \
       /etc/nginx/conf.d \
       /var/www/html;

gzip nginxdata.tar
