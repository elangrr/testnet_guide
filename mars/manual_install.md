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
### [Explorer](https://explorer.planq.network/ares-1/staking)

## Minimum Requirements 
- 4 or more physical CPU cores
- At least 160GB of SSD disk storage
- At least 8GB of memory (RAM)
- At least 120mbps network bandwidth


# Manual Install Node Guide with custom port 20

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
git checkout v1.0.0-rc7
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
marsd config chain-id ares-1
marsd config keyring-backend test
marsd config node tcp://localhost:20657
```

### Init 
```
marsd init $MONIKER --chain-id ares-1
```

### Download genesis file and addrbook
```

```

### Set minimum gas price , seeds , and peers
```
peers="14ba3b19424301a6bb58c27663a0323a81866d5d@134.122.82.186:26656,6c855909a8bf1c12ef34baca059f5c0cdf82bc36@65.108.255.124:36656,9847d03c789d9c87e84611ebc3d6df0e6123c0cc@91.194.30.203:10656,cec7501f438e2700573cdd9d45e7fb5116ba74b9@176.9.51.55:10256,e12bc490096d1b5f4026980f05a118c82e81df2a@85.17.6.142:26656,7342199e80976b052d8506cc5a56d1f9a1cbb486@65.21.89.54:26653,7226c00dd90cf182ca9ec9aa513f518965e7e1a4@167.235.7.34:43656,846ee4df536ddba9739d3f5eebd0139b0a9e5169@159.148.146.132:27225,719cf7e8f7640a48c782599475d4866b401f2d34@51.254.197.170:26656,fe8d614aa5899a97c11d0601ef50c3e7ce17d57b@65.108.233.109:18556"
sed -i -e "s|^seeds *=.*|seeds = \"3f472746f46493309650e5a033076689996c8881@mars-testnet.rpc.kjnodes.com:45659\"|" $HOME/.mars/config/config.toml
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$peers\"/" $HOME/.mars/config/config.toml
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
ExecStart=/usr/bin/cosmovisor run start
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

### Snapshot
```
SOON
```

### Faucet
[FAUCET HERE](https://faucet.marsprotocol.io/)

  
### Create validator
After your node is synced, create validator

To check if your node is synced simply run
`curl http://localhost:20657/status sync_info "catching_up": false`

Creating validator with `4 Mars` change the value as you like

```
marsd tx staking create-validator \
  --amount 4000000umars \
  --from wallet \
  --commission-max-change-rate "0.1" \
  --commission-max-rate "0.2" \
  --commission-rate "0.1" \
  --min-self-delegation "1" \
  --pubkey $(marsd tendermint show-validator) \
  --moniker $MONIKER \
  --chain-id ares-1 \
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
marsd tx gov vote 1 yes --from wallet --chain-id=ares-1
```

### Staking, Delegation and Rewards
Delegate Stake to your own validator
```
marsd tx staking delegate $(marsd keys show wallet --bech val -a) 1000000umars --from wallet --chain-id ares-1 --gas-adjustment 1.4 --gas auto --gas-prices 0.001umars -y
```

Delegate stake
```
marsd tx staking delegate <mars valoper> 10000000umars --from=wallet --chain-id=ares-1 --gas=auto
```

Redelegate stake from validator to another validator
```
marsd tx staking redelegate <srcValidatorAddress> <destValidatorAddress> 10000000umars --from=wallet --chain-id=ares-1 --gas=auto
```

Withdraw all rewards
```
marsd tx distribution withdraw-all-rewards --from=wallet --chain-id=ares-1 --gas=auto
```

Withdraw rewards with commision
```
marsd tx distribution withdraw-rewards <mars valoper> --from=wallet --commission --chain-id=ares-1
```

### Validator management
Edit validator
```
marsd tx staking edit-validator \
  --moniker=$MONIKER \
  --identity=<your_keybase_id> \
  --website="<your_website>" \
  --details="<your_validator_description>" \
  --chain-id=ares-1 \
  --from=wallet
```

Unjail validator
```
marsd tx slashing unjail \
  --broadcast-mode=block \
  --from=wallet \
  --chain-id=ares-1 \
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




















