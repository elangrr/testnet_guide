<p style="font-size:14px" align="right">
<a href="https://github.com/elangrr/testnet_guide" target="_blank">More Guide Tutorials<img src="https://avatars.githubusercontent.com/u/34649601?v=4" width="30"/></a>
</p>

<p style="font-size:14px" align="right">
<a href="https://indonode.dev/" target="_blank">Visit my website <img src="https://avatars.githubusercontent.com/u/34649601?v=4" width="30"/></a>
</p>

<p align="center">
 <img height="200" height="auto" src="https://user-images.githubusercontent.com/34649601/207593974-32d7cb69-eca9-4096-bc96-246fe7038c88.png">


# Official Links
### [Official Document](https://docs-nolus-protocol.notion.site/Run-a-Full-Node-7a92545223e7483bb4a02cce30b53aa8)
### [Nolus Official Discord](https://discord.gg/nolus-protocol)

# Explorer
### SOON

## Minimum Requirements 
- 2 or more physical CPU cores
- At least 120GB of SSD disk storage
- At least 4GB of memory (RAM)
- At least 100mbps network bandwidth

# Auto Install ( SOON )
```
SOOOOON
```
After Using Auto install run 
```
SOOON
```
After This , Proceed to `Create Wallet`

# Manual Install Node Guide

### Set vars
```
Nodename=$Nodename
```
Change `$Nodename` to your moniker
```
echo export Nodename=${Nodename} >> $HOME/.bash_profile
echo export CHAIN_ID="nolus-rila" >> $HOME/.bash_profile
source ~/.bash_profile
```

### Update Packages
```
sudo apt update && sudo apt upgrade -y
```

### Install Depencies
```
sudo apt install curl tar wget tmux htop net-tools clang pkg-config libssl-dev jq build-essential git make ncdu -y
```

### Install GO
```
ver="1.19" && \
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz" && \
sudo rm -rf /usr/local/go && \
sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz" && \
rm "go$ver.linux-amd64.tar.gz" && \
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> $HOME/.bash_profile && \
source $HOME/.bash_profile && \
go version
```

### Download binaries
```
cd $HOME && rm -rf nolus-core
git clone https://github.com/Nolus-Protocol/nolus-core
cd nolus-core
git checkout v0.1.39
make install
```

### Config
```
nolusd config chain-id $CHAIN_ID
nolusd config keyring-backend test
```

### Init 
```
nolusd init $Nodename --chain-id $CHAIN_ID
```
Change `$Nodename` to your moniker


### Download genesis file and addrbook
```
wget -O $HOME/.nolus/config/genesis.json "https://raw.githubusercontent.com/Nolus-Protocol/nolus-networks/main/testnet/nolus-rila/genesis.json"
wget -O $HOME/.nolus/config/addrbook.json "https://raw.githubusercontent.com/elangrr/testnet_guide/main/nolus/addrbook.json"
```

### Set minimum gas price , seeds , and peers
```
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.0025unls\"/" $HOME/.nolus/config/app.toml
PEERS="$(curl -s "https://raw.githubusercontent.com/Nolus-Protocol/nolus-networks/main/testnet/nolus-rila/persistent_peers.txt")"
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.nolus/config/config.toml
```

### Pruning (Optional)
```
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="50"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.nolus/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.nolus/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.nolus/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.nolus/config/app.toml
```

### Indexer (Optional)
```
indexer="null" && \
sed -i -e "s/^indexer *=.*/indexer = \"$indexer\"/" $HOME/.nolus/config/config.toml
```

### Create service file and start the node
```
sudo tee /etc/systemd/system/nolusd.service > /dev/null <<EOF
[Unit]
Description=nolus
After=network-online.target

[Service]
User=$USER
ExecStart=$(which nolusd) start --home $HOME/.nolus
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable nolusd
sudo systemctl restart nolusd && sudo journalctl -u nolusd -f -o cat
```

### Create wallet
To create new wallet use 
```
nolusd keys add wallet
```
Change `wallet` to your wallet name

To recover existing keys use 
```
nolusd keys add wallet --recover
```
Change `wallet` to your wallet name

To see current keys 
```
nolusd keys list
```

### State-Sync (OPTIONAL)
Sync your node in minutes
```
SOON
```

### Get faucet here 

### [NOLUS FAUCET](https://faucet-rila.nolus.io/)

### Create validator
After your node is synced, create validator

To check if your node is synced simply run
`curl http://localhost:26657/status sync_info "catching_up": false`

Create validator with 9 Nolus
```
nolusd tx staking create-validator \
  --amount 9000000unls \
  --from wallet \
  --commission-max-change-rate "0.01" \
  --commission-max-rate "0.2" \
  --commission-rate "0.07" \
  --min-self-delegation "1" \
  --pubkey  $(nolusd tendermint show-validator) \
  --moniker $Nodename \
  --chain-id $CHAIN_ID \
  --fees 500unls
```

## Usefull commands
### Service management
Check logs
```
journalctl -fu nolusd -o cat
```

Start service
```
sudo systemctl start nolusd
```

Stop service
```
sudo systemctl stop nolusd
```

Restart service
```
sudo systemctl restart nolusd
```

### Node info
Synchronization info
```
nolusd status 2>&1 | jq .SyncInfo
```

Validator info
```
nolusd status 2>&1 | jq .ValidatorInfo
```

Node info
```
nolusd status 2>&1 | jq .NodeInfo
```

Show node id
```
nolusd tendermint show-node-id
```

### Wallet operations
List of wallets
```
nolusd keys list
```

Recover wallet
```
nolusd keys add wallet --recover
```

Delete wallet
```
nolusd keys delete wallet
```

Get wallet balance
```
nolusd query bank balances <address>
```

Transfer funds
```
nolusd tx bank send <FROM ADDRESS> <TO_defund_WALLET_ADDRESS> 10000000unls
```

### Voting
```
nolusd tx gov vote 1 yes --from wallet --chain-id=$CHAIN_ID
```

### Staking, Delegation and Rewards
Delegate stake
```
nolusd tx staking delegate <defund valoper> 10000000unls --from=wallet --chain-id=$CHAIN_ID --gas=auto
```

Redelegate stake from validator to another validator
```
nolusd tx staking redelegate <srcValidatorAddress> <destValidatorAddress> 10000000unls --from=wallet --chain-id=$CHAIN_ID --gas=auto
```

Withdraw all rewards
```
nolusd tx distribution withdraw-all-rewards --from=wallet --chain-id=$CHAIN_ID --gas=auto
```

Withdraw rewards with commision
```
nolusd tx distribution withdraw-rewards <defund valoper> --from=wallet --commission --chain-id=$CHAIN_ID
```

### Validator management
Edit validator
```
nolusd tx staking edit-validator \
  --moniker=$Nodename \
  --identity=<your_keybase_id> \
  --website="<your_website>" \
  --details="<your_validator_description>" \
  --chain-id=$CHAIN_ID \
  --from=wallet
```

Unjail validator
```
nolusd tx slashing unjail \
  --broadcast-mode=block \
  --from=wallet \
  --chain-id=$CHAIN_ID \
  --gas=auto
```

### Delete node
```
sudo systemctl stop nolusd && \
sudo systemctl disable nolusd && \
rm /etc/systemd/system/nolusd.service && \
sudo systemctl daemon-reload && \
cd $HOME && \
rm -rf .nolus && \
rm -rf $(which nolusd)
```




















