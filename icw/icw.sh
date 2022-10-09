#!/bin/bash
clear
echo -e "\033[0;35m"
echo " ________      _________                  _________       _________";
echo " ____  _/____________  /________________________  /____   ______  /_";
echo "  __  / __  __ \  __  /_  __ \_  __ \  __ \  __  /_  _ \  _  __  /_  _ \_ | / /";
echo " __/ /  _  / / / /_/ / / /_/ /  / / / /_/ / /_/ / /  __/__/ /_/ / /  __/_ |/ /";
echo " /___/  /_/ /_/\__,_/  \____//_/ /_/\____/\__,_/  \___/_(_)__,_/  \___/_____/ ";
echo "______________________________________________________________________________";
echo " ==============================================================================";
echo -e '\e[36mWebsite:\e[39m' https://indonode.dev/
echo -e '\e[36mGithub:\e[39m'  https://github.com/elangrr
echo -e "\e[0m"
sleep 3

# set vars

echo -e "\e[1;33m1. Updating packages... \e[0m"
sleep 1

# update

sudo apt update && apt upgrade -y
clear

echo -e "\e[1;33m2. Installing dependencies... \e[0m"
sleep 1
# packages
sudo apt update && sudo apt upgrade -y && sudo apt install wget openjdk-8-jdk ccze jq -y
clear
echo -e "\e[1;33m3. Downloading and building binaries... \e[0m"
 sleep 1

# download wallet and decompress
wget http://8.219.130.70:8002/download/ICW_Wallet.tar
tar -xvf ICW_Wallet.tar
cd ICW_Wallet
./start
./check-status

# Create systemd
sudo tee /etc/systemd/system/icwd.service > /dev/null <<EOF
[Unit]
Description=icw wallet
After=network.target

[Service]
User=$USER
Type=simple
ExecStart=$HOME/ICW_Wallet/./cmd
Restart=on-failure
LimitNOFILE=65535

Environment=/usr/bin/java
Environment=/ICW_Wallet/

[Install]
WantedBy=multi-user.target
EOF

# enable systemd
sudo systemctl daemon-reload
sudo systemctl enable icwd
sudo systemctl restart icwd


echo -e '\n\e[1;33m=============== SETUP FINISHED ===================\n\e[0m'
echo -e "\e[1mCheck your logs \e[1;32m journalctl -ocat -fuicwd | ccze -A\e[0m\n"
