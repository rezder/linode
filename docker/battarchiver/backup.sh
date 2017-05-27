#!/bin/bash
# Must login to archiver docker (arch) to use localhost else login to webnet and use arch.
docker run --rm -v $(pwd):/currdir --network webnet battbase wget -O currdir/backup.db "http://arch:8282/backup" 
gzip backup.db
