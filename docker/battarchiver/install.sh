#!/bin/bash

#Build
docker build -t arch:v1 .
#Run
docker run -d --name battarch --network webnet arch:v1 -client="batt:7373" -addr="battarch" -backupport="8282"
state=docker inspect -f {{.State.Running}} battarch
sleep 5

if[ state = "false" ]; then
    docker stop battarch
    exitcode=docker inspect -f {{.State.ExitCode}} battarc
    echo "Test failed container exit with error: $exitcode"
    exit 1
else
    echo "Stopping"
    docker stop battarch
    echo "Stopped"
fi
