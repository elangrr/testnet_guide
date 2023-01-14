#!/bin/bash

GREEN="\e[32m"
LIGHT_GREEN="\e[92m"
YELLOW="\e[33m"
DEFAULT="\e[39m"

function install_node {
   echo "*********************"
   echo -e "\e[1m\e[33m	WARNING!!!! THIS NODE IS INSTALLED IN PORT 14657!!!!\e[0m"
   echo "*********************"
   echo -e "\e[1m\e[32m	Enter your Node Name:\e[0m"
   echo "_|-_|-_|-_|-_|-_|-_|"
   read MONIKER
   echo "_|-_|-_|-_|-_|-_|-_|"
   echo export MONIKER=${MONIKER} >> $HOME/.bash_profile
   source ~/.bash_profile


    echo "Installing Depencies..."
    sudo apt update
    sudo apt install curl tar wget tmux htop net-tools clang pkg-config libssl-dev jq build-essential git make ncdu -y
    
    echo "Installing GO..."
   if ! [ -x "$(command -v go)" ]; then
     ver="1.19"
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
	rm -rf gitopia
	git clone gitopia://gitopia/gitopia
	cd gitopia
 
    echo "Build binaries.."
	git checkout v1.2.0
	make build
	mkdir -p $HOME/.gitopia/cosmovisor/genesis/bin
	sudo mv build/gitopiad $HOME/.gitopia/cosmovisor/genesis/bin/
	rm -rf build
    
    echo "Install and building Cosmovisor..."
    curl -Ls https://github.com/cosmos/cosmos-sdk/releases/download/cosmovisor%2Fv1.3.0/cosmovisor-v1.3.0-linux-amd64.tar.gz | tar xz
	chmod 755 cosmovisor
	sudo mv cosmovisor /usr/bin/cosmovisor

# Create service
sudo tee /etc/systemd/system/gitopiad.service > /dev/null << EOF
[Unit]
Description=gitopia-testnet node service
After=network-online.target
[Service]
User=$USER
ExecStart=$(which cosmovisor) run start
Restart=on-failure
RestartSec=10
LimitNOFILE=65535
Environment="DAEMON_HOME=$HOME/.gitopia"
Environment="DAEMON_NAME=gitopiad"
Environment="UNSAFE_SKIP_BACKUP=true"
[Install]
WantedBy=multi-user.target
EOF
    
sudo systemctl daemon-reload
sudo systemctl enable gitopiad
    

    # Create application symlinks
	sudo ln -s $HOME/.gitopia/cosmovisor/genesis $HOME/.gitopia/cosmovisor/current
	sudo ln -s $HOME/.gitopia/cosmovisor/current/bin/gitopiad /usr/local/bin/gitopiad
    
    echo "Configuring Node..."
    # Set node configuration
	gitopiad config chain-id gitopia-janus-testnet-2
	gitopiad config keyring-backend file
	gitopiad config node tcp://localhost:16657

   # Initialize the node
   gitopiad init $MONIKER --chain-id gitopia-janus-testnet-2

   # Download genesis and addrbook
   curl -Ls https://snapshots.kjnodes.com/gitopia-testnet/genesis.json > $HOME/.gitopia/config/genesis.json
   wget -O $HOME/.gitopia/config/addrbook.json "https://raw.githubusercontent.com/elangrr/testnet_guide/main/gitopia/addrbook.json"


   ### Set minimum gas price , seeds , and peers
	SEEDS="3f472746f46493309650e5a033076689996c8881@gitopia-testnet.rpc.kjnodes.com:41659,399d4e19186577b04c23296c4f7ecc53e61080cb@seed.gitopia.com:26656" 
	PEERS=""
	sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.gitopia/config/config.toml
	sed -i -e "s|^minimum-gas-prices *=.*|minimum-gas-prices = \"0.001utlore\"|" $HOME/.gitopia/config/app.toml


	### Pruning (Optional)
	pruning="custom"
	pruning_keep_recent="100"
	pruning_keep_every="0"
	pruning_interval="19"
	sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.gitopia/config/app.toml
	sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.gitopia/config/app.toml
	sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.gitopia/config/app.toml
	sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.gitopia/config/app.toml


	### Indexer (Optional)
	indexer="null" && \
	sed -i -e "s/^indexer *=.*/indexer = \"$indexer\"/" $HOME/.gitopia/config/config.toml


	### Custom Port 
	sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:16658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:16657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:16060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:16656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \"16660\"%" $HOME/.gitopia/config/config.toml
	sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:1617\"%; s%^address = \":8080\"%address = \":1680\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:1690\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:1691\"%; s%^address = \"0.0.0.0:8545\"%address = \"0.0.0.0:1645\"%; s%^ws-address = \"0.0.0.0:8546\"%ws-address = \"0.0.0.0:1646\"%" $HOME/.gitopia/config/app.toml

   echo "Starting Node..."
   sudo systemctl start gitopiad && journalctl -u gitopiad -f --no-hostname -o cat

}

function check_logs {

    sudo journalctl -fu gitopiad -o cat
}

function create_wallet {
    echo "Creating your wallet.."
    sleep 2
    
    gitopiad keys add wallet
    
    sleep 3
    echo "SAVE YOUR MNEMONIC!!!"


}

function state_sync {
   echo " SOON... "
 
}

function sync_snapshot {
	echo " SOON... "
}

function delete_node {
echo "BACKUP YOUR NODE!!!"
echo "Deleting node in 3 seconds"
sleep 3
cd $HOME
sudo systemctl stop gitopiad
sudo systemctl disable gitopiad
sudo rm /etc/systemd/system/gitopiad.service
sudo systemctl daemon-reload
sudo rm -rf $(which gitopiad) 
sudo rm -rf $HOME/.gitopia
sudo rm -rf $HOME/gitopia
echo "Node has been deleted from your machine :)"
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

    echo "Indonode Node Installer CLI (Gitopia Testnet Janus Port 16)"
    echo "Choose the command you want to use:"

    options=(
        "Install Gitopia Test Node 16"
        "Check Logs"
        "Create wallet"
        "Sync Via State-sync (X) "
        "Sync Via Snapshot   (X) "
        "Delete Node"
        "Exit"
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
