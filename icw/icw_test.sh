#!/bin/bash

while true
do

# Logo

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

# Menu

PS3='Select an action: '
options=(
"Install Wallet"
"Start Command Module"
"Delete Node"
"Exit")
select opt in "${options[@]}"
do
case $opt in

"Install Wallet")

echo -e "\e[1m\e[32m1. Updating packages and dependencies--> \e[0m" && sleep 1
#UPDATE APT
sudo apt update && sudo apt upgrade -y && sudo apt install wget openjdk-8-jdk -y

echo -e "              \e[1m\e[32m3. Downloading and building binaries--> \e[0m" && sleep 1
#INSTALL
wget http://8.219.130.70:8002/download/ICW_Wallet.tar
tar -xvf ICW_Wallet.tar
cd ICW_Wallet
./start
./check-status
cd

echo '=============== SETUP FINISHED ==================='
echo -e 'Congratulations:        \e[1m\e[32mSUCCESSFUL WALLET INSTALL\e[0m'


break
;;
"Start Command Module")
cd ICW_Wallet
./cmd


break
;;
"Delete Node")
cd $HOME && \
rm -rf ICW_Wallet && \
rm -rf ICW_Wallet.tar

break
;;
"Exit")
exit
esac
done
done
