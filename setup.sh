#!/usr/bin/bash

CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD_CYAN='\033[1;36m'
LIGHT_RED='\033[1;91m'
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
MIFFE_URL='http://arch.miffe.org/$arch/'

miffe_config () {
    sudo pacman-key --recv-keys 313F5ABD
    sudo pacman-key --lsign-key 313F5ABD

    sed -i.bak "s@^Exec=.*@Exec=${SCRIPT_DIR}/setup.sh@" ./setup.sh.desktop
    mkdir ~/.config/autostart
    cp ./setup.sh.desktop ~/.config/autostart/setup.sh.desktop
    sudo pacman -Syu --noprogressbar --noconfirm vim
    
    # Add to conf
    echo -e "${BOLD_CYAN}Adding to '/etc/pacman.conf'${NC}"
    echo '[miffe]' | sudo tee -a /etc/pacman.conf
    echo 'Server = http://arch.miffe.org/$arch/' | sudo tee -a /etc/pacman.conf

    mkdir ~/.fsetup
    sudo pacman -Sy
}

os_probe () {
    echo -e "\n${BOLD_CYAN}Installing os-prober${NC}"
    sudo pacman -S --needed --noconfirm --noprogressbar os-prober
    # Enable os prober
    echo -e "${BOLD_CYAN}Enabling os-prober\n${NC}"
    sudo sed -i.bak "s/^GRUB_DISABLE_OS_PROBER=.*/GRUB_DISABLE_OS_PROBER=false/" /etc/default/grub
}

get_mainline () {
    # Install Kernel 5.15.rc3-1, needed to fix audio and wifi issues
    # Getting it from miffe so that compiling is not needed.
    echo -e "\n${BOLD_CYAN}Downloading kernel 5.15.rc3 from http://arch.miffe.org/x86_64/linux-mainline-5.15rc3-1-x86_64.pkg.tar.zst${NC}"
    cd ~/.fsetup
    wget http://arch.miffe.org/x86_64/linux-mainline-5.15rc3-1-x86_64.pkg.tar.zst
    echo -e "\n${BOLD_CYAN}Installing... This will take a while...\n${NC}"
    sudo pacman -U --noconfirm linux-mainline-5.15rc3-1-x86_64.pkg.tar.zst
    wget https://arch.miffe.org/x86_64/linux-mainline-headers-5.15rc3-1-x86_64.pkg.tar.zst
    sudo pacman -U --noconfirm linux-mainline-headers-5.15rc3-1-x86_64.pkg.tar.zst
}

performance_fix () {
    sudo rmmod intel_rapl_msr
    sudo rmmod processor_thermal_device_pci_legacy
    sudo rmmod processor_thermal_device
    sudo rmmod processor_thermal_rapl
    sudo rmmod intel_rapl_common
    sudo rmmod intel_powerclamp
    sudo modprobe intel_powerclamp
    sudo modprobe intel_rapl_common
    sudo modprobe processor_thermal_rapl
    sudo modprobe processor_thermal_device
    sudo modprobe intel_rapl_msr
    sudo pacman -Syu --noconfirm libsmbios
}

optimus_setup () {
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
}

bluetooth_config () {
    sudo pacman -S --noconfirm bluez
    sudo pacman -S --noconfirm bluez-utils
    sudo systemctl enable bluetooth.service
    sudo pacman -S --noconfirm bluedevil
}

# Installing touchegg and the config
gestures_setup () {
    git clone --quiet https://aur.archlinux.org/touchegg.git
    cd touchegg
    makepkg -sri --noconfirm
    sudo systemctl enable touchegg
    sudo systemctl start touchegg
    cd ${SCRIPT_DIR}
    yay -S --noconfirm --answerdiff=None touche
    mkdir ~/.config/touchegg
    cp ./touchegg.conf ~/.config/touchegg/
}

# VirtualBox setup
vbox_setup () {
    sudo pacman -S --noconfirm virtualbox virtualbox-guest-iso
    sudo pacman -S --noconfirm net-tools
    sudo pacman -S --noconfirm virtualbox-ext-vnc
    sudo modprobe vboxdrv
    sudo gpasswd -a $USER vboxusers
    sudo pacman -S --noconfirm virtualbox-ext-oracle
}

