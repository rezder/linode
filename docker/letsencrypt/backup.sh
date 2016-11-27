#!/bin/bash
mv letsdata.tar.gz letsdata.old.tar.gz
rm letsdata.tar.gz

docker run --rm --volumes-from letsencrypt-data -v $(pwd):/backup ubuntu \
       tar cvf /backup/letsdata.tar \
       /etc/letsencrypt \
       /var/lib/letsencrypt;

gzip letsdata.tar
