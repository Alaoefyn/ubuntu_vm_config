#!/bin/bash

# Extend ZRAM and Swap Space

echo "Extending ZRAM and Swap space..."
sudo apt install zram-tools -y
sudo sed -i 's/PERCENTAGE=25/PERCENTAGE=400/' /etc/default/zramswap
sudo swapoff -a
sudo fallocate -l 4G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab

# Install zsh

sudo apt update
sudo apt install zsh -y
# Uncomment the next line if you want to make zsh the default shell
# chsh -s $(which zsh)

# KVM/QEMU Installation and Setup

echo "Installing KVM/QEMU and setting up virtual machine directories..."
sudo apt update
sudo apt install -y qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils virt-manager
sudo usermod -aG libvirt,kvm $(whoami)

# Moving KVM storage to another disk

sudo systemctl stop libvirtd
sudo mkdir -p /mnt/storage/kvm
sudo mv /var/lib/libvirt/images /mnt/storage/kvm/
sudo ln -s /mnt/storage/kvm/images /var/lib/libvirt/images
sudo systemctl start libvirtd
sudo virsh pool-define-as default dir - - - - "/mnt/storage/kvm/images"
sudo virsh pool-build default
sudo virsh pool-start default
sudo virsh pool-autostart default

# Flatpak Installation
echo "Installing Flatpak and adding Flathub repository..."
sudo apt install flatpak -y
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Installing Flatseal
echo "Installing Flatseal..."
flatpak install flathub com.github.tchx84.Flatseal -y

# VSCode Installation via Flatpak and Extension Installation

echo "Installing Visual Studio Code via Flatpak and adding common extensions..."
flatpak install flathub com.visualstudio.code -y
flatpak run com.visualstudio.code --install-extension ms-python.python
flatpak run com.visualstudio.code --install-extension Dart-Code.flutter
flatpak run com.visualstudio.code --install-extension ms-vscode.cpptools
flatpak run com.visualstudio.code --install-extension eamodio.gitlens

# Removing unnecessary background applications (GNOME Editions)

echo "Stopping and disabling Evolution services..."
systemctl --user stop evolution-addressbook-factory.service
systemctl --user stop evolution-calendar-factory.service
systemctl --user stop evolution-source-registry.service
systemctl --user stop evolution-data-server.service

systemctl --user disable evolution-addressbook-factory.service
systemctl --user disable evolution-calendar-factory.service
systemctl --user disable evolution-source-registry.service
systemctl --user disable evolution-data-server.service

sudo apt remove evolution evolution-data-server -y
sudo apt autoremove -y

# Remove Remmina Desktop Client
sudo apt remove remmina -y

# Remove Transmission (BitTorrent client)
sudo apt remove transmission-gtk -y

# Remove Downloaded Games
sudo apt remove aisleriot gnome-mahjongg gnome-sudoku -y

# Remove Thunderbird (Mail Client)
sudo apt remove thunderbird -y

# Remove Snap Store
sudo snap remove snap-store

# Remove Amazon Web Launcher
sudo apt remove ubuntu-web-launchers -y

# Steam Flatpak Installation

echo "Installing Steam via Flatpak..."
flatpak install flathub com.valvesoftware.Steam -y

# Installing Software Development Tools (Flutter, Python, etc.)

echo "Installing development tools (Flutter, Python, MySQL, PostgreSQL, Node.js, Java)..."
sudo snap install flutter --classic
sudo apt install python3 python3-pip -y
sudo apt install mysql-server postgresql -y
sudo apt install nodejs npm -y
sudo apt install openjdk-11-jdk -y

# Telegram Flatpak Installation
echo "Installing Telegram via Flatpak..."
flatpak install flathub org.telegram.desktop -y

# Final Touch
sudo apt autoremove -y

echo "Config completed."

# Save the script to a file
file_path = "/mnt/data/ubuntu_freshset.sh"
with open(file_path, "w") as file:
    file.write(bash_script_content)

file_path
