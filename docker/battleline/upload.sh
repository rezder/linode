#!/bin/bash
MYDIR="$(dirname "$(realpath "$0")")"
cd ~/go/src/github.com/rezder/go-battleline/v2/http
go install
mkdir -p /tmp/server/htmlroot
cp -r /home/rho/js/batt-game-app/build/* /tmp/server/htmlroot
cd /tmp
tar -cf battup.tar server/htmlroot
mv battup.tar ~/go/bin
cd ~/go/bin
tar --append --file=battup.tar battserver2
mv battup.tar $MYDIR
cd $MYDIR
gzip battup.tar
scp  battup.tar.gz rho@rezder.com:/home/rho/upload/battleline/battserver/
rm battup.tar.gz
rm -r /tmp/server
