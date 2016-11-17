#!/bin/bash
pacman -S docker

# may be need:
#
# tee /etc/modules-load.d/loop.conf <<< "loop"
# modprobe loop
#
# and a reboot

systemctl start docker.service
systemctl enable docker.service

# check that it works
docker info

# Add user to user group
gpasswd -a rho docker
newgrp docker

# setup mordern disk system
echo "[Service]">>/etc/systemd/system/docker.service.d/override.conf
echo "ExecStart=">>/etc/systemd/system/docker.service.d/override.conf
echo "ExecStart=/usr/bin/dockerd -H fd:// -s overlay2">>/etc/systemd/system/docker.service.d/override.conf

