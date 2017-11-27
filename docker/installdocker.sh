#!/bin/bash
pacman -S docker

# setup mordern disk system

mkdir /etc/systemd/system/docker.service.d
cat <<EOF >/etc/systemd/system/docker.service.d/override.conf
[Service]
ExecStart=
ExecStart=/usr/bin/dockerd -H fd:// -s overlay2
EOF

systemctl start docker.service
systemctl enable docker.service

# check that it works
docker info

# Add user to user group
gpasswd -a rho docker # something strange happen here I ended up as root
newgrp docker


