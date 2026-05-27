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

# general
apt install -y sudo htop micro git curl zsh bat eza ncdu duf wget neovim tmux build-essential unzip openssh-server ufw net-tools dnsutils dkms

# Other
apt install -y fastfetch fbterm fontconfig fonts-jetbrains-mono fonts-noto-color-emoji zsh-autosuggestions zsh-syntax-highlighting command-not-found
# talvez: virtualbox-guest-dkms virtualbox-guest-utils


# Python utils
apt install -y python-is-python3 pipx python3-pip python3-venv

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

## zsh conf
mv zshrc.txt .zshrc
chsh -s $(which zsh)

## pipx conf
pipx ensurepath

## ssh
systemctl enable --now ssh

pipx install git+https://github.com/will8211/unimatrix.git

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
echo "Welcome to Debian TTY environment!"
echo "PLease, reboot the system to fully apply the updates."
