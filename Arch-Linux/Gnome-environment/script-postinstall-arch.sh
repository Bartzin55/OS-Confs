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
BASE_PKGS="base-devel intel-ucode ufw pipewire pipewire-pulse bind wireplumber pulsemixer bluez bluez-utils brightnessctl"
GENERAL_PKGS="curl duf wget rustup python-pip libsecret ttf-nerd-fonts-symbols ttf-jetbrains-mono-nerd terminus-font nautilus htop ranger less bat nano micro man-db man-pages vim git fastfetch bc imv mpv eza wev"
CLI_PKGS="pkgfile"
GUI_PKGS="gdm gnome-shell gnome-keyring gnome-control-center extension-manager xorg-xwayland"
COMPRESSION_PKGS="unzip zip p7zip unrar"

sudo pacman -S --noconfirm --needed $BASE_PKGS $GENERAL_PKGS $CLI_PKGS $GUI_PKGS $COMPRESSION_PKGS
rustup default stable

git clone --recursive --depth 1 https://github.com/akinomyoga/ble.sh.git
make -C ble.sh install PREFIX=~/.local

rm -rf ble.sh

echo "=== YAY CONFIG ==="

if ! command -v yay &> /dev/null; then
    cd /tmp
    git clone https://aur.archlinux.org/yay-bin.git
    cd yay-bin
    makepkg -si --noconfirm
    cd ~
fi

AUR_PKGS="bash-completion ttf-ms-fonts alacritty drawing debtap tmux brave-bin firefox openssh croc plymouth tailscale  speech-dispatcher plymouth-theme-arch-charge gnome-clocks visual-studio-code-bin virtualbox-bin dbeaver-ce-bin noto-fonts noto-fonts-emoji noto-fonts-cjk bitwarden-cli bibata-cursor-theme-bin"
yay -S --noconfirm --needed $AUR_PKGS

sudo VBoxManage extpack install Oracle_VM_VirtualBox_Extension_Pack.vbox-extpack

echo "=== CONFIGS ==="
sudo pkgfile -u
sudo systemctl enable pkgfile-update.timer
sudo systemctl enable gdm.service
sudo systemctl enable bluetooth.service
sudo systemctl enable ufw.service
sudo systemctl enable power-profiles-daemon.service
sudo systemctl enable sshd
sudo systemctl enable tailscaled

sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw --force enable

sudo usermod -aG vboxusers $USER

# boot sem os OKs, ainda fazer
## editar hooks do /etc/mkinitcpio.conf
#sudo mkinitcpio -P
## editar arch.conf (o nome as vezes n é esse)
#sudo systemctl enable plymouth-quit-wait.service
#sudo plymouth-set-default-theme -R arch-charge

echo 'SSH_AUTH_SOCK DEFAULT="${XDG_RUNTIME_DIR}/keyring/ssh"' | sudo tee -a /etc/environment
git config --global credential.helper /usr/lib/git-core/git-credential-libsecret

flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
source /etc/profile.d/flatpak.sh

dbus-run-session gsettings set org.gnome.shell disable-extension-version-validation true
dbus-run-session gsettings set org.gnome.mutter center-new-windows true
dbus-run-session gsettings set org.gnome.desktop.interface cursor-theme 'Bibata-Modern-Classic'

sudo touch /etc/sysctl.d/99-sysrq.conf
echo "kernel.sysrq=1" | sudo tee -a /etc/sysctl.d/99-sysrq.conf > /dev/null

# bash-completion configuration
touch .inputrc
echo "set show-all-if-ambiguous on" >> /home/$USER/.inputrc
echo "set show-all-if-unmodified on" >> /home/$USER/.inputrc
echo "set menu-complete-display-prefix on" >> /home/$USER/.inputrc
echo "TAB: menu-complete" >> /home/$USER/.inputrc

#Gnome menu configuration
cp /usr/share/applications /home/$USER/.local/share/ -r
echo "NoDisplay=true" >> /home/$USER/.local/share/applications/avahi-discover.desktop
echo "NoDisplay=true" >> /home/$USER/.local/share/applications/bssh.desktop
echo "NoDisplay=true" >> /home/$USER/.local/share/applications/bvnc.desktop
echo "NoDisplay=true" >> /home/$USER/.local/share/applications/vim.desktop
echo "NoDisplay=true" >> /home/$USER/.local/share/applications/ranger.desktop
echo "NoDisplay=true" >> /home/$USER/.local/share/applications/mpv.desktop
echo "NoDisplay=true" >> /home/$USER/.local/share/applications/micro.desktop
echo "NoDisplay=true" >> /home/$USER/.local/share/applications/htop.desktop
echo "NoDisplay=true" >> /home/$USER/.local/share/applications/jconsole-java-openjdk.desktop
echo "NoDisplay=true" >> /home/$USER/.local/share/applications/jshell-java-openjdk.desktop
echo "NoDisplay=true" >> /home/$USER/.local/share/applications/qv4l2.desktop
echo "NoDisplay=true" >> /home/$USER/.local/share/applications/qvidcap.desktop
echo "NoDisplay=true" >> /home/$USER/.local/share/applications/linguist.desktop
echo "NoDisplay=true" >> /home/$USER/.local/share/applications/assistant.desktop
echo "NoDisplay=true" >> /home/$USER/.local/share/applications/designer.desktop
echo "NoDisplay=true" >> /home/$USER/.local/share/applications/qdbusviewer.desktop
echo "NoDisplay=true" >> /home/$USER/.local/share/applications/org.gnome.Extensions.desktop

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

