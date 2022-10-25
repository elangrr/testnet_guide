<p style="font-size:14px" align="right">
<a href="https://github.com/elangrr/testnet_guide" target="_blank">More Guide Tutorials<img src="https://avatars.githubusercontent.com/u/34649601?v=4" width="30"/></a>
</p>

<p style="font-size:14px" align="right">
<a href="https://indonode.dev/" target="_blank">Visit my website <img src="https://avatars.githubusercontent.com/u/34649601?v=4" width="30"/></a>
</p>

<p align="center">
 <img height="100" height="auto" src="https://user-images.githubusercontent.com/34649601/197785294-543d0ae0-ec0e-44c1-9b24-a631ef598967.png">


# Official Links
### [Official Document](https://github.com/okp4)
### [OKP4 Official Discord](https://discord.gg/9VRwHvTN4w)

# Explorer
## [Explorer](https://explorer.bccnodes.com/okp4/staking)

## Minimum Requirements 
- 4 or more physical CPU cores
- At least 100GB of SSD disk storage
- At least 8GB of memory (RAM)
- At least 500mbps network bandwidth

# Install Node Guide

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
git clone https://github.com/okp4/okp4d.git
cd okp4d
make install
```

### Init 
```
okp4d init <moniker> --chain-id okp4-nemeton
```
Change `<moniker>` to your moniker

### Create wallet
To create new wallet use 
```
okp4d keys add <wallet>
```
Change `<wallet>` to your wallet name

To recover existing keys use 
```
okp4d keys add <wallet> --recover
```
Change `<wallet>` to your wallet name

To see current keys 
```
okp4d keys list
```

### Download genesis file
```
wget -qO $HOME/.okp4d/config/genesis.json "https://raw.githubusercontent.com/okp4/networks/main/chains/nemeton/genesis.json"
```

### Set minimum gas price , seeds , and peers
```
sed -i.bak -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.0uknow\"/;" ~/.okp4d/config/app.toml
peers="f595a1386d5ca2e0d2cd81d3c6372c3bf84bbd16@65.109.31.114:2280,a49302f8999e5a953ebae431c4dde93479e17155@162.19.71.91:26656,dc14197ed45e84ca3afb5428eb04ea3097894d69@88.99.143.105:26656,79d179ea2e1fbdcc0c59a95ab7f1a0c48438a693@65.108.106.131:26706,501ad80236a5ac0d37aafa934c6ec69554ce7205@89.149.218.20:26656,5fbddca54548bf125ee96bb388610fe1206f087f@51.159.66.123:26656,769f74d3bb149216d0ab771d7767bd39585bc027@185.196.21.99:26656,024a57c0bb6d868186b6f627773bf427ec441ab5@65.108.2.41:36656,fff0a8c202befd9459ff93783a0e7756da305fe3@38.242.150.63:16656,2bfd405e8f0f176428e2127f98b5ec53164ae1f0@142.132.149.118:26656,bf5802cfd8688e84ac9a8358a090e99b5b769047@135.181.176.109:53656,dc9a10f2589dd9cb37918ba561e6280a3ba81b76@54.244.24.231:26656,085cf43f463fe477e6198da0108b0ab08c70c8ab@65.108.75.237:6040,803422dc38606dd62017d433e4cbbd65edd6089d@51.15.143.254:26656,b8330b2cb0b6d6d8751341753386afce9472bac7@89.163.208.12:26656"
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$peers\"/" $HOME/.okp4d/config/config.toml
seeds=""
sed -i.bak -e "s/^seeds =.*/seeds = \"$seeds\"/" $HOME/.okp4d/config/config.toml
```

### Pruning (Optional)
```
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="10"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.okp4d/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.okp4d/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.okp4d/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.okp4d/config/app.toml
```

### Indexer (Optional)
```
indexer="null" && \
sed -i -e "s/^indexer *=.*/indexer = \"$indexer\"/" $HOME/.okp4d/config/config.toml
```

### Download addrbook
```
wget -O $HOME/.okp4d/config/addrbook.json "https://raw.githubusercontent.com/obajay/nodes-Guides/main/OKP4/addrbook.json"
```

### Create service file and start the node
```
sudo tee /etc/systemd/system/okp4d.service > /dev/null <<EOF
[Unit]
Description=okp4d
After=network-online.target

