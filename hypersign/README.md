<p style="font-size:14px" align="right">
<a href="https://github.com/elangrr/testnet_guide" target="_blank">More Guide Tutorials<img src="https://avatars.githubusercontent.com/u/34649601?v=4" width="30"/></a>
</p>

<p style="font-size:14px" align="right">
<a href="https://indonode.dev/" target="_blank">Visit my website <img src="https://avatars.githubusercontent.com/u/34649601?v=4" width="30"/></a>
</p>

<p align="center">
 <img height="200" height="auto" src="https://user-images.githubusercontent.com/50621007/189590189-369a8e4d-97a6-4c1e-97cc-6a9586c3697e.png">



# Official Links
### [Official Document](https://github.com/hypersign-protocol/hid-node)
### [Hypersign Official Discord](https://discord.gg/RAnJjbkyzx)
### [Hypersign Explorer](https://explorer.theamsolutions.info/hypersign-test/staking)

## Minimum Requirements 
- 4 or more physical CPU cores
- At least 160GB of SSD disk storage
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
git clone https://github.com/hypersign-protocol/hid-node.git
cd hid-node
git checkout v0.1.2
make install
```

### Init 
```
hid-noded init <moniker> --chain-id jagrat
```
Change `<moniker>` to your moniker

### Create wallet
To create new wallet use 
```
hid-noded keys add <wallet>
```
Change `<wallet>` to your wallet name

To recover existing keys use 
```
hid-noded keys add <wallet> --recover
```
Change `<wallet>` to your wallet name

To see current keys 
```
hid-noded keys list
```

### Download genesis file
```
wget -qO $HOME/.hid-node/config/genesis.json https://github.com/hypersign-protocol/networks/raw/master/testnet/jagrat/final_genesis.json
```

### Set minimum gas price , seeds , and peers
```
sed -i.bak -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0uhid\"/;" ~/.hid-node/config/app.toml
SEEDS=""
PEERS="7991e99ee8c05906a2161d8b47d826240da5c5d2@network.jagart.hypersign.id:26656,4625d4f9aa5034579134bdd551b6b54ee2b48c6a@network.jagart.hypersign.id:26656,85d140e4c211992d50285d93ba4cadc7d89410b5@38.242.206.64:26656,20e40949206d9d991274bfa388af4f77b7da0de1@176.100.3.29:26656,5cd888a5c37474ca778277cfd9dee7d24fe96094@95.217.214.107:26656,e0fe2fd7aa53edabf4978d96928d4d754d2140b0@23.88.55.152:26656,82fe77bca592a1dbcf747ad7f76847495bb4923e@65.108.151.238:26657,71043088812f947facd25b4f93c4eca73bc922f6@65.109.28.219:10956,cccc44f39832eaa9ae345fa92e47b553517765aa@207.180.197.147:26656,af22e60521ee775cad6ac83b4104783407df3fc2@172.104.184.55:26656,9aac6b663fa75bc1e50ad74aa8efa929e31fd3e4@178.250.242.94:26656,84408be4e3f13dcd976568d6370e1c50e9eb614d@185.252.232.110:46656,b0206e6ccd3ed9bfbb0feb9401faf27559742dc8@5.161.55.130:26656,776785ba52f350e10c0eaba22731e0891edb07fc@154.12.236.152:26656,c395620698af314d68a62df4217f5fd1aacad696@65.21.129.95:46636,d5f7dfff307cefb8e960000caf53b92dd9c58a1d@65.109.28.177:29227,14996170d73843813be594a03eb9690b95ea71bd@13.76.157.155:26656,6f95b7db6a293887dcd4b11137cd824f48c43f50@165.22.197.119:26657,77fbcaef349a10d628aac7f0832d450d4f869bdf@195.201.123.105:26656,5daa030db81056a177ac0b9d9aa0cdcaaef4e4c9@103.25.200.231:26656,69e7ff3d6bc66e3f1e5f1d0794643be4ace556fc@65.109.49.111:26456,ed12770cba24bfc5ea73d470115067bde00d8291@198.244.159.55:26656,2bd6f4bfb15c56cb1f179f9d921b37772dcfb9fa@5.161.154.109:36656,3990d5a402ca8f9e53441b02e22f4558c5c85fc5@65.108.44.149:27756,2128694e7da76a731b24d8bc059227748f0bc38d@144.91.100.18:26657,7bd5ca4aebb21d664939295c306ad6aef70b5604@95.161.27.57:26656,1dae68f061204fe2c10e9476239c0333258889e7@65.109.31.114:2460,ad06dd3131caea14bcbe809b5dc58c885859538e@38.242.216.207:26656,9f5079901be228be2a8686b4f17376441853ef26@65.108.52.192:56656,5b6356defbfc7227035698d6af7d686d3981a0eb@5.161.99.136:26656,bd8d56f381cde164db541a5764c6bf8f484fcf18@51.250.106.108:26656,70f00c612c1d681a04244749a56f3a35e9be1420@65.108.194.40:28765,839e1ee14102cc2a8c6616ab1a4cc96862cfccc3@95.217.131.157:26656,80a0eb37a75fbe0a66baa4c18a167ccaa7440a2c@95.216.156.201:26657,d5080fcee1b12910eee2ed35460b9046ecfd5dc3@139.162.235.100:26926,e32d544f129ae096dbc9f123de7f7af32ebf2ace@65.108.103.184:26656,98625e86ec117d277a58b8c576058189991ae6c0@65.108.206.56:13656,b441c4bfa215e8b46fe058e7a4ce4886d87860e3@132.145.54.94:26656,fd8a8905a404d4169e9a9ed7f4b034079e6a13ab@65.108.77.250:46151,06901d4cb4f0902e27c18ae19d5a67f3506b7d18@45.140.185.6:26656,8e4938aa6561695326f61f432ea2b2a53a428205@95.217.118.96:27161,4a020006964d92bd752bed55a2348828478b7da3@141.95.124.154:26656,1de2abae74a4c5fd7d96d9869ef02187f81498f0@134.209.238.66:26656,ea6ec9ba3f431e47c7baf8b07b5c752f0f1777a3@5.189.176.226:26657,c57cb8c929a73edff5cbad63a90d923edcf96913@34.168.39.191:26656,cf94099349980f9593a3f0362c85fe7c6eda8b14@8.219.48.59:26656,de1f980cc59bdb2457202768d4b4d964d783789e@167.235.21.165:26656,e9bf8e034cfb29658d252f81633ab91e9f28df26@143.198.163.38:26656,91089c0911b59f59fe2ec79fdae017f9beefbbfd@65.108.101.158:26656,af77f61922251db5860c98092246089cb4104865@109.74.200.157:26657,f3eaab835c004c3bc7119097de649cf35a14b48d@45.88.106.199:45656,33fd6e5062baedde026514357b6865f1fbc74c4f@185.144.99.15:26656,ac25bdc230944cc20f03913a8dae881c9b5f9c18@3.239.45.125:26656,55e8a3bc20328c23422e93d875db6dfd6d0adbf2@95.217.207.236:26656,789ca5ed1ee43c4fbf1258d1ec62edea5855dd50@20.42.111.34:26656,15d2f1bc2bfaa143388465ea115c59e5ce6e77dc@65.109.39.223:26656,7379f212d15f6256cf3cc452a6e50b787eccc8ec@161.97.102.31:26656"
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.hid-node/config/config.toml
seeds="cd3e4f5b7f5680bbd86a96b38bc122aa46668399@34.171.132.212:26656"
sed -i.bak -e "s/^seeds =.*/seeds = \"$seeds\"/" $HOME/.hid-node/config/config.toml
```

### Pruning (Optional)
```
pruning="custom" && \
pruning_keep_recent="100" && \
pruning_keep_every="0" && \
pruning_interval="10" && \
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" ~/.hid-node/config/app.toml && \
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" ~/.hid-node/config/app.toml && \
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" ~/.hid-node/config/app.toml && \
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" ~/.hid-node/config/app.toml
```

### Indexer (Optional)
```
indexer="null" && \
sed -i -e "s/^indexer *=.*/indexer = \"$indexer\"/" $HOME/.hid-node/config/config.toml
```

### Download addrbook
```
wget -O $HOME/.hid-node/config/addrbook.json "https://raw.githubusercontent.com/elangrr/testnet_guide/main/hypersign/addrbook.json"
```

### Create service file and start the node
```
sudo tee /etc/systemd/system/hid-noded.service > /dev/null <<EOF
[Unit]
Description=hid-noded
After=network-online.target

