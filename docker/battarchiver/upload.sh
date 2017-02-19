#!/bin/bash
MYDIR="$(dirname "$(realpath "$0")")"
cd ~/go/src/github.com/rezder/go-battleline/battarchiver
go install
cd ~/go/bin
tar -cf archup.tar battarchiver
mv archup.tar $MYDIR
cd $MYDIR
gzip archup.tar
scp  archup.tar.gz rho@rezder.com:/home/rho/upload/battleline/battarchiver
rm archup.tar.gz