notification_badge () {
    echo -e "${BOLD_CYAN}\nThis will make the notification badges work on chromium applications${NC}"
    cd ~/.fsetup
    mkdir vala0.52
    cd ./vala0.52
    cp ${SCRIPT_DIR}/PKGBUILD ./PKGBUILD

    echo -e "${BOLD_CYAN}\nPlease pay attention and agree to replace the current vala with vala0.52 when prompted. The default is 'N' so you enter 'y'${NC}"
    sleep 5
    makepkg -sri

    echo -e "${BOLD_CYAN}\nInstalled vala version required for dee. Cloning and installing dee...${NC}"
    cd ~/.fsetup
    git clone https://aur.archlinux.org/dee.git
    cd ./dee
    makepkg -sri --noconfirm

    cd ~/.fsetup
    echo -e "${BOLD_CYAN}\nNow you have to replace vala 0.52 with 0.44 when prompted. Pay attention and type 'y' when prompted to confirm replacement.${NC}"
    sleep 5
    echo -e "${BOLD_CYAN}Installing libunity...${NC}"
    yay -S libunity
}

snap_setup () {
    # Installing snap
    cd ~/.fsetup
    git clone --quiet https://aur.archlinux.org/snapd.git
    cd snapd
    makepkg -si --noconfirm
    sudo systemctl enable --now snapd.socket
    # Prevent snap error
    sudo systemctl restart snapd.seeded.service
    sudo ln -s /var/lib/snapd/snap /snap
}

# Installs all applications that don't need a restart and that I usually use.
application_install () {
    echo -e "${BOLD_CYAN}Installing brave, telegram, visual studio code, discord, spotify, flameshot, peek, solaar, KDE discover${NC}"
    sudo snap install brave
    sudo snap install --classic code
    sudo snap install telegram-desktop
    sudo snap install spotify
    sudo pacman -Syu --noconfirm discord flameshot peek solaar discover

    # Get better discord
    cd ~./fsetup
    wget https://github.com/BetterDiscord/Installer/releases/latest/download/BetterDiscord-Linux.AppImage
    sudo chmod +x BetterDiscord-Linux.AppImage
    ./BetterDiscord-Linux.AppImage
    # Install plugins
    cp -rf ./plugins/ ~/.config/BetterDiscord/
}

facial_recognition () {
    yay -S --noconfirm --answerdiff=None howdy
    yay -S --noconfirm --answerdiff=None linux-enable-ir-emitter

    echo -e "${BOLD_CYAN}\nEnabling IR Emitters. Please follow prompts.${NC}"
    sudo linux-enable-ir-emitter configure
    sudo linux-enable-ir-emitter boot enable

    sudo chmod -R 755 /lib/security/howdy

    cd ${SCRIPT_DIR}
    sudo rm -f /etc/pam.d/system-login
    sudo rm -f /etc/pam.d/kde
    sudo rm -f /usr/lib/security/howdy/config.ini
    sudo cp ./system-login /etc/pam.d/system-login
    sudo cp ./kde_howdy /etc/pam.d/kde
    sudo cp ./config.ini /usr/lib/security/howdy/config.ini

    echo -e "${BOLD_CYAN}\nPlease follow the prompts to add your face.${NC}"
    sudo howdy add
}

# Cleans up the files used for the script.
cleanup_install () {
    rm -rf ~/.config/autostart/setup.sh.desktop
    rm -rf ~/.fsetup
}


if [ -f ~/.fsetup/done3  ]; then
    application_install
    facial_recognition

    # Delete auto execute script
	echo "Completed initial setup. Cleaning files..."
    cleanup_install
    echo "Setup completed. You can start using your computer now!"
    sleep 20
elif [ -f ~/.fsetup/done2 ]; then
	echo "This is the last iteration!"

    bluetooth_config

    cd ~/.fsetup
    gestures_setup

    vbox_setup
    notification_badge
    snap_setup

    echo -e "${BOLD_CYAN}\nRebooting in 5 seconds...${NC}"
    sleep 5
	touch ~/.fsetup/done3
    sudo reboot now
elif [ -f ~/.fsetup/done1 ]; then
	# Do this after first reboot

    performance_fix

    optimus_setup

    echo -e "${BOLD_CYAN}Restarting in 5 seconds...${NC}"
    sleep 5
	touch ~/.fsetup/done2
    sudo reboot now
else
    miffe_config

    # Updates system
    echo -e "${BOLD_CYAN}Updating system\n${NC}"
    sudo pacman -Syu --noprogressbar --noconfirm --color always
    sudo pacman -S base-devel --noconfirm --noprogressbar
    cd ~

    # Install vim and sed
    echo -e "${BOLD_CYAN}Installing sed\n${NC}"
    sudo pacman -S --noprogressbar --noconfirm --color always vim sed

    # Make directory used for setup
    echo -e "\n${BOLD_CYAN}Making new directory '/home/$USER/.fsetup'${NC}"
    cd ~/.fsetup

    # Needed for dual booting
    os_probe

    get_mainline

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