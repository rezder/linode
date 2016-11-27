#!/bin/bash
mv nginxdata.tar.gz confdata.old.tar.gz
rm nginxdata.tar.gz

docker run --rm --volumes-from vnginx -v $(pwd):/backup ubuntu \
       tar cvf /backup/nginxdata.tar /etc/nginx/sites-enabled \
       /etc/nginx/certs \
       /etc/nginx/conf.d \
       /var/www/html;

gzip nginxdata.tar
