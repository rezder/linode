#!/bin/bash
MYDIR="$(dirname "$(realpath "$0")")"
scp "$1" rho@rezder.com:/home/rho/upload/octave
