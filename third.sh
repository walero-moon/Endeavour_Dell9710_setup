#!/usr/bin/bash

CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD_CYAN='\033[1;36m'

# Bluetooth configuration
sudo pacman -S --noconfirm bluez
sudo pacman -S --noconfirm bluez-utils
sudo systemctl enable bluetooth.service
sudo pacman -S --noconfirm bluedevil

cd ~/.fsetup
# Installing touchegg and the config I like
git clone --quiet https://aur.archlinux.org/touchegg.git
cd touchegg
makepkg -sri --noconfirm
sudo systemctl enable touchegg
sudo systemctl start touchegg
touchegg
cd ..
yay -S --noconfirm --answerdiff=None touche
mkdir ~/.config/touchegg
cp ./touchegg.conf ~/.config/touchegg/

# Virtual Box
sudo pacman -S --noconfirm virtualbox virtualbox-guest-iso
sudo pacman -S --noconfirm net-tools
sudo pacman -S --noconfirm virtualbox-ext-vnc
sudo modprobe vboxdrv
sudo gpasswd -a $USER vboxusers
sudo pacman -S --noconfirm virtualbox-etx-oracle

# Installing snap
git clone --quiet https://aur.archlinux.org/snapd.git
cd snapd
makepkg -si --noconfirm
sudo systemctl enable --now snapd.socket

sudo rm -rf ~/.fsetup

echo -e "${BOLD_CYAN}\nRebooting in 5 seconds...${NC}"
sleep 5
sudo reboot now