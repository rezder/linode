#!/bin/bash
MYDIR="$(dirname "$(realpath "$0")")"
cd ~/go/src/github.com/rezder/go-battleline/battserver
go install
tar -cf battup.tar html/static html/pages
mv battup.tar ~/go/bin
cd ~/go/bin
tar --append --file=battup.tar battserver
mv battup.tar $MYDIR
cd $MYDIR
gzip battup.tar
##scp rho@rezder.com:battup.tar.gz /updload/battleline