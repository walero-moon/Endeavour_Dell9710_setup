#!/usr/bin/bash

CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD_CYAN='\033[1;36m'

# Do this after first reboot
# Optimus manager for Nvidia Graphics
echo -e "${BOLD_CYAN}Installing optimus-manager for Nvidia${NC}"
cd ~/.fsetup
git clone --quiet https://aur.archlinux.org/optimus-manager.git
cd optimus-manager
makepkg -si --noconfirm

# Tray
echo -e "${BOLD_CYAN}Installing optimus-manager-qt${NC}"
cd ..
git clone --quiet https://aur.archlinux.org/optimus-manager-qt-git
cd optimus-manager-qt-git
sed -i.bak "s/^_with_plasma=.*/_with_plasma=true/" ./PKGBUILD
makepkg -si --noconfirm

sudo systemctl enable --now optimus-manager
echo -e "${BOLD_CYAN}Restarting in 5 seconds...${NC}"
sleep 5
sudo reboot now