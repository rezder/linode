#!/bin/bash
docker run --rm --volumes-from batt -v $(pwd):/currdir ubuntu cp -r /currdir/server/htmlroot/ /server/;
