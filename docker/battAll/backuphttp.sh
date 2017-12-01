#!/bin/bash
#backup using http server. The server must be running else use volume backup
#WARNING the http back is files not the data directory
d=~/backup/
touch ${d}battdata.tar.gz
mv ${d}battdata.tar.gz ${d}battdata.old.tar.gz

archN=${2:-arch}
serverN=${1:-batt}
docker run --rm -v $(pwd):/currdir --network webnet battbase \
       "wget -O currdir/savegames.db http://${serverN}:8888/backup/games; wget -O currdir/clients.db http://${serverN}:8888/backup/clients; wget -O currdir/bdb.db http://${archN}:8282/backup/clients"

tar cfz ${d}battdata.tar.gz clients.db games.db
rm savegames.db
rm clients.db

touch ${d}archdata.tar.gz
mv ${d}archdata.tar.gz ${d}archdata.old.tar.gz

tar cfz ${d}archdata.tar bdb.db
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
