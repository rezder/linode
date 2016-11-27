#!/bin/bash
docker run --rm --volumes-from vnginx -v $(pwd):/currdir ubuntu cp /currdir/nginx.conf /etc/nginx;
docker kill --signal=HUP vnginx
