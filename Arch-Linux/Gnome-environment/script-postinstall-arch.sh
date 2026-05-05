#!/bin/bash

set -e

echo "=== ARCH LINUX POST-INSTALLATION SCRIPT ==="
if [ "$EUID" -eq 0 ]; then
  echo "ERROR: Run this script as normal user."
  exit 1
fi

sudo -v

if ! ping -c 1 google.com &> /dev/null; then
  echo "ERROR: No internet connection. Please connect to a network and try again."
  exit 1
fi

echo "=== PACMAN CONFIGURATION ==="
sudo sed -i 's/^#ParallelDownloads/ParallelDownloads/' /etc/pacman.conf
sudo sed -i 's/^#Color/Color/' /etc/pacman.conf

if ! grep -q "ILoveCandy" /etc/pacman.conf; then
    sudo sed -i '/^Color/a ILoveCandy' /etc/pacman.conf
fi

echo "=== UPDATE ==="
sudo pacman -Syu --noconfirm

echo "=== INSTALLING PACKAGES ==="
BASE_PKGS="base-devel intel-ucode ufw pipewire pipewire-pulse wireplumber pulsemixer bluez bluez-utils brightnessctl"
GENERAL_PKGS="curl duf wget rustup flatpak python-pip croc libsecret extension-manager ttf-nerd-fonts-symbols ttf-jetbrains-mono-nerd nautilus htop ranger less bat firefox cmatrix nano micro man-db man-pages vim git fastfetch bc imv mpv eza wev"
CLI_PKGS="alacritty zsh zsh-autosuggestions zsh-syntax-highlighting tmux pkgfile"
GNOME_PKGS="gdm gnome-shell gnome-keyring gnome-control-center xorg-xwayland"

COMPRESSION_PKGS="unzip zip p7zip unrar"
sudo pacman -S --noconfirm --needed $BASE_PKGS $GENERAL_PKGS $CLI_PKGS $GNOME_PKGS $COMPRESSION_PKGS
rustup default stable

echo "=== YAY CONFIG ==="

if ! command -v yay &> /dev/null; then
    cd /tmp
    git clone https://aur.archlinux.org/yay-bin.git
    cd yay-bin
    makepkg -si --noconfirm
    cd ~
fi

AUR_PKGS="brave-bin visual-studio-code-bin virtualbox-bin dbeaver-ce-bin noto-fonts noto-fonts-emoji noto-fonts-cjk bitwarden-cli"
yay -S --noconfirm --needed $AUR_PKGS

echo "=== CONFIGS ==="
sudo pkgfile -u
sudo systemctl enable pkgfile-update.timer
sudo systemctl enable gdm.service
sudo systemctl enable bluetooth.service
sudo systemctl enable ufw.service
sudo systemctl enable power-profiles-daemon.service

sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw --force enable

sudo chsh -s $(which zsh) $USER

echo 'SSH_AUTH_SOCK DEFAULT="${XDG_RUNTIME_DIR}/keyring/ssh"' | sudo tee -a /etc/environment
git config --global credential.helper /usr/lib/git-core/git-credential-libsecret

flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
source /etc/profile.d/flatpak.sh

dbus-run-session gsettings set org.gnome.shell disable-extension-version-validation true
dbus-run-session gsettings set org.gnome.mutter center-new-windows true

sudo touch /etc/sysctl.d/99-sysrq.conf
echo "kernel.sysrq=1" | sudo tee -a /etc/sysctl.d/99-sysrq.conf > /dev/null

clear
echo "=============== ...FINISHING... ==============="
duf
echo "==============================================="
ip -brief addr
echo "==============================================="
echo "--- UFW ----"
sudo ufw status
echo "==============================================="
echo "Welcome to the Arch side of the force! BTW <3"
fastfetch
echo ""
echo "==============================================="
echo "Please reboot your system..."