[Service]
User=$USER
ExecStart=$(which hid-noded) start
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF
sudo systemctl daemon-reload
sudo systemctl enable hid-noded
sudo systemctl restart hid-noded && sudo journalctl -u hid-noded -f -o cat
```

### State-Sync (OPTIONAL)
Sync your node in minutes
```
sudo systemctl stop hid-noded

SNAP_RPC=http://38.242.199.93:24657
peers="a3e3e20528604b26b792055be84e3fd4de70533b@38.242.199.93:24656"
sed -i.bak -e  "s/^persistent_peers *=.*/persistent_peers = \"$peers\"/" ~/.hid-node/config/config.toml
LATEST_HEIGHT=$(curl -s $SNAP_RPC/block | jq -r .result.block.header.height); \
BLOCK_HEIGHT=$((LATEST_HEIGHT - 500)); \
TRUST_HASH=$(curl -s "$SNAP_RPC/block?height=$BLOCK_HEIGHT" | jq -r .result.block_id.hash)

echo $LATEST_HEIGHT $BLOCK_HEIGHT $TRUST_HASH

sed -i.bak -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1true| ; \
s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"$SNAP_RPC,$SNAP_RPC\"| ; \
s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1$BLOCK_HEIGHT| ; \
s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"| ; \
s|^(seeds[[:space:]]+=[[:space:]]+).*$|\1\"\"|" $HOME/.hid-node/config/config.toml

