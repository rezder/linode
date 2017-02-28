#!/bin/bash
d=~/backup/
touch ${d}battdata.tar.gz
mv ${d}battdata.tar.gz ${d}battdata.old.tar.gz

serverN=${1:-batt}
docker run --rm --volumes-from "$serverN" -v ${d}:/backup ubuntu tar cvf /backup/battdata.tar /batt/data
gzip ${d}battdata.tar

archN=${2:-arch}
touch ${d}archdata.tar.gz
mv ${d}archdata.tar.gz ${d}archdata.old.tar.gz

docker run --rm --volumes-from "$archN" -v ${d}:/backup ubuntu tar cvf /backup/battdata.tar /arch/data
gzip ${d}archdata.tar

touch ${d}letsdata.tar.gz
mv ${d}letsdata.tar.gz ${d}letsdata.old.tar.gz

docker run --rm --volumes-from letsencrypt-data -v ${d}:/backup ubuntu \
       tar cvf /backup/letsdata.tar \
       /etc/letsencrypt \
       /var/lib/letsencrypt;

gzip ${d}letsdata.tar

touch ${d}nginxdata.tar.gz
mv ${d}nginxdata.tar.gz ${d}nginxdata.old.tar.gz

docker run --rm --volumes-from cnginx -v ${d}:/backup ubuntu \
       tar cvf /backup/nginxdata.tar /etc/nginx/sites-enabled \
       /etc/nginx/certs \
       /etc/nginx/conf.d \
       /var/www/html;

gzip ${d}nginxdata.tar
