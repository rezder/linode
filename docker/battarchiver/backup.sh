#!/bin/bash
# Must login to archiver docker (arch) to use localhost else login to webnet and use arch.
docker run --rm -v $(pwd):/currdir arch curl "http://localhost:8282/backup" >backup.db;
gzip backup.db
