#!/bin/bash

#Backup via http server.
mv battdata.tar.gz battdata.old.tar.gz
docker run --rm -v $(pwd):/currdir --network webnet battbase "wget -O currdir/games.db http://batt:8888/backup/games; wget -O currdir/clients.db http://batt:8888/backup/clients;"
tar cfz battdata.tar.gz clients.db games.db
rm games.db
rm clients.db
