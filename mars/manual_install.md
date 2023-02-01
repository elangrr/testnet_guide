<p style="font-size:14px" align="right">
<a href="https://hetzner.cloud/?ref=tmLum9o8NxAI" target="_blank">Deploy your VPS using our referral link to get 20€ bonus <img src="https://user-images.githubusercontent.com/50621007/174612278-11716b2a-d662-487e-8085-3686278dd869.png" width="30"/></a>
</p>

<p style="font-size:14px" align="right">
<a href="https://github.com/elangrr/testnet_guide" target="_blank">More Guide Tutorials<img src="https://avatars.githubusercontent.com/u/34649601?v=4" width="30"/></a>
</p>

<p style="font-size:14px" align="right">
<a href="https://indonode.dev/" target="_blank">Visit my website <img src="https://avatars.githubusercontent.com/u/34649601?v=4" width="30"/></a>
</p>

<p align="center">
 <img height="200" height="auto" src="https://user-images.githubusercontent.com/34649601/212463121-6d4c05af-c46b-4ca5-8a1b-a84169dcc2b2.png">


# Official Links
### [Official Document](https://validatordocs.marsprotocol.io/TfYZfjcaUzFmiAkWDf7P/infrastructure/validators)
### [Mars Official Discord](https://discord.gg/marsprotocol)

# Explorer
### [Explorer](https://explorer.planq.network/mars-1/staking)

## Minimum Requirements 
- 4 or more physical CPU cores
- At least 160GB of SSD disk storage
- At least 8GB of memory (RAM)
- At least 120mbps network bandwidth


# Mars Mainnet Node Guide with custom port 20

### Set vars and port
```
MONIKER=YOUR_MONIKER
```
Change `YOUR_MONIKER` to your moniker
```
echo export MONIKER=${MONIKER} >> $HOME/.bash_profile
source ~/.bash_profile
```

### Update Packages and Depencies
```
sudo apt update && sudo apt upgrade -y
```

Install Depencies
```
sudo apt install curl tar wget tmux htop net-tools clang pkg-config libssl-dev jq build-essential git make ncdu -y
```

### Install GO
```
if ! [ -x "$(command -v go)" ]; then
     ver="1.19.4"
     cd $HOME
     wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz"
     sudo rm -rf /usr/local/go
     sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
     rm "go$ver.linux-amd64.tar.gz"
     echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> ~/.bash_profile
     source ~/.bash_profile
fi
```
  
### Download binaries
```
cd $HOME
rm -rf hub
git clone https://github.com/mars-protocol/hub.git
cd hub
git checkout v1.0.0
```
Build Binaries
```
make build
mkdir -p $HOME/.mars/cosmovisor/genesis/bin
mv build/marsd $HOME/.mars/cosmovisor/genesis/bin/
rm -rf build
```

### Download Cosmovisor
```
go install cosmossdk.io/tools/cosmovisor/cmd/cosmovisor@v1.4.0
```
  
### Config
```
marsd config chain-id mars-1
marsd config keyring-backend file
marsd config node tcp://localhost:20657
```

### Init 
```
marsd init $MONIKER --chain-id mars-1
```

### Download genesis file and addrbook
```
wget -O $HOME/.mars/config/addrbook.json "https://raw.githubusercontent.com/elangrr/testnet_guide/main/mars/addrbook.json"
wget -O $HOME/.mars/config/addrbook.json "http://service.mars.indonode.net/addrbook.json"
```

### Set minimum gas price , seeds , and peers
```
seeds="52de8a7e2ad3da459961f633e50f64bf597c7585@seed.marsprotocol.io:443,d2d2629c8c8a8815f85c58c90f80b94690468c4f@tenderseed.ccvalidators.com:26012"
peers=""
sed -i -e 's|^seeds *=.*|seeds = "'$seeds'"|; s|^persistent_peers *=.*|persistent_peers = "'$peers'"|' $HOME/.mars/config/config.toml
sed -i -e "s|^minimum-gas-prices *=.*|minimum-gas-prices = \"0umars\"|" $HOME/.mars/config/app.toml
```

### Pruning (Optional)
```
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="19"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.mars/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.mars/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.mars/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.mars/config/app.toml
```

### Indexer (Optional)
```
indexer="null" && \
sed -i -e "s/^indexer *=.*/indexer = \"$indexer\"/" $HOME/.mars/config/config.toml
```

### Custom Port 
```
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:20658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:20657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:20060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:20656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \"20660\"%" $HOME/.mars/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:2017\"%; s%^address = \":8080\"%address = \":2080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:2090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:2091\"%; s%^address = \"0.0.0.0:8545\"%address = \"0.0.0.0:2045\"%; s%^ws-address = \"0.0.0.0:8546\"%ws-address = \"0.0.0.0:2046\"%" $HOME/.mars/config/app.toml
```

### Create service file and start the node
```
sudo tee /etc/systemd/system/marsd.service > /dev/null << EOF
[Unit]
Description=mars-testnet node service
After=network-online.target
[Service]
User=$USER
ExecStart=$(which cosmovisor) run start
Restart=on-failure
RestartSec=10
LimitNOFILE=65535
Environment="DAEMON_HOME=$HOME/.mars"
Environment="DAEMON_NAME=marsd"
Environment="UNSAFE_SKIP_BACKUP=true"
[Install]
WantedBy=multi-user.target
EOF
    
sudo systemctl daemon-reload
sudo systemctl enable marsd
```

