<p style="font-size:14px" align="right">
<a href="https://github.com/elangrr/testnet_guide" target="_blank">More Guide Tutorials<img src="https://avatars.githubusercontent.com/u/34649601?v=4" width="30"/></a>
</p>

<p style="font-size:14px" align="right">
<a href="https://indonode.dev/" target="_blank">Visit my website <img src="https://avatars.githubusercontent.com/u/34649601?v=4" width="30"/></a>
</p>

<p align="center">
 <img height="250" height="auto" src="https://user-images.githubusercontent.com/34649601/195998836-4f64c191-0a50-4819-a623-a2e9fb84901b.png">



# Official Links
### [Official Document](https://github.com/mande-labs/testnet-1)
### [Mande Chain Official Discord](https://discord.gg/Q43H94fG7X)

# Explorer
[STAVR Explorer](https://explorer.stavr.tech/mande-chain/staking)

## Minimum Requirements 
- 2 or more physical CPU cores
- At least 100GB of SSD disk storage
- At least 4GB of memory (RAM)
- At least 100mbps network bandwidth

# Auto Install
```
wget -O mand https://raw.githubusercontent.com/elangrr/testnet_guide/main/mande%20chain/mand && chmod +x mand && ./mand
```

# Manual Install Node Guide

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
cd $HOME
curl -OL https://github.com/mande-labs/testnet-1/raw/main/mande-chaind
mv mande-chaind /usr/local/bin
chmod 744 /usr/local/bin/mande-chaind
```

### Init 
```
mande-chaind init <moniker> --chain-id mande-testnet-1
```
Change `<moniker>` to your moniker


### Download genesis file
```
wget -O $HOME/.mande-chain/config/genesis.json "https://raw.githubusercontent.com/mande-labs/testnet-1/main/genesis.json"
```

### Set minimum gas price , seeds , and peers
```
sed -i.bak -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.0mand\"/;" ~/.mande-chain/config/app.toml
sed -i -e "s/^filter_peers *=.*/filter_peers = \"true\"/" $HOME/.mande-chain/config/config.toml
peers="cd3e4f5b7f5680bbd86a96b38bc122aa46668399@34.171.132.212:26656,6780b2648bd2eb6adca2ca92a03a25b216d4f36b@34.170.16.69:26656,a3e3e20528604b26b792055be84e3fd4de70533b@38.242.199.93:24656"
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$peers\"/" $HOME/.mande-chain/config/config.toml
seeds="cd3e4f5b7f5680bbd86a96b38bc122aa46668399@34.171.132.212:26656"
sed -i.bak -e "s/^seeds =.*/seeds = \"$seeds\"/" $HOME/.mande-chain/config/config.toml
```

### Pruning (Optional)
```
pruning="custom" && \
pruning_keep_recent="100" && \
pruning_keep_every="0" && \
pruning_interval="10" && \
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" ~/.mande-chain/config/app.toml && \
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" ~/.mande-chain/config/app.toml && \
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" ~/.mande-chain/config/app.toml && \
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" ~/.mande-chain/config/app.toml
```

### Indexer (Optional)
```
indexer="null" && \
sed -i -e "s/^indexer *=.*/indexer = \"$indexer\"/" $HOME/.mande-chain/config/config.toml
```

### Download addrbook
```
wget -O $HOME/.mande-chain/config/addrbook.json "https://raw.githubusercontent.com/obajay/nodes-Guides/main/Mande%20Chain/addrbook.json"
```

### Create service file and start the node
```
sudo tee /etc/systemd/system/mande-chaind.service > /dev/null <<EOF
[Unit]
Description=mande-chaind
After=network-online.target

[Service]
User=$USER
ExecStart=$(which mande-chaind) start
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF
sudo systemctl daemon-reload
sudo systemctl enable mande-chaind
sudo systemctl restart mande-chaind && sudo journalctl -u mande-chaind -f -o cat
```

### Create wallet
To create new wallet use 
```
mande-chaind keys add <wallet>
```
Change `<wallet>` to your wallet name

To recover existing keys use 
```
mande-chaind keys add <wallet> --recover
```
Change `<wallet>` to your wallet name

To see current keys 
```
mande-chaind keys list
```

### State-Sync (OPTIONAL)
Sync your node in minutes
```
SNAP_RPC=http://209.182.239.169:28657
peers="bd9929b9a2e8b5ad1581e4b01f85457e0d01cba3@209.182.239.169:28656"
sed -i.bak -e  "s/^persistent_peers *=.*/persistent_peers = \"$peers\"/" ~/.mande-chain/config/config.toml
LATEST_HEIGHT=$(curl -s $SNAP_RPC/block | jq -r .result.block.header.height); \
BLOCK_HEIGHT=$((LATEST_HEIGHT - 500)); \
TRUST_HASH=$(curl -s "$SNAP_RPC/block?height=$BLOCK_HEIGHT" | jq -r .result.block_id.hash)

echo $LATEST_HEIGHT $BLOCK_HEIGHT $TRUST_HASH

sed -i.bak -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1true| ; \
s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"$SNAP_RPC,$SNAP_RPC\"| ; \
s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1$BLOCK_HEIGHT| ; \
s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"| ; \
s|^(seeds[[:space:]]+=[[:space:]]+).*$|\1\"\"|" $HOME/.mande-chain/config/config.toml

mande-chaind tendermint unsafe-reset-all --home /root/.mande-chain --keep-addr-book
systemctl restart mande-chaind && journalctl -u mande-chaind -f -o cat
```

### Ask for faucet
```
curl -d '{"address":"<MANDE ADDRESS>"}' -H 'Content-Type: application/json' http://35.224.207.121:8080/request
```
Change `<MANDE ADDRESS>` to your address

### Create validator
After your node is synced, create validator

To check if your node is synced simply run
`curl http://localhost:26657/status sync_info "catching_up": false`

```
mande-chaind tx staking create-validator \
--chain-id mande-testnet-1 \
--amount 0cred \
--pubkey "$(mande-chaind tendermint show-validator)" \
--from <wallet> \
--moniker="<Moniker>" \
--fees 1000mand
```
Change `<wallet>` and `<moniker>` 


## Usefull commands
### Service management
Check logs
```
journalctl -fu mande-chaind -o cat
```

Start service
```
sudo systemctl start mande-chaind
```

Stop service
```
sudo systemctl stop mande-chaind
```

Restart service
```
sudo systemctl restart mande-chaind
```

### Node info
Synchronization info
```
mande-chaind status 2>&1 | jq .SyncInfo
```

Validator info
```
mande-chaind status 2>&1 | jq .ValidatorInfo
```

Node info
```
mande-chaind status 2>&1 | jq .NodeInfo
```

Show node id
```
mande-chaind tendermint show-node-id
```

### Wallet operations
List of wallets
```
mande-chaind keys list
```

Recover wallet
```
mande-chaind keys add <wallet> --recover
```

Delete wallet
```
mande-chaind keys delete <wallet>
```

Get wallet balance
```
mande-chaind query bank balances <address>
```

Transfer funds
```
mande-chaind tx bank send <FROM ADDRESS> <TO_MANDE_WALLET_ADDRESS> 10000000mand
```

### Voting
```
mande-chaind tx gov vote 1 yes --from <wallet> --chain-id=mande-testnet-1
```

### Staking, Delegation and Rewards
Delegate stake
```
mande-chaind tx staking delegate <mande valoper> 10000000mand --from=<wallet> --chain-id=mande-testnet-1 --gas=auto
```

Redelegate stake from validator to another validator
```
mande-chaind tx staking redelegate <srcValidatorAddress> <destValidatorAddress> 10000000mand --from=<wallet> --chain-id=mande-testnet-1 --gas=auto
```

Withdraw all rewards
```
mande-chaind tx distribution withdraw-all-rewards --from=<wallet> --chain-id=mande-testnet-1 --gas=auto
```

Withdraw rewards with commision
```
mande-chaind tx distribution withdraw-rewards <mande valoper> --from=<wallet> --commission --chain-id=mande-testnet-1
```

### Validator management
Edit validator
```
mande-chaind tx staking edit-validator \
  --moniker=<moniker> \
  --identity=<your_keybase_id> \
  --website="<your_website>" \
  --details="<your_validator_description>" \
  --chain-id=mande-testnet-1 \
  --from=<wallet>
```

Unjail validator
```
mande-chaind tx slashing unjail \
  --broadcast-mode=block \
  --from=<wallet> \
  --chain-id=mande-testnet-1 \
  --gas=auto
```

### Delete node
```
sudo systemctl stop mande-chaind && \
sudo systemctl disable mande-chaind && \
rm /etc/systemd/system/mande-chaind.service && \
sudo systemctl daemon-reload && \
cd $HOME && \
rm -rf .mande-chain && \
rm -rf $(which mande-chaind)
```




