hid-noded tendermint unsafe-reset-all --home /root/.hid-node --keep-addr-book
systemctl restart hid-noded && journalctl -u hid-noded -f -o cat
```


### Create validator
After your node is synced, create validator

To check if your node is synced simply run
`curl http://localhost:26657/status sync_info "catching_up": false`

```
hid-noded tx staking create-validator \
 --amount=1000000uhid \
 --pubkey=$(hid-noded tendermint show-validator) \
 --moniker="<moniker>" \
 --chain-id="jagrat" \
 --from=<wallet> \
 --commission-rate=0.05 \
 --commission-max-rate=0.2 \
 --commission-max-change-rate=0.05 \
 --min-self-delegation=1 \
--gas=auto
```
Change `<wallet>` and `<moniker>` 


## Usefull commands
### Service management
Check logs
```
journalctl -fu hid-noded -o cat
```

Start service
```
sudo systemctl start hid-noded
```

Stop service
```
sudo systemctl stop hid-noded
```

Restart service
```
sudo systemctl restart hid-noded
```

### Node info
Synchronization info
```
hid-noded status 2>&1 | jq .SyncInfo
```

Validator info
```
hid-noded status 2>&1 | jq .ValidatorInfo
```

Node info
```
hid-noded status 2>&1 | jq .NodeInfo
```

Show node id
```
hid-noded tendermint show-node-id
```

### Wallet operations
List of wallets
```
hid-noded keys list
```

Recover wallet
```
hid-noded keys add <wallet> --recover
```

Delete wallet
```
hid-noded keys delete <wallet>
```

Get wallet balance
```
hid-noded query bank balances <address>
```

Transfer funds
```
hid-noded tx bank send <FROM ADDRESS> <TO_HYPERSIGN_WALLET_ADDRESS> 10000000uhid
```

### Voting
```
hid-noded tx gov vote 1 yes --from <wallet> --chain-id=jagrat
```

### Staking, Delegation and Rewards
Delegate stake
```
hid-noded tx staking delegate <hypersign valoper> 10000000uhid --from=<wallet> --chain-id=jagrat --gas=auto
```

Redelegate stake from validator to another validator
```
hid-noded tx staking redelegate <srcValidatorAddress> <destValidatorAddress> 10000000uhid --from=<wallet> --chain-id=jagrat --gas=auto
```

Withdraw all rewards
```
hid-noded tx distribution withdraw-all-rewards --from=<wallet> --chain-id=jagrat --gas=auto
```

Withdraw rewards with commision
```
hid-noded tx distribution withdraw-rewards <hypersign valoper> --from=<wallet> --commission --chain-id=jagrat
```

### Validator management
Edit validator
```
hid-noded tx staking edit-validator \
  --moniker=<moniker> \
  --identity=<your_keybase_id> \
  --website="<your_website>" \
  --details="<your_validator_description>" \
  --chain-id=jagrat \
  --from=<wallet>
```

Unjail validator
```
hid-noded tx slashing unjail \
  --broadcast-mode=block \
  --from=<wallet> \
  --chain-id=jagrat \
  --gas=auto
```

### Delete node
```
sudo systemctl stop hid-noded && \
sudo systemctl disable hid-noded && \
rm /etc/systemd/system/hid-noded.service && \
sudo systemctl daemon-reload && \
cd $HOME && \
rm -rf .hid-node && \
rm -rf $(which hid-noded)
```




















