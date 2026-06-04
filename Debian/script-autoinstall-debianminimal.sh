#!/bin/bash
set -e

#garante que o script rode com root
if [ "$EUID" -ne 0 ]; then
    echo "Error: Run as root."
    exit 1
fi

# coleta o usuário real que rodou o script
REAL_USER=""
if [ -n "$SUDO_USER" ]; then
    REAL_USER="$SUDO_USER"
elif [ -n "$PKEXEC_UID" ]; then
    REAL_USER=$(id -nu "$PKEXEC_UID")
else
    REAL_USER=$(who am i | awk '{print $1}')
fi

if [ -z "$REAL_USER" ] || [ "$REAL_USER" = "root" ]; then
    echo "Error: Common user not detected."
    exit 1
fi

apt update -y && apt upgrade -y

apt remove -y bluez bluetooth alsa-topology-conf alsa-ucm-conf wireless-tools wireless-regdb xdg-user-dirs xkb-data

# general
apt install -y sudo htop micro git curl bat eza ncdu bison gawk m4 texinfo duf wget neovim tmux systemd-timesyncd build-essential unzip openssh-server ufw dkms linux-headers-$(uname -r) fastfetch

# croc
curl https://getcroc.schollz.com | bash

# configs
## sudo config
usermod -aG sudo luizsousa # configura user como sudo

## ufw conf
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw --force enable

## shell conf
sudo ln -sf /bin/bash /bin/sh

## ssh
systemctl enable ssh

## NTP 
timedatectl set-ntp true

apt autoremove -y

echo "=== STATUS FINAL ==="
echo ""
ip -brief addr || true
echo ""
echo "####################"
echo ""
echo "--- UFW ---"
ufw status || true
echo ""
echo "####################"
echo ""
duf || true
echo ""
echo "####################"
echo ""
systemctl status ssh
echo ""
echo "####################"
echo ""
fastfetch || true
echo ""
echo "####################"
echo ""
echo "Welcome to Debian Minimal TTY environment!"
echo "PLease, reboot the system to fully apply the updates."
