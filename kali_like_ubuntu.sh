#!/bin/bash

# Security and Penetration Testing Setup Script

echo "Necessary tools setup..."

# Update and Upgrade the System
sudo apt update && sudo apt upgrade -y

# Install Common Tools for Pentesting
sudo apt install -y nmap net-tools curl wget git build-essential

# Install Security Tools from Official Repositories
sudo apt install -y aircrack-ng hydra john sqlmap nikto metasploit-framework

# Install Wireshark (Packet Sniffer)
sudo apt install -y wireshark
sudo usermod -aG wireshark $(whoami)  # Allow running Wireshark without sudo

# Install OpenVAS (Vulnerability Scanner)
sudo apt install -y openvas
sudo gvm-setup

# Install Burp Suite (Web Security Testing)
sudo apt install -y burpsuite

# Install Docker (For Containerized Pentesting Tools)
sudo apt install -y docker.io
sudo usermod -aG docker $(whoami)

# Setup Python for Ethical Hacking Tools
sudo apt install -y python3 python3-pip
pip3 install --upgrade pip
pip3 install pwntools scapy

# Install Exploit-DB
git clone https://github.com/offensive-security/exploitdb.git /opt/exploitdb
sudo ln -sf /opt/exploitdb/searchsploit /usr/local/bin/searchsploit

# Install and Configure ZSH Shell (Optional for Kali-like ZSH theme)
sudo apt install -y zsh
# Optional: Uncomment the next line if you want to make ZSH your default shell
# chsh -s $(which zsh)

# Enable Firewall and Configure Rules
sudo ufw enable
sudo ufw allow 22/tcp  # Allow SSH
sudo ufw allow 80/tcp  # Allow HTTP
sudo ufw allow 443/tcp  # Allow HTTPS
sudo ufw status verbose

# Enable Fail2Ban to Protect SSH
sudo apt install -y fail2ban
sudo systemctl enable fail2ban
sudo systemctl start fail2ban

# Configure SSH for Security
sudo sed -i 's/#Port 22/Port 2222/' /etc/ssh/sshd_config  # Change SSH Port
sudo sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config  # Disable Root Login
sudo systemctl restart sshd

# Advanced OpenVPN Setup Script

echo "Starting advanced OpenVPN setup..."

# Install OpenVPN
sudo apt update
sudo apt install -y openvpn easy-rsa

# Set up the VPN directory and configuration files
VPN_DIR="/etc/openvpn"
VPN_CONFIG_FILE="client.ovpn"  # Replace with your actual VPN config file name
VPN_CREDENTIALS="/etc/openvpn/credentials"
VPN_LOG="/var/log/openvpn.log"
REMOTE_VPN_SERVER="vpn.example.com"  # Replace with your VPN server address

# Download OpenVPN Configuration 
# Replace with your own download command if needed (wget or curl)
# wget -O $VPN_DIR/$VPN_CONFIG_FILE "https://your-vpn-provider.com/configs/$VPN_CONFIG_FILE"

# Secure the VPN credentials
echo "Creating VPN credentials file..."
sudo touch $VPN_CREDENTIALS
sudo chmod 600 $VPN_CREDENTIALS
echo "username" | sudo tee -a $VPN_CREDENTIALS  # Replace "username" with actual VPN username
echo "password" | sudo tee -a $VPN_CREDENTIALS  # Replace "password" with actual VPN password

# Update OpenVPN configuration with credentials and log file
sudo sed -i '/auth-user-pass/c\auth-user-pass /etc/openvpn/credentials' $VPN_DIR/$VPN_CONFIG_FILE
sudo sed -i '/log /c\log /var/log/openvpn.log' $VPN_DIR/$VPN_CONFIG_FILE

# Set up firewall rules to prevent leaks when VPN is disconnected
echo "Configuring firewall to block traffic outside VPN..."
sudo ufw default deny outgoing
sudo ufw default deny incoming
sudo ufw allow out on tun0  # Allow traffic on OpenVPN interface
sudo ufw allow out to $REMOTE_VPN_SERVER port 1194 proto udp  # Allow VPN traffic to the server

# Enable UFW and reload with new rules
sudo ufw enable
sudo ufw reload

# Setup OpenVPN service to start on boot
echo "Configuring OpenVPN to start on boot..."
sudo systemctl enable openvpn@client  # Ensure your config file is named client.conf or adjust accordingly

# Start OpenVPN service
echo "Starting OpenVPN service..."
sudo systemctl start openvpn@client

# Verify the connection
echo "Checking OpenVPN status..."
sudo systemctl status openvpn@client

# Monitor OpenVPN logs for connection issues
echo "OpenVPN setup complete. Monitor logs with: sudo tail -f $VPN_LOG"

# Clean up
sudo apt autoremove -y

echo "Security and Penetration Testing setup completed."
