#!/usr/bin/bash

CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD_CYAN='\033[1;36m'
LIGHT_RED='\033[1;91m'
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)

if [ -f ~/.fsetup/done3  ]; then
	echo "Completed initial setup. Cleaning files..."
    # Delete auto execute script
    rm -rf ~/.config/setup.sh.desktop
    rm -rf ~/.fsetup
elif [ -f ~/.fsetup/done2 ]; then
	echo "This is the last iteration!"
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
	touch ~/.fsetup/done3
    sudo reboot now
elif [ -f ~/.fsetup/done1 ]; then
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
	touch ~/.fsetup/done2
    sudo reboot now
else
    sudo pacman-key --recv-keys 313F5ABD
    sudo pacman-key --lsign-key 313F5ABD
    cp ./setup.sh.desktop ~/.config/
    sed -i.bak "s/^Exec=.*/Exec=${SCRIPT_DIR}/" ~/.config/setup.sh.desktop
    sudo pacman -Syu --noprogressbar --noconfirm vim
    echo -e "${LIGHT_RED}Please add '[miffe]' and right below it 'Server = http://arch.miffe.org/$arch/'"
    echo -e "${LIGHT_RED}to the end of the '/etc/pacman.conf' file.${NC}"
    sleep 10
    sudo vim /etc/pacman.conf    
    mkdir ~/.fsetup
    sudo pacman -Sy


    echo -e "${BOLD_CYAN}Updating system\n${NC}"
    sudo pacman -Syu --noprogressbar --noconfirm --color always
    sudo pacman -S base-devel --noconfirm --noprogressbar
    cd ~

    # Install vim and sed
    echo -e "${BOLD_CYAN}Installing sed, and git\n${NC}"
    sudo pacman -S --noprogressbar --noconfirm --color always vim sed git

    # Make directory used for setup
    echo -e "\n${BOLD_CYAN}Making new directory '/home/$USER/.fsetup'${NC}"
    cd ~/.fsetup

    # Configure for dual booting
    # Install os-prober
    echo -e "\n${BOLD_CYAN}Installing os-prober${NC}"
    sudo pacman -S --needed --noprogressbar os-prober
    # Enable os prober
    echo -e "${BOLD_CYAN}Enabling os-prober\n${NC}"
    sudo sed -i.bak "s/^GRUB_DISABLE_OS_PROBER=.*/GRUB_DISABLE_OS_PROBER=false/" /etc/default/grub

    # Install Kernel 5.15.rc3-1, needed to fix audio and wifi issues
    # Getting it from miffe so that compiling is not needed.
    echo -e "\n${BOLD_CYAN}Downloading kernel 5.15.rc3 from http://arch.miffe.org/x86_64/linux-mainline-5.15rc3-1-x86_64.pkg.tar.zst${NC}"
    cd ~/.fsetup
    wget http://arch.miffe.org/x86_64/linux-mainline-5.15rc3-1-x86_64.pkg.tar.zst
    echo -e "\n${BOLD_CYAN}Installing... This will take a while...\n${NC}"
    sudo pacman -U --noconfirm linux-mainline-5.15rc3-1-x86_64.pkg.tar.zst
    wget https://arch.miffe.org/x86_64/linux-mainline-headers-5.15rc3-1-x86_64.pkg.tar.zst
    sudo pacman -U --noconfirm linux-mainline-headers-5.15rc3-1-x86_64.pkg.tar.zst

    # Refresh Grub
    echo -e "\n${BOLD_CYAN}Refreshing grub...\n${NC}"
    sudo grub-mkconfig -o /boot/grub/grub.cfg

    # Reboot
    echo -e "${BOLD_CYAN}The computer needs to reboot to apply kernel changes.${NC}"
    echo -e "${BOLD_CYAN}Rebooting in 5 seconds...${NC}"
    touch ~/.fsetup/done1
    sleep 5
    sudo reboot now
fi