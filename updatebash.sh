#!/bin/bash
cat <<EOF >~/.bashrc
alias hi='history|grep'
alias ll='ls -lAh'
export HISTIGNORE="ls:ll:cd:pwd"
export HISTFILESIZE=1000
export HISTSIZE=1000
EOF
