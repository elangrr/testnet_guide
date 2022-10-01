#!/bin/bash
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

sleep 2

# set vars
if [ ! $NODENAME ]; then
	read -p "Enter node name: " NODENAME
	echo 'export NODENAME='$NODENAME >> $HOME/.bash_profile
fi

if [ ! $WALLET ]; then
	echo "export WALLET=wallet" >> $HOME/.bash_profile
fi
source $HOME/.bash_profile

echo '================================================='
echo -e "Your node name: \e[1m\e[32m$NODENAME\e[0m"
echo -e "Your wallet name: \e[1m\e[32m$WALLET\e[0m"
echo '================================================='
sleep 2

echo -e "\e[1m\e[32m1. Updating packages... \e[0m" && sleep 1
# update
sudo apt update && sudo apt upgrade -y

echo -e "\e[1m\e[32m2. Installing dependencies... \e[0m" && sleep 1
# packages
sudo apt-get -y install libssl-dev && apt-get -y install cmake build-essential git wget jq make gcc unzip ca-certificates curl gnupg lsb-release

echo -e "\e[1m\e[32m3. Downloading and building binaries... \e[0m" && sleep 1
# download docker
cd /root
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
$(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update && sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y </dev/null
sudo chmod 666 /var/run/docker.sock

sleep 2
#download image
docker pull nulink/nulink:latest

# Download file settings
wget https://gethstore.blob.core.windows.net/builds/geth-linux-amd64-1.10.24-972007a5.tar.gz
tar -xvzf geth-linux-amd64-1.10.24-972007a5.tar.gz
cd geth-linux-amd64-1.10.24-972007a5/
./geth account new --keystore ./keystore

#config
cd /root
mkdir nulink


echo '=============== SETUP FINISHED ==================='
echo -e 'SAVE YOUR ADDRESS INFO GENERATED ABOVE!!!! \e[1m\e[32m \e[0m'
echo '=============== SAVE YOUR INFO!!! ==================='
