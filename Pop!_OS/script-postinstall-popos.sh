#!/bin/bash
set -e

# Garante que está rodando como root
if [ "$EUID" -ne 0 ]; then
  echo "Por favor, rode este script com sudo."
  exit 1
fi

export DEBIAN_FRONTEND=noninteractive

USER_NAME=${SUDO_USER:-$USER}
USER_HOME=$(eval echo "~$USER_NAME")

echo "=== CONFIGURAÇÃO INICIAL ==="
# --force para não pedir confirmação e travar o script
ufw --force enable

if command -v fwupdmgr >/dev/null 2>&1; then
  fwupdmgr refresh || true
  fwupdmgr get-updates || true
  fwupdmgr update -y || true
fi

echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | debconf-set-selections

echo "=== ATUALIZAÇÃO DO SISTEMA ==="
apt update -y
apt upgrade -y

echo "=== REMOÇÃO DE SOFTWARE DESNECESSÁRIO ==="
apt remove -y baobab file-roller eog gucharmap cosmic-edit cosmic-player evince gnome-font-viewer gnome-icon-theme gnome-power-manager libreoffice* orca repoman simple-scan steam-devices thunderbird popsicle || true

echo "=== ESSENCIAIS ==="
apt install -y software-properties-common build-essential ubuntu-restricted-extras timeshift linux-headers-$(uname -r)

echo "=== GERAL ==="
apt install -y htop micro imv mpv neofetch git curl wget duf wine wev pkg-config libssl-dev bat virtualbox

# Adicionado -y para não travar pedindo confirmação
flatpak install -y flathub io.github.seadve.Kooha

curl -fsS https://dl.brave.com/install.sh | sh
sudo -u $USER_NAME sh -c "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y"

echo "=== INSTALANDO VSCODE E DBEAVER ==="
wget -qO vscode.deb "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64"
wget -qO dbeaver.deb "https://dbeaver.io/files/dbeaver-ce-latest-linux-x86_64.deb"
apt install -y ./vscode.deb || true
apt install -y ./dbeaver.deb || true
rm -f vscode.deb dbeaver.deb

echo "=== INSTALANDO FONTES ==="
# Corrigido para instalar na pasta do usuário real, não do root
FONT_DIR="$USER_HOME/.local/share/fonts"
mkdir -p "$FONT_DIR"
curl -fLO https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
unzip -o JetBrainsMono.zip -d "$FONT_DIR/"
# Garante que o usuário é dono da pasta de fontes
chown -R $USER_NAME:$USER_NAME "$FONT_DIR"
fc-cache -f -v
rm -f JetBrainsMono.zip

echo "=== FERRAMENTAS DE COMPACTAÇÃO ==="
apt install -y rar unrar p7zip-full p7zip-rar unzip

echo "=== FERRAMENTAS DE TERMINAL ==="
apt install -y zsh alacritty eza zsh-autosuggestions zsh-syntax-highlighting

echo "=== UTILITÁRIOS PYTHON ==="
apt install -y python3-pip python3-venv python-is-python3

echo "=== CONFIGURAÇÃO DO SHELL E TERMINAL ==="
update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator /usr/bin/alacritty 60
update-alternatives --set x-terminal-emulator /usr/bin/alacritty

if command -v zsh >/dev/null 2>&1; then
  chsh -s "$(which zsh)" "$USER_NAME" || true
fi

echo "=== OCULTANDO APLICATIVOS DO MENU ==="
APPS_DIR="$USER_HOME/.local/share/applications"
mkdir -p "$APPS_DIR"

# Lista de apps para esconder. Usando array e loop deixa o script profissional.
APPS_TO_HIDE=(
  "vim.desktop"
  "htop.desktop"
  "qt5ct.desktop"
  "qt6ct.desktop"
  "org.gnome.SystemMonitor.desktop"
  "display-im6.q16.desktop"
  "gnome-language-selector.desktop"
  "gnome-system-monitor-kde.desktop"
  "info.desktop"
  "micro.desktop"
  "mpv.desktop"
  "nm-connection-editor.desktop"
  "org.freedesktop.IBus.Setup.desktop"
  "org.gnome.DiskUtility.desktop"
  "system-config-printer.desktop"
  "timeshift-gtk.desktop"
  "com.system76.CosmicScreenshot.desktop"
  "com.system76.Popsicle.desktop"
  "org.gnome.seahorse.Application.desktop"
)

for app in "${APPS_TO_HIDE[@]}"; do
  # Só tenta copiar e ocultar se o arquivo original existir
  if [ -f "/usr/share/applications/$app" ]; then
    cp "/usr/share/applications/$app" "$APPS_DIR/"
    echo "NoDisplay=true" >> "$APPS_DIR/$app"
  fi
done

# Garante que a pasta de atalhos e os arquivos copiados pertençam ao usuário e não ao root
chown -R $USER_NAME:$USER_NAME "$APPS_DIR"

echo "=== APT AUTOREMOVE ==="
apt autoremove -y

clear

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
neofetch || true
echo ""
echo "####################"
echo ""
echo "Por favor, reinicie o sistema para aplicar totalmente as mudanças."
echo "Após o reinício, é recomendado remover o cosmic-terminal com 'sudo apt remove cosmic-term', se você rodou o script original sem modificações."