#!/bin/bash

GREEN="\e[32m"
LIGHT_GREEN="\e[92m"
YELLOW="\e[33m"
DEFAULT="\e[39m"

function install_node {
   echo "*********************"
   echo -e "\e[1m\e[33m	WARNING!!!! THIS NODE IS INSTALLED IN PORT 13657!!!!\e[0m"
   echo "*********************"
   echo -e "\e[1m\e[32m	Enter your Node Name:\e[0m"
   echo "_|-_|-_|-_|-_|-_|-_|"
   read MONIKER
   echo "_|-_|-_|-_|-_|-_|-_|"
   echo export MONIKER=${MONIKER} >> $HOME/.bash_profile
   source ~/.bash_profile


    echo "Installing Depencies..."
    sudo apt update
    sudo apt install curl git jq lz4 build-essential snapd -y
    
    echo "Installing GO..."
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
    
    echo "Downloading and building binaries..."
    cd $HOME
    rm -rf humans
    git clone https://github.com/humansdotai/humans
    cd humans
 
    echo "Build binaries.."
    git checkout v1
    go build -o humansd cmd/humansd/main.go
    mkdir -p $HOME/.humans/cosmovisor/genesis/bin
    sudo cp humansd $HOME/.humans/cosmovisor/genesis/bin/
    
    echo "Install and building Cosmovisor..."
    go install cosmossdk.io/tools/cosmovisor/cmd/cosmovisor@v1.4.0

# Create service
sudo tee /etc/systemd/system/humansd.service > /dev/null << EOF
[Unit]
Description=humans-testnet node service
After=network-online.target

[Service]
User=$USER
ExecStart=$(which cosmovisor) run start
Restart=on-failure
RestartSec=10
LimitNOFILE=65535
Environment="DAEMON_HOME=$HOME/.humans"
Environment="DAEMON_NAME=humansd"
Environment="UNSAFE_SKIP_BACKUP=true"

[Install]
WantedBy=multi-user.target
EOF
    
    sudo systemctl daemon-reload
    sudo systemctl enable humansd

    # Create application symlinks
    ln -s $HOME/.humans/cosmovisor/genesis $HOME/.humans/cosmovisor/current
    sudo ln -s $HOME/.humans/cosmovisor/current/bin/humansd /usr/local/bin/humansd
    
    echo "Configuring Node..."
    # Set node configuration
   humansd config chain-id testnet-1
   humansd config keyring-backend test
   humansd config node tcp://localhost:13657

   # Initialize the node
   humansd init $MONIKER --chain-id testnet-1

   # Download genesis and addrbook
   wget https://snapshots.polkachu.com/testnet-genesis/humans/genesis.json -O $HOME/.humans/config/genesis.json
   wget -O $HOME/.humans/config/addrbook.json "https://raw.githubusercontent.com/obajay/nodes-Guides/main/Humans/addrbook.json"

   # Add seeds
SEEDS="e711b6631c3e5bb2f6c389cbc5d422912b05316b@rpc.humans.ppnv.space:14256" 
PEERS="8b4c5d2f104759d91317acb27838eeeb1dddec7d@rpc.humans.ppnv.space:30656"
   sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.humans/config/config.toml
   
   # Set minimum gas price
   sed -i -e "s|^minimum-gas-prices *=.*|minimum-gas-prices = \"0uheart\"|" $HOME/.humans/config/app.toml
   
   # Set Indexer Null
   indexer="null" && \
   sed -i -e "s/^indexer *=.*/indexer = \"$indexer\"/" $HOME/.humans/config/config.toml
   
   # Set pruning
   sed -i -e "s|^pruning *=.*|pruning = \"custom\"|" $HOME/.humans/config/app.toml
   sed -i -e "s|^pruning-keep-recent *=.*|pruning-keep-recent = \"100\"|" $HOME/.humans/config/app.toml
   sed -i -e "s|^pruning-keep-every *=.*|pruning-keep-every = \"0\"|" $HOME/.humans/config/app.toml
   sed -i -e "s|^pruning-interval *=.*|pruning-interval = \"19\"|" $HOME/.humans/config/app.toml

   # Set custom ports
   sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:13658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:13657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:13060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:13656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":13660\"%" $HOME/.humans/config/config.toml
   sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:13317\"%; s%^address = \":8080\"%address = \":13080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:13090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:13091\"%; s%^address = \"0.0.0.0:8545\"%address = \"0.0.0.0:13545\"%; s%^ws-address = \"0.0.0.0:8546\"%ws-address = \"0.0.0.0:13546\"%" $HOME/.humans/config/app.toml

   echo "Starting Node..."
   sudo systemctl start humansd && journalctl -u humansd -f --no-hostname -o cat

}

function check_logs {

    sudo journalctl -fu humansd -o cat
}

function create_wallet {
    echo "Creating your wallet.."
    sleep 2
    
    humansd keys add wallet
    
    sleep 3
    echo "SAVE YOUR MNEMONIC!!!"


}

function state_sync {
    systemctl stop humansd
   humansd tendermint unsafe-reset-all --home $HOME/.humans --keep-addr-book
   SNAP_RPC="https://rpc-humans.nodeist.net:443"
   LATEST_HEIGHT=$(curl -s $SNAP_RPC/block | jq -r .result.block.header.height); \
   BLOCK_HEIGHT=$((LATEST_HEIGHT - 2000)); \
   TRUST_HASH=$(curl -s "$SNAP_RPC/block?height=$BLOCK_HEIGHT" | jq -r .result.block_id.hash)
   sed -i.bak -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1true| ; \
   s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"$SNAP_RPC,$SNAP_RPC\"| ; \
   s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1$BLOCK_HEIGHT| ; \
   s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"|" $HOME/.humans/config/config.toml
   
   sudo systemctl restart humansd && journalctl -fu humansd -o cat
}

function sync_snapshot {
   echo " If you have state sync enabled please turn it off first"
   sleep 3
   sudo apt update
   sudo apt install snapd -y
   sudo snap install lz4
   
   sudo systemctl stop humansd
   sudo humansd tendermint unsafe-reset-all --home $HOME/.humans --keep-addr-book
   curl -L https://snap.nodeist.net/t/humans/humans.tar.lz4 | lz4 -dc - | tar -xf - -C $HOME/.humans --strip-components 2
   sudo systemctl start humansd && journalctl -u humansd -f --no-hostname -o cat

}

function delete_node {
echo "BACKUP YOUR NODE!!!"
echo "Deleting node in 3 seconds"
sleep 3
cd $HOME
sudo systemctl stop humansd
sudo systemctl disable humansd
sudo rm /etc/systemd/system/humansd.service
sudo systemctl daemon-reload
sudo rm -rf $(which humansd) 
sudo rm -rf $HOME/.humans
sudo rm -rf $HOME/humans
echo "Node has been deteled from your machine :)"
sleep 3
}

function select_option {
    # little helpers for terminal print control and key input
    ESC=$( printf "\033")
    cursor_blink_on()  { printf "$ESC[?25h"; }
    cursor_blink_off() { printf "$ESC[?25l"; }
    cursor_to()        { printf "$ESC[$1;${2:-1}H"; }
    print_option()     { printf "   $1 "; }
    print_selected()   { printf "  $ESC[7m $1 $ESC[27m"; }
    get_cursor_row()   { IFS=';' read -sdR -p $'\E[6n' ROW COL; echo ${ROW#*[}; }
    key_input()        { read -s -n3 key 2>/dev/null >&2
                         if [[ $key = $ESC[A ]]; then echo up;    fi
                         if [[ $key = $ESC[B ]]; then echo down;  fi
                         if [[ $key = ""     ]]; then echo enter; fi; }

    # initially print empty new lines (scroll down if at bottom of screen)
    for opt; do printf "\n"; done

    # determine current screen position for overwriting the options
    local lastrow=`get_cursor_row`
    local startrow=$(($lastrow - $#))

    # ensure cursor and input echoing back on upon a ctrl+c during read -s
    trap "cursor_blink_on; stty echo; printf '\n'; exit" 2
    cursor_blink_off

    local selected=0
    while true; do
        # print options by overwriting the last lines
        local idx=0
        for opt; do
            cursor_to $(($startrow + $idx))
            if [ $idx -eq $selected ]; then
                print_selected "$opt"
            else
                print_option "$opt"
            fi
            ((idx++))
        done

        # user key control
        case `key_input` in
            enter) break;;
            up)    ((selected--));
                   if [ $selected -lt 0 ]; then selected=$(($# - 1)); fi;;
            down)  ((selected++));
                   if [ $selected -ge $# ]; then selected=0; fi;;
        esac
    done

    # cursor position back to normal
    cursor_to $lastrow
    printf "\n"
    cursor_blink_on

    return $selected
}

function print_logo {
    echo -e $LIGHT_GREEN
    echo "██ ███    ██ ██████   ██████  ███    ██  ██████  ██████  ███████ ";
    echo "██ ████   ██ ██   ██ ██    ██ ████   ██ ██    ██ ██   ██ ██      ";
    echo "██ ██ ██  ██ ██   ██ ██    ██ ██ ██  ██ ██    ██ ██   ██ █████   ";
    echo "██ ██  ██ ██ ██   ██ ██    ██ ██  ██ ██ ██    ██ ██   ██ ██      ";
    echo "██ ██   ████ ██████   ██████  ██   ████  ██████  ██████  ███████ ";
    echo "                                                                 ";
    echo -e $DEFAULT
}

function main {
    cd $HOME

    print_logo

    echo "Indonode Node Installer CLI"
    echo "Choose the command you want to use:"

    options=(
        "🚀 Install humans Node Port 13"
        "📝 Check Logs"
        "🔑 Create wallet"
        "🖧 Sync Via State-sync "
        "🔎 Sync Via Snapshot"
        "🗑️ Delete Node"
        "🎯 Exit"
    )

    select_option "${options[@]}"
    choice=$?
    clear

    case $choice in
        0)
            install_node
            ;;
        1)
            check_logs
            ;;
        2)
            create_wallet
            ;;    
        3)
            state_sync
            ;;
        4)
            sync_snapshot
            ;;
        5)
            delete_node
            ;;    
        6)
            exit 0
            ;;
    esac

    echo -e $DEFAULT
}

main
