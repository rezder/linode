#!/bin/bash
mv battdata.tar.gz battdata.old.tar.gz
rm battdata.tar.gz
docker run --rm --volumes-from battleline -v $(pwd):/backup ubuntu tar cvf /backup/battdata.tar /data
gzip battdata.tar
