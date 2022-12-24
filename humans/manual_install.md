<p style="font-size:14px" align="right">
<a href="https://github.com/elangrr/testnet_guide" target="_blank">More Guide Tutorials<img src="https://avatars.githubusercontent.com/u/34649601?v=4" width="30"/></a>
</p>

<p style="font-size:14px" align="right">
<a href="https://indonode.dev/" target="_blank">Visit my website <img src="https://avatars.githubusercontent.com/u/34649601?v=4" width="30"/></a>
</p>

<p align="center">
 <img height="200" height="auto" src="https://user-images.githubusercontent.com/34649601/209423077-9a15c401-77b2-4002-b75f-13d948f31c7d.png">


# Official Links
### [Official Document](https://docs.humans.zone/dev/cli/humansd-binary.html#)
### [Humans Ai Official Discord](https://discord.gg/humansdotai)

# Explorer
### [KJ Explorer](https://explorer.kjnodes.com/defund/staking)

## Minimum Requirements 
- 4 or more physical CPU cores
- At least 120GB of SSD disk storage
- At least 8GB of memory (RAM)
- At least 100mbps network bandwidth


# Manual Install Node Guide

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
     ver="1.18.2"
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
rm -rf humans
git clone https://github.com/humansdotai/humans
cd humans
git checkout v1
go build -o humansd cmd/humansd/main.go
mkdir -p $HOME/.humans/cosmovisor/genesis/bin
sudo cp humansd $HOME/.humans/cosmovisor/genesis/bin/
```

### Download Cosmovisor
```
go install cosmossdk.io/tools/cosmovisor/cmd/cosmovisor@v1.4.0
```
  
### Config
```
humansd config chain-id testnet-1
humansd config keyring-backend test
humansd config node tcp://localhost:13657
```

### Init 
```
humansd init $MONIKER --chain-id testnet-1
```

### Download genesis file and addrbook
```
wget https://snapshots.polkachu.com/testnet-genesis/humans/genesis.json -O $HOME/.humans/config/genesis.json
curl -s https://snapshots4-testnet.nodejumper.io/humans-testnet/addrbook.json > $HOME/.humans/config/addrbook.json
```

### Set minimum gas price , seeds , and peers
```
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0uheart\"/" $HOME/.humans/config/app.toml
SEEDS="e711b6631c3e5bb2f6c389cbc5d422912b05316b@rpc.humans.ppnv.space:14256" 
PEERS="8b4c5d2f104759d91317acb27838eeeb1dddec7d@rpc.humans.ppnv.space:30656"
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.humans/config/config.toml
```

### Pruning (Optional)
```
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="50"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.humans/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.humans/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.humans/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.humans/config/app.toml
```

### Indexer (Optional)
```
indexer="null" && \
sed -i -e "s/^indexer *=.*/indexer = \"$indexer\"/" $HOME/.humans/config/config.toml
```

### Create service file and start the node
```
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
sudo systemctl restart humansd && sudo journalctl -u humansd -f -o cat
```

### Create wallet
To create new wallet use 
```
humansd keys add wallet
```
Change `wallet` to your wallet name

To recover existing keys use 
```
humansd keys add wallet --recover
```
Change `wallet` to your wallet name

To see current keys 
```
humansd keys list
```

### State-Sync (OPTIONAL)
Sync your node in minutes
```
peers="5e7853ec4f74dba1d3ae721ff9f50926107efc38@65.108.6.45:60556"
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$peers\"/" $HOME/.humans/config/config.toml

SNAP_RPC=https://t-defund.rpc.utsa.tech:443

LATEST_HEIGHT=$(curl -s $SNAP_RPC/block | jq -r .result.block.header.height); \
BLOCK_HEIGHT=$((LATEST_HEIGHT - 2000)); \
TRUST_HASH=$(curl -s "$SNAP_RPC/block?height=$BLOCK_HEIGHT" | jq -r .result.block_id.hash)

echo $LATEST_HEIGHT $BLOCK_HEIGHT $TRUST_HASH

sed -i.bak -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1true| ; \
s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"$SNAP_RPC,$SNAP_RPC\"| ; \
s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1$BLOCK_HEIGHT| ; \
s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"| ; \
s|^(seeds[[:space:]]+=[[:space:]]+).*$|\1\"\"|" $HOME/.humans/config/config.toml

sudo systemctl restart humansd && sudo journalctl -u humansd -f -o cat
```

### Ask for faucet in Discord

### Create validator
After your node is synced, create validator

To check if your node is synced simply run
`curl http://localhost:13657/status sync_info "catching_up": false`

```
humansd tx staking create-validator \
  --amount 2000000ufetf \
  --from wallet \
  --commission-max-change-rate "0.01" \
  --commission-max-rate "0.2" \
  --commission-rate "0.07" \
  --min-self-delegation "1" \
  --pubkey  $(humansd tendermint show-validator) \
  --moniker $MONIKER \
  --chain-id testnet-1
```

## Usefull commands
### Service management
Check logs
```
journalctl -fu humansd -o cat
```

Start service
```
sudo systemctl start humansd
```

Stop service
```
sudo systemctl stop humansd
```

Restart service
```
sudo systemctl restart humansd
```

### Node info
Synchronization info
```
humansd status 2>&1 | jq .SyncInfo
```

Validator info
```
humansd status 2>&1 | jq .ValidatorInfo
```

Node info
```
humansd status 2>&1 | jq .NodeInfo
```

Show node id
```
humansd tendermint show-node-id
```

### Wallet operations
List of wallets
```
humansd keys list
```

Recover wallet
```
humansd keys add wallet --recover
```

Delete wallet
```
humansd keys delete wallet
```

Get wallet balance
```
humansd query bank balances <address>
```

Transfer funds
```
humansd tx bank send <FROM ADDRESS> <TO_defund_WALLET_ADDRESS> 10000000ufetf
```

### Voting
```
humansd tx gov vote 1 yes --from wallet --chain-id=testnet-1
```

### Staking, Delegation and Rewards
Delegate stake
```
humansd tx staking delegate <defund valoper> 10000000ufetf --from=wallet --chain-id=testnet-1 --gas=auto
```

Redelegate stake from validator to another validator
```
humansd tx staking redelegate <srcValidatorAddress> <destValidatorAddress> 10000000ufetf --from=wallet --chain-id=testnet-1 --gas=auto
```

Withdraw all rewards
```
humansd tx distribution withdraw-all-rewards --from=wallet --chain-id=testnet-1 --gas=auto
```

Withdraw rewards with commision
```
humansd tx distribution withdraw-rewards <defund valoper> --from=wallet --commission --chain-id=testnet-1
```

### Validator management
Edit validator
```
humansd tx staking edit-validator \
  --moniker=$MONIKER \
  --identity=<your_keybase_id> \
  --website="<your_website>" \
  --details="<your_validator_description>" \
  --chain-id=testnet-1 \
  --from=wallet
```

Unjail validator
```
humansd tx slashing unjail \
  --broadcast-mode=block \
  --from=wallet \
  --chain-id=testnet-1 \
  --gas=auto
```

### Delete node
```
sudo systemctl stop humansd && \
sudo systemctl disable humansd && \
rm /etc/systemd/system/humansd.service && \
sudo systemctl daemon-reload && \
cd $HOME && \
rm -rf .humans && \
rm -rf $(which humansd)
```




















