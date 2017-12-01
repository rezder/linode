#!/bin/bash
MYDIR="$(dirname "$(realpath "$0")")"
cd ~/go/src/github.com/rezder/go-battleline/v2/cmd/battbot2
go install
cd ~/go/bin
tar -cf botup.tar battbot2
mv botup.tar $MYDIR
cd $MYDIR
gzip botup.tar
scp  botup.tar.gz rho@rezder.com:/home/rho/upload/battleline/battbot
rm botup.tar.gz
