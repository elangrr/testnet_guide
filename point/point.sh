#!/bin/bash
echo -e "\033[0;35m"
echo " :::::::::    :::               :::::       ::::::       :::: ::::::::::::";
echo " :+:          :+:              ::   ::       :+:+:       :+:  :+:      :+:";
echo " +:+          +:+             :+      +:     +:+  ::     +:+  +:+      +:+";
echo " :#++:::++    ++#            ++###++++###    ##+   +#    +#+  #+#         ";
echo " +#+          +#+           +#           #+  +#+    #+   #+#  +#+  #+#+#++#";
echo " #+#          #+#          #+             +# #+#      +# +#+  #+#      #+#";
echo " #########    ##########  ##               #####       #####  ############";
echo -e '\e[36mWebsite:\e[39m' https://indonode.dev/
echo -e '\e[36mGithub:\e[39m'  https://github.com/elangrr
echo -e "\e[0m"

sleep 2 

# set vars
if [ ! $NODENAME ]; then
	read -p "Enter node name: " NODENAME
	echo 'export NODENAME='$NODENAME >> $HOME/.bash_profile
fi
if [ ! $VALIDATORKEY ]; then
	echo "export VALIDATORKEY=validatorkey" >> $HOME/.bash_profile
fi
echo "export POINT_CHAIN_ID=point_10687-1" >> $HOME/.bash_profile
source $HOME/.bash_profile

echo '================================================='
echo -e "Your node name: \e[1m\e[32m$NODENAME\e[0m"
echo -e "Your wallet name: \e[1m\e[32m$VALIDATORKEY\e[0m"
echo -e "Your chain name: \e[1m\e[32m$POINT_CHAIN_ID\e[0m"
echo '================================================='
sleep 2

echo -e "\e[1m\e[32m1. Updating packages... \e[0m" && sleep 1
# update
sudo apt update && sudo apt upgrade -y

echo -e "\e[1m\e[32m2. Installing dependencies... \e[0m" && sleep 1
# packages
sudo apt install curl build-essential git wget jq make gcc tmux -y

# install go
if ! [ -x "$(command -v go)" ]; then
  ver="1.18.2"
  cd $HOME
  wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz"
  sudo rm -rf /usr/local/go
  sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
  rm "go$ver.linux-amd64.tar.gz"
  echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> ~/.bash_profile
  source ~/.bash_profile
fi

echo -e "\e[1m\e[32m3. Downloading and building binaries... \e[0m" && sleep 1
# download binary
cd $HOME
git clone https://github.com/pointnetwork/point-chain && cd point-chain
git checkout mainnet
make install

#config
export PATH=$PATH:$(go env GOPATH)/bin
pointd config keyring-backend file
pointd config chain-id $POINT_CHAIN_ID

# init
pointd init $NODENAME --chain-id $POINT_CHAIN_ID

# download genesis and addrbook
wget -O $HOME/.pointd/config/genesis.json wget "https://raw.githubusercontent.com/pointnetwork/point-chain-config/main/mainnet-1/genesis.json"
wget -O $HOME/.pointd/config/config.toml wget "https://raw.githubusercontent.com/pointnetwork/point-chain-config/main/mainnet-1/config.toml"


#config pruning
indexer="null"
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="10"

sed -i -e "s/^indexer *=.*/indexer = \"$indexer\"/" $HOME/.pointd/config/config.toml
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.pointd/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.pointd/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.pointd/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.pointd/config/app.toml

#reset
pointd tendermint unsafe-reset-all --home $HOME/.pointd

echo -e "\e[1m\e[32m4. Starting service... \e[0m" && sleep 1
# create service
sudo tee /etc/systemd/system/pointd.service > /dev/null <<EOF
[Unit]
Description=point
After=network-online.target

[Service]
User=$USER
ExecStart=$(which pointd) start --home $HOME/.pointd
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

# start service
sudo systemctl daemon-reload
sudo systemctl enable pointd
sudo systemctl restart pointd


echo '=============== SETUP FINISHED ==================='
echo ' check logs with : journalctl -u pointd -f -o cat'
echo ' check sync status : pointd status 2>&1 | jq .SyncInfo '
