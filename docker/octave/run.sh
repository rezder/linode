#!/bin/bash
docker run -d -rm -v /home/rho/upload/octave:/octave/lib imgoctave octave-cli --eval "addpath('lib');${1};"