Create Synlinks
```
ln -s $HOME/.mars/cosmovisor/genesis $HOME/.mars/cosmovisor/current
sudo ln -s $HOME/.mars/cosmovisor/current/bin/marsd /usr/local/bin/marsd
```

Start Cosmovisor
```
sudo systemctl restart marsd && sudo journalctl -u marsd -f -o cat
```

### Create wallet
To create new wallet use 
```
marsd keys add wallet
```
Change `wallet` to your wallet name

To recover existing keys use 
```
marsd keys add wallet --recover
```
Change `wallet` to your wallet name

To see current keys 
```
marsd keys list
```

### Snapshot Updated every 12 Hours
```
sudo apt update
sudo apt install snapd -y
sudo snap install lz4
   
sudo systemctl stop marsd
cp $HOME/.mars/data/priv_validator_state.json $HOME/.mars/priv_validator_state.json.backup
rm -rf $HOME/.mars/data

curl -L https://snapshot.mars.indonode.net/mars-snapshot.tar.lz4 | lz4 -dc - | tar -xf - -C $HOME/.mars
mv $HOME/.mars/priv_validator_state.json.backup $HOME/.mars/data/priv_validator_state.json

sudo systemctl restart marsd && journalctl -u marsd -f --no-hostname -o cat
```

 
### Create validator
After your node is synced, create validator

To check if your node is synced simply run
`curl http://localhost:20657/status sync_info "catching_up": false`

Creating validator with `1 Mars` change the value as you like

```
marsd tx staking create-validator \
  --amount 1000000umars \
  --from wallet \
  --commission-max-change-rate "0.01" \
  --commission-max-rate "0.2" \
  --commission-rate "0.05" \
  --min-self-delegation "1" \
  --pubkey $(marsd tendermint show-validator) \
  --moniker $MONIKER \
  --chain-id mars-1 \
  --identity="" \
  --details="" \
  --website="" -y
```

## Usefull commands
### Service management
Check logs
```
journalctl -fu marsd -o cat
```

Start service
```
sudo systemctl start marsd
```

Stop service
```
sudo systemctl stop marsd
```

Restart service
```
sudo systemctl restart marsd
```

### Node info
Synchronization info
```
marsd status 2>&1 | jq .SyncInfo
```

Validator info
```
marsd status 2>&1 | jq .ValidatorInfo
```

Node info
```
marsd status 2>&1 | jq .NodeInfo
```

Show node id
```
marsd tendermint show-node-id
```

Get Node Peer
```
echo $(marsd tendermint show-node-id)'@'$(curl -s ifconfig.me)':'$(cat $HOME/.mars/config/config.toml | sed -n '/Address to listen for incoming connection/{n;p;}' | sed 's/.*://; s/".*//')
```

Get Live Peer
```
curl -sS http://localhost:20657/net_info | jq -r '.result.peers[] | "\(.node_info.id)@\(.remote_ip):\(.node_info.listen_addr)"' | awk -F ':' '{print $1":"$(NF)}'
```

### Wallet operations
List of wallets
```
marsd keys list
```

Recover wallet
```
marsd keys add wallet --recover
```

Delete wallet
```
marsd keys delete wallet
```

Get wallet balance
```
marsd query bank balances <address>
```

Transfer funds
```
marsd tx bank send <FROM ADDRESS> <TO_mars_WALLET_ADDRESS> 10000000umars
```

### Voting
```
marsd tx gov vote 1 yes --from wallet --chain-id=mars-1
```

### Staking, Delegation and Rewards
Delegate Stake to your own validator
```
marsd tx staking delegate $(marsd keys show wallet --bech val -a) 1000000umars --from wallet --chain-id mars-1 --gas-adjustment 1.4 --gas auto --gas-prices 0.001umars -y
```

Delegate stake
```
marsd tx staking delegate <mars valoper> 10000000umars --from=wallet --chain-id=mars-1 --gas=auto
```

Redelegate stake from validator to another validator
```
marsd tx staking redelegate <srcValidatorAddress> <destValidatorAddress> 10000000umars --from=wallet --chain-id=mars-1 --gas=auto
```

Withdraw all rewards
```
marsd tx distribution withdraw-all-rewards --from=wallet --chain-id=mars-1 --gas=auto
```

Withdraw rewards with commision
```
marsd tx distribution withdraw-rewards <mars valoper> --from=wallet --commission --chain-id=mars-1
```

### Validator management
Edit validator
```
marsd tx staking edit-validator \
  --moniker=$MONIKER \
  --identity=<your_keybase_id> \
  --website="<your_website>" \
  --details="<your_validator_description>" \
  --chain-id=mars-1 \
  --from=wallet
```

Unjail validator
```
marsd tx slashing unjail \
  --broadcast-mode=block \
  --from=wallet \
  --chain-id=mars-1 \
  --gas=auto
```

### Delete node
```
sudo systemctl stop marsd && \
sudo systemctl disable marsd && \
rm /etc/systemd/system/marsd.service && \
sudo systemctl daemon-reload && \
cd $HOME && \
rm -rf .mars && \
rm -rf $(which marsd)
```




















