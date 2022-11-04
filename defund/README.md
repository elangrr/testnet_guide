<p style="font-size:14px" align="right">
<a href="https://github.com/elangrr/testnet_guide" target="_blank">More Guide Tutorials<img src="https://avatars.githubusercontent.com/u/34649601?v=4" width="30"/></a>
</p>

<p style="font-size:14px" align="right">
<a href="https://indonode.dev/" target="_blank">Visit my website <img src="https://avatars.githubusercontent.com/u/34649601?v=4" width="30"/></a>
</p>

<p align="center">
 <img height="200" height="auto" src="https://user-images.githubusercontent.com/50621007/171904810-664af00a-e78a-4602-b66b-20bfd874fa82.png">



# Official Links
### [Official Document](https://github.com/defund-labs/testnet/tree/main/defund-private-2)
### [Defund Official Discord](https://discord.gg/Rx2gdHmsRn)

# Explorer
### [KJ Explorer](https://explorer.kjnodes.com/defund/staking)

## Minimum Requirements 
- 4 or more physical CPU cores
- At least 100GB of SSD disk storage
- At least 8GB of memory (RAM)
- At least 100mbps network bandwidth

# Auto Install
```
wget -O defund https://raw.githubusercontent.com/elangrr/testnet_guide/main/defund/defund && chmod +x defund && ./defund
```
After Using Auto install run 
```
source $HOME/.bash_profile
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
echo export CHAIN_ID="defund-private-2" >> $HOME/.bash_profile
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
cd $HOME && rm -rf defund
git clone https://github.com/defund-labs/defund.git
cd defund
git checkout v0.1.0
make install
```

### Config
```
defundd config chain-id $CHAIN_ID
defundd config keyring-backend test
```

### Init 
```
defundd init $Nodename --chain-id $CHAIN_ID
```
Change `$Nodename` to your moniker


### Download genesis file
```
wget -qO $HOME/.defund/config/genesis.json "https://raw.githubusercontent.com/defund-labs/testnet/main/defund-private-2/genesis.json"
```

### Set minimum gas price , seeds , and peers
```
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0ufetf\"/" $HOME/.defund/config/app.toml
SEEDS="85279852bd306c385402185e0125dffeed36bf22@38.146.3.194:26656,09ce2d3fc0fdc9d1e879888e7d72ae0fefef6e3d@65.108.105.48:11256"
PEERS=""
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.defund/config/config.toml
```

### Pruning (Optional)
```
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="50"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.defund/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.defund/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.defund/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.defund/config/app.toml
```

### Indexer (Optional)
```
indexer="null" && \
sed -i -e "s/^indexer *=.*/indexer = \"$indexer\"/" $HOME/.defund/config/config.toml
```

### Create service file and start the node
```
sudo tee /etc/systemd/system/defundd.service > /dev/null <<EOF
[Unit]
Description=fetf
After=network-online.target

[Service]
User=$USER
ExecStart=$(which defundd) start --home $HOME/.defund
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable defundd
sudo systemctl restart defundd && sudo journalctl -u defundd -f -o cat
```

### Create wallet
To create new wallet use 
```
defundd keys add wallet
```
Change `wallet` to your wallet name

To recover existing keys use 
```
defundd keys add wallet --recover
```
Change `wallet` to your wallet name

To see current keys 
```
defundd keys list
```

### State-Sync (OPTIONAL)
Sync your node in minutes
```
peers="5e7853ec4f74dba1d3ae721ff9f50926107efc38@65.108.6.45:60556"
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$peers\"/" $HOME/.defund/config/config.toml

SNAP_RPC=https://t-defund.rpc.utsa.tech:443

LATEST_HEIGHT=$(curl -s $SNAP_RPC/block | jq -r .result.block.header.height); \
BLOCK_HEIGHT=$((LATEST_HEIGHT - 2000)); \
TRUST_HASH=$(curl -s "$SNAP_RPC/block?height=$BLOCK_HEIGHT" | jq -r .result.block_id.hash)

echo $LATEST_HEIGHT $BLOCK_HEIGHT $TRUST_HASH

sed -i.bak -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1true| ; \
s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"$SNAP_RPC,$SNAP_RPC\"| ; \
s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1$BLOCK_HEIGHT| ; \
s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"| ; \
s|^(seeds[[:space:]]+=[[:space:]]+).*$|\1\"\"|" $HOME/.defund/config/config.toml

sudo systemctl restart defundd && sudo journalctl -u defundd -f -o cat
```

### Ask for faucet in Discord

### Create validator
After your node is synced, create validator

To check if your node is synced simply run
`curl http://localhost:26657/status sync_info "catching_up": false`

```
defundd tx staking create-validator \
  --amount 2000000ufetf \
  --from $WALLET \
  --commission-max-change-rate "0.01" \
  --commission-max-rate "0.2" \
  --commission-rate "0.07" \
  --min-self-delegation "1" \
  --pubkey  $(defundd tendermint show-validator) \
  --moniker $Nodename \
  --chain-id $CHAIN_ID
```

## Usefull commands
### Service management
Check logs
```
journalctl -fu defundd -o cat
```

Start service
```
sudo systemctl start defundd
```

Stop service
```
sudo systemctl stop defundd
```

Restart service
```
sudo systemctl restart defundd
```

### Node info
Synchronization info
```
defundd status 2>&1 | jq .SyncInfo
```

Validator info
```
defundd status 2>&1 | jq .ValidatorInfo
```

Node info
```
defundd status 2>&1 | jq .NodeInfo
```

Show node id
```
defundd tendermint show-node-id
```

### Wallet operations
List of wallets
```
defundd keys list
```

Recover wallet
```
defundd keys add wallet --recover
```

Delete wallet
```
defundd keys delete wallet
```

Get wallet balance
```
defundd query bank balances <address>
```

Transfer funds
```
defundd tx bank send <FROM ADDRESS> <TO_defund_WALLET_ADDRESS> 10000000ufetf
```

### Voting
```
defundd tx gov vote 1 yes --from wallet --chain-id=$CHAIN_ID
```

### Staking, Delegation and Rewards
Delegate stake
```
defundd tx staking delegate <defund valoper> 10000000ufetf --from=wallet --chain-id=$CHAIN_ID --gas=auto
```

Redelegate stake from validator to another validator
```
defundd tx staking redelegate <srcValidatorAddress> <destValidatorAddress> 10000000ufetf --from=wallet --chain-id=$CHAIN_ID --gas=auto
```

Withdraw all rewards
```
defundd tx distribution withdraw-all-rewards --from=wallet --chain-id=$CHAIN_ID --gas=auto
```

Withdraw rewards with commision
```
defundd tx distribution withdraw-rewards <defund valoper> --from=wallet --commission --chain-id=$CHAIN_ID
```

### Validator management
Edit validator
```
defundd tx staking edit-validator \
  --moniker=$Nodename \
  --identity=<your_keybase_id> \
  --website="<your_website>" \
  --details="<your_validator_description>" \
  --chain-id=$CHAIN_ID \
  --from=wallet
```

Unjail validator
```
defundd tx slashing unjail \
  --broadcast-mode=block \
  --from=wallet \
  --chain-id=$CHAIN_ID \
  --gas=auto
```

### Delete node
```
sudo systemctl stop defundd && \
sudo systemctl disable defundd && \
rm /etc/systemd/system/defundd.service && \
sudo systemctl daemon-reload && \
cd $HOME && \
rm -rf .defund && \
rm -rf $(which defundd)
```




















