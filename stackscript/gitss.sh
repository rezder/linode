#!/bin/bash

# <UDF name="username" label="Unprivileged user name" example="This will be the user who will be able to SSH into the server." />
# <UDF name="userpass" label="Unprivileged user password" />
# <UDF name="userpubkey" label="Public key for the user" default="" example="Should look like 'ssh-rsa AAABBB1x2y3z...'" />
# <UDF name="nopass" label="Disable password authentication for SSH?" oneof="Yes,No" default="Yes" />
# <UDF name="sshport" label="SSH port" default="22" example="It is a good idea to set this to something other than the default of 22."/>
# <UDF name="locale" label="Locale" default="en_US.UTF-8 UTF-8" />
# <UDF name="settz" label="Set the appropriate timezone based on datacenter location?" oneof="Yes,No" default="Yes" />
# <UDF name="hostname" label="Host name" example="This is the name of your server."/>
# <UDF name="gituser" label="Git user name" />
# <UDF name="gitmail" label="Git user email" />


# Update and optimize mirrorlist for pacman
pacman -Sy --noconfirm reflector
mv /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.old
wget https://www.archlinux.org/mirrorlist/all/ -O /etc/pacman.d/mirrorlist
reflector --protocol http --sort rate --fastest 6 --threads 10 --save /etc/pacman.d/mirrorlist

# Update system
pacman -Syu --noconfirm

# Set up the hostname
echo $HOSTNAME > /etc/hostname
hostname -F /etc/hostname

# Set the locale
sed -i '/en_US.UTF-8 UTF-8/s/^#//g' /etc/locale.gen
if [ "$LOCALE" != 'en_US.UTF-8 UTF-8' ]; then
  sed -i "/$LOCALE/s/^#//g" /etc/locale.gen
fi
locale-gen

# Set up the correct TZ
if [ "$SETTZ" == 'Yes' ]; then
    case $LINODE_DATACENTERID in
        2) TZ="US/Central" ;;
        3) TZ="US/Pacific" ;;
        4) TZ="US/Eastern" ;;
        6) TZ="US/Eastern" ;;
        7) TZ="Europe/London" ;;
        8) TZ="Asia/Tokyo" ;;
        9) TZ="Asia/Singapore" ;;
        10) TZ="Europe/Berlin" ;;
        *) TZ="UTC" ;;
    esac
else
    TZ="UTC"
fi
ln -sf /usr/share/zoneinfo/$TZ /etc/localtime

# Set up an non-privileged user and sudo
useradd -m -g users -G wheel $USERNAME
passwd $USERNAME <<EOF
$USERPASS
$USERPASS
EOF
sed -i 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers

# Set up sshd: disable root login, ensure SSH2, set up password auth, and allow the unprivileged user to login
sed -i 's/^[# ]*PermitRootLogin \(yes\|no\)/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i "s/^[# ]*Port [0-9]\+/Port $SSHPORT/" /etc/ssh/sshd_config
sed -i 's/^[# ]*Protocol \([0-9],\?\)\+/Protocol 2/' /etc/ssh/sshd_config
if [ "$NOPASS" == 'Yes' ]; then
    sed -i 's/^[# ]*PasswordAuthentication \(yes\|no\)/PasswordAuthentication no/' /etc/ssh/sshd_config
fi
# Allow only the unprivileged user to log on
echo "AllowUsers $USERNAME" >> /etc/ssh/sshd_config
if [ -n "$USERPUBKEY" ]; then
    sed -i 's/^[# ]*PubkeyAuthentication \(yes\|no\)/PubkeyAuthentication yes/' /etc/ssh/sshd_config
    mkdir -p /home/$USERNAME/.ssh
    echo "$USERPUBKEY" >> /home/$USERNAME/.ssh/authorized_keys
    chown -R "$USERNAME" /home/$USERNAME/.ssh
fi
systemctl restart sshd

# Install ntp to keep your clock in sync
pacman -S --nconfirm ntp
systemctl enable ntpd.service
timedatectl set-ntp 1

# Set up a firewall (UFW). Don't forget to "ufw allow" other ports if needed.
pacman -S --noconfirm ufw
ufw default deny
ufw allow $SSHPORT
ufw limit $SSHPORT
ufw enable


# Install git sets globally user name, email and outcrlf
# the last setting is handle windows and linux end of line problems.
pacman -S --noconfirm git
git config --global user.name  $GITUSER
git config --global user.email $GITMAIL
git config --globa lcore.autocrlf "input"
