<p style="font-size:14px" align="right">
<a href="https://github.com/elangrr/testnet_guide" target="_blank">More Guide Tutorials<img src="https://avatars.githubusercontent.com/u/34649601?v=4" width="30"/></a>
</p>

<p style="font-size:14px" align="right">
<a href="https://indonode.dev/" target="_blank">Visit my website <img src="https://avatars.githubusercontent.com/u/34649601?v=4" width="30"/></a>
</p>

<p align="center">
 <img height="200" height="auto" src="https://pbs.twimg.com/profile_images/1556857504394526721/OyWtRrNP_400x400.jpg">



# Official Links
### [Official Website](https://nibiru.fi/)
### [Official Document](https://docs.nibiru.fi/run-nodes/testnet/#)
### [Nibiru Chain Official Discord](https://discord.gg/2pBbNpgGMm)

# Explorer
[STAVR Explorer](https://texplorer.stavr.tech/nibiru/staking)

## Minimum Requirements 
- 2 or more physical CPU cores
- At least 100GB of SSD disk storage
- At least 4GB of memory (RAM)
- At least 100mbps network bandwidth

# Auto Install
```
wget -O nibi https://raw.githubusercontent.com/elangrr/testnet_guide/main/nibiru/nibi && chmod +x nibi && ./nibi
```

After completing Auto install 
```
source $HOME/.bash_profile
```
Then proceed to `Create Wallet`

# Manual Install Node Guide

### Set Vars
```
Nodename=<MONIKER>
```
Change `<MONIKER>` With your own Moniker
```
echo export Nodename=${Nodename} >> $HOME/.bash_profile
echo export CHAIN_ID="nibiru-testnet-1" >> $HOME/.bash_profile
source ~/.bash_profile
```

### Update Packages and Depencies
```
sudo apt update && sudo apt upgrade -y
```

Install Depencies
```
sudo apt install curl tar wget clang pkg-config libssl-dev libleveldb-dev jq build-essential bsdmainutils git make ncdu htop snapd screen unzip bc fail2ban htop -y
```

### Install GO
```
ver="1.18.2" && \
cd $HOME && \
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
cd $HOME
git clone https://github.com/NibiruChain/nibiru
cd nibiru
git checkout v0.15.0
make install
```
### Config
```
nibid config chain-id $CHAIN_ID
```

### Init 
```
nibid init $Nodename --chain-id $CHAIN_ID
```

### Download genesis file
```
cd $HOME
curl -s https://rpc.testnet-1.nibiru.fi/genesis | jq -r .result.genesis > genesis.json
cp genesis.json $HOME/.nibid/config/genesis.json
```

### Set minimum gas price , seeds , and peers
```
sed -i.bak -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.025unibi\"/;" ~/.nibid/config/app.toml
sed -i -e "s/^filter_peers *=.*/filter_peers = \"true\"/" $HOME/.nibid/config/config.toml
peers="37713248f21c37a2f022fbbb7228f02862224190@35.243.130.198:26656,ff59bff2d8b8fb6114191af7063e92a9dd637bd9@35.185.114.96:26656,cb431d789fe4c3f94873b0769cb4fce5143daf97@35.227.113.63:26656"
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$peers\"/" $HOME/.nibid/config/config.toml
```
### Update Block time parameters
```
CONFIG_TOML="$HOME/.nibid/config/config.toml"
 sed -i 's/timeout_propose =.*/timeout_propose = "100ms"/g' $CONFIG_TOML
 sed -i 's/timeout_propose_delta =.*/timeout_propose_delta = "500ms"/g' $CONFIG_TOML
 sed -i 's/timeout_prevote =.*/timeout_prevote = "100ms"/g' $CONFIG_TOML
 sed -i 's/timeout_prevote_delta =.*/timeout_prevote_delta = "500ms"/g' $CONFIG_TOML
 sed -i 's/timeout_precommit =.*/timeout_precommit = "100ms"/g' $CONFIG_TOML
 sed -i 's/timeout_precommit_delta =.*/timeout_precommit_delta = "500ms"/g' $CONFIG_TOML
 sed -i 's/timeout_commit =.*/timeout_commit = "1s"/g' $CONFIG_TOML
 sed -i 's/skip_timeout_commit =.*/skip_timeout_commit = false/g' $CONFIG_TOML
```

### Pruning (Optional)
```
pruning="custom" && \
pruning_keep_recent="100" && \
pruning_keep_every="0" && \
pruning_interval="10" && \
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" ~/.nibid/config/app.toml && \
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" ~/.nibid/config/app.toml && \
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" ~/.nibid/config/app.toml && \
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" ~/.nibid/config/app.toml
```

### Indexer (Optional)
```
indexer="null" && \
sed -i -e "s/^indexer *=.*/indexer = \"$indexer\"/" $HOME/.nibid/config/config.toml
```

### Download addrbook
```
wget -O $HOME/nibid/config/addrbook.json "https://raw.githubusercontent.com/elangrr/testnet_guide/main/nibiru/addrbook.json"
```

### Create service file and start the node
```
sudo tee /etc/systemd/system/nibid.service > /dev/null <<EOF
[Unit]
Description=nibid
After=network-online.target
[Service]
User=$USER
ExecStart=$(which nibid) start
Restart=on-failure
RestartSec=3
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable nibid
sudo systemctl restart nibid && sudo journalctl -u nibid -f -o cat
```

### Create wallet
To create new wallet use 
```
nibid keys add wallet
```

To recover existing keys use 
```
nibid keys add wallet --recover
```

To see current keys 
```
nibid keys list
```

### State-Sync (OPTIONAL)
Sync your node in minutes
```
peers="968472e8769e0470fadad79febe51637dd208445@65.108.6.45:60656"
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$peers\"/" $HOME/.nibid/config/config.toml

SNAP_RPC=https://t-nibiru.rpc.utsa.tech:443

LATEST_HEIGHT=$(curl -s $SNAP_RPC/block | jq -r .result.block.header.height); \
BLOCK_HEIGHT=$((LATEST_HEIGHT - 2000)); \
TRUST_HASH=$(curl -s "$SNAP_RPC/block?height=$BLOCK_HEIGHT" | jq -r .result.block_id.hash)

echo $LATEST_HEIGHT $BLOCK_HEIGHT $TRUST_HASH

sed -i.bak -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1true| ; \
s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"$SNAP_RPC,$SNAP_RPC\"| ; \
s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1$BLOCK_HEIGHT| ; \
s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"| ; \
s|^(seeds[[:space:]]+=[[:space:]]+).*$|\1\"\"|" $HOME/.nibid/config/config.toml

nibid tendermint unsafe-reset-all --home /root/.nibid--keep-addr-book
systemctl restart nibid && journalctl -u nibid -f -o cat
```

### Ask for faucet
```
curl -X POST -d '{"address": "'"<ADDRESS>"'", "coins": ["10000000unibi","100000000000unusd"]}' "https://faucet.testnet-1.nibiru.fi/"
```
Change `<ADDRESS>` to your address

### Create validator
After your node is synced, create validator

To check if your node is synced simply run
`curl http://localhost:26657/status sync_info "catching_up": false`

```
nibid tx staking create-validator \
--amount 10000000unibi \
--commission-max-change-rate "0.1" \
--commission-max-rate "0.20" \
--commission-rate "0.1" \
--min-self-delegation "1" \
--details " " \
--pubkey=$(nibid tendermint show-validator) \
--moniker $Nodename \
--chain-id $CHAIN_ID \
--gas-prices 0.025unibi \
--from wallet
```


## Usefull commands
### Service management
Check logs
```
journalctl -fu nibid -o cat
```

Start service
```
sudo systemctl start nibid
```

Stop service
```
sudo systemctl stop nibid
```

Restart service
```
sudo systemctl restart nibid
```

### Node info
Synchronization info
```
nibid status 2>&1 | jq .SyncInfo
```

Validator info
```
nibid status 2>&1 | jq .ValidatorInfo
```

Node info
```
nibid status 2>&1 | jq .NodeInfo
```

Show node id
```
nibid tendermint show-node-id
```

### Wallet operations
List of wallets
```
nibid keys list
```

Recover wallet
```
nibid keys add wallet --recover
```

Delete wallet
```
nibid keys delete wallet
```

Get wallet balance
```
nibid query bank balances <address>
```

Transfer funds
```
nibid tx bank send <FROM ADDRESS> <TO_NIBIRU_WALLET_ADDRESS> 10000000unibi
```

### Voting
```
nibid tx gov vote 1 yes --from wallet --chain-id=$CHAIN_ID
```

### Staking, Delegation and Rewards
Delegate stake
```
nibid tx staking delegate <mande valoper> 10000000unibi --from=wallet --chain-id=$CHAIN_ID --gas=auto
```

Redelegate stake from validator to another validator
```
nibid tx staking redelegate <srcValidatorAddress> <destValidatorAddress> 10000000mand --from=wallet --chain-id=$CHAIN_ID --gas=auto
```

Withdraw all rewards
```
nibid tx distribution withdraw-all-rewards --from=wallet --chain-id=$CHAIN_ID --gas=auto
```

Withdraw rewards with commision
```
nibid tx distribution withdraw-rewards <mande valoper> --from=wallet --commission --chain-id=$CHAIN_ID
```

### Validator management
Edit validator
```
nibid tx staking edit-validator \
  --moniker=<moniker> \
  --identity=<your_keybase_id> \
  --website="<your_website>" \
  --details="<your_validator_description>" \
  --chain-id=$CHAIN_ID \
  --from=wallet
```

Unjail validator
```
nibid tx slashing unjail \
  --broadcast-mode=block \
  --from=wallet \
  --chain-id=$CHAIN_ID \
  --gas=auto
```

### Delete node
```
sudo systemctl stop nibid && \
sudo systemctl disable nibid && \
rm /etc/systemd/system/nibid.service && \
sudo systemctl daemon-reload && \
cd $HOME && \
rm -rf nibid && \
rm -rf $(which nibid)
```




