[Service]
User=$USER
ExecStart=$(which okp4d) start
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF
```

### Start node
```
sudo systemctl daemon-reload
sudo systemctl enable okp4d
sudo systemctl restart okp4d && sudo journalctl -u okp4d -f -o cat
```

### State-Sync (OPTIONAL)
Sync your node in minutes
```
SNAP_RPC=https://okp4-testnet-rpc.polkachu.com:443
peers="https://okp4-testnet-rpc.polkachu.com:443"
sed -i.bak -e  "s/^persistent_peers *=.*/persistent_peers = \"$peers\"/" ~/.okp4d/config/config.toml
LATEST_HEIGHT=$(curl -s $SNAP_RPC/block | jq -r .result.block.header.height); \
BLOCK_HEIGHT=$((LATEST_HEIGHT - 500)); \
TRUST_HASH=$(curl -s "$SNAP_RPC/block?height=$BLOCK_HEIGHT" | jq -r .result.block_id.hash)

echo $LATEST_HEIGHT $BLOCK_HEIGHT $TRUST_HASH

sed -i.bak -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1true| ; \
s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"$SNAP_RPC,$SNAP_RPC\"| ; \
s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1$BLOCK_HEIGHT| ; \
s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"| ; \
s|^(seeds[[:space:]]+=[[:space:]]+).*$|\1\"\"|" $HOME/.okp4d/config/config.toml

okp4d tendermint unsafe-reset-all --home /root/.okp4d --keep-addr-book
systemctl restart okp4d && journalctl -u okp4d -f -o cat
```

### Faucet
Get your faucet at https://faucet.okp4.network/

### Create Validator
```
okp4d tx staking create-validator \
  --amount 1000000uknow \
  --from <wallet> \
  --commission-max-change-rate "0.1" \
  --commission-max-rate "0.2" \
  --commission-rate "0.1" \
  --min-self-delegation "1" \
  --pubkey  $(okp4d tendermint show-validator) \
  --moniker <moniker> \
  --chain-id okp4-nemeton \
  --identity="" \
  --details="" \
  --website="" -y
```
Change `<wallet>` and `<moniker>` 


## Usefull comuknows
### Service management
Check logs
```
journalctl -fu okp4d -o cat
```

Start service
```
sudo systemctl start okp4d
```

Stop service
```
sudo systemctl stop okp4d
```

Restart service
```
sudo systemctl restart okp4d
```

### Node info
Synchronization info
```
okp4d status 2>&1 | jq .SyncInfo
```

Validator info
```
okp4d status 2>&1 | jq .ValidatorInfo
```

Node info
```
okp4d status 2>&1 | jq .NodeInfo
```

Show node id
```
okp4d tendermint show-node-id
```

### Wallet operations
List of wallets
```
okp4d keys list
```

Recover wallet
```
okp4d keys add <wallet> --recover
```

Delete wallet
```
okp4d keys delete <wallet>
```

Get wallet balance
```
okp4d query bank balances <address>
```

Transfer funds
```
okp4d tx bank send <FROM ADDRESS> <TO_okp_WALLET_ADDRESS> 10000000uknow
```

### Voting
```
okp4d tx gov vote 1 yes --from <wallet> --chain-id=okp4-nemeton
```

### Staking, Delegation and Rewards
Delegate stake
```
okp4d tx staking delegate <okp valoper> 10000000uknow --from=<wallet> --chain-id=okp4-nemeton --gas=auto
```

Redelegate stake from validator to another validator
```
okp4d tx staking redelegate <srcValidatorAddress> <destValidatorAddress> 10000000uknow --from=<wallet> --chain-id=okp4-nemeton --gas=auto
```

Withdraw all rewards
```
okp4d tx distribution withdraw-all-rewards --from=<wallet> --chain-id=okp4-nemeton --gas=auto
```

Withdraw rewards with commision
```
okp4d tx distribution withdraw-rewards <okp valoper> --from=<wallet> --commission --chain-id=okp4-nemeton
```

### Validator management
Edit validator
```
okp4d tx staking edit-validator \
  --moniker=<moniker> \
  --identity=<your_keybase_id> \
  --website="<your_website>" \
  --details="<your_validator_description>" \
  --chain-id=okp4-nemeton \
  --from=<wallet>
```

Unjail validator
```
okp4d tx slashing unjail \
  --broadcast-mode=block \
  --from=<wallet> \
  --chain-id=okp4-nemeton \
  --gas=auto
```

### Delete node
```
sudo systemctl stop okp4d && \
sudo systemctl disable okp4d && \
rm /etc/systemd/system/okp4d.service && \
sudo systemctl daemon-reload && \
cd $HOME && \
rm -rf okp4d && \
rm -rf .okp4d && \
rm -rf $(which okp4d)
```




















