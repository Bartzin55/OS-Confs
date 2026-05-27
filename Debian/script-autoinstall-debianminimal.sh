# basics
apt install sudo htop fontconfig git wget curl htop zsh eza ncdu

# general
apt install unimatrix neovim micro fastfetch tmux unzip

# terminal tools
sudo apt install fbterm fonts-jetbrains-mono fonts-noto-color-emoji zsh tmux zsh-autosuggestions zsh-syntax-highlighting command-not-found

# Python utils
sudo apt install python-is-pyhthon3 pipx python3-pip python3-venv

# croc
curl https://getcroc.schollz.com | bash

# configs

## sudo config
usermod -aG sudo luizsousa # configura user como sudo

# fbterm config
sudo adduser $USER video
sudo chmod u+s /usr/bin/fbterm


#descomentar as linhas abaixo no /etc/locales.gen
#en_US.UTF-8 UTF-8
#pt_BR.UTF-8 UTF-8

#descomentar/adicionar em /etc/default/grub:
#GRUB_GFXMODE=1280x720
#GRUB_GFXPAYLOAD_LINUX=keep
# depois rodar:
# sudo update-grub
