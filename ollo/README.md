<a href="https://discord.gg/j4AcXqqr8P" target="_blank">Join our discord <img src="https://user-images.githubusercontent.com/50621007/176236430-53b0f4de-41ff-41f7-92a1-4233890a90c8.png" width="30"/></a>
<a href="https://indonode.dev/" target="_blank">Visit our website <img src="https://avatars.githubusercontent.com/u/34649601?v=4" width="30"/></a>
<a href="https://discord.gg/d4wbfZCtTG" target="_blank">Join OLLO Discord <img src="https://user-images.githubusercontent.com/50621007/176236430-53b0f4de-41ff-41f7-92a1-4233890a90c8.png" width="30"/></a>
  
![image](https://user-images.githubusercontent.com/34649601/193186845-aacfef1b-6091-4f61-bea7-9f2d9c698f7d.png)

# Ollo Testnet validator guide

## Setting up Vars
```
NODENAME=<YOUR MONIKER>
```
Change `<YOUR MONIKER>`

Save and Import variable into the system
```
echo "export NODENAME=$NODENAME" >> $HOME/.bash_profile
if [ ! $WALLET ]; then
	echo "export WALLET=wallet" >> $HOME/.bash_profile
fi
echo "export OLLO_CHAIN_ID=ollo-testnet-0" >> $HOME/.bash_profile
source $HOME/.bash_profile
```

## Minimum System Requirements
- 8vCPU
- 16GB Ram
- 160 of Storage
- Internet Connection

## Installing Depencies
```
sudo apt update && sudo apt upgrade -y
sudo apt install curl tar wget clang pkg-config libssl-dev jq build-essential bsdmainutils git make ncdu gcc git jq chrony liblz4-tool -y
```

## Install GO 
```
cd $HOME
ver="1.18.5"
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
rm "go$ver.linux-amd64.tar.gz"
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> $HOME/.bash_profile
source $HOME/.bash_profile
go version
```

## Install Binary
```
git clone https://github.com/OLLO-Station/ollo
cd ollo
make install
```
Check OLLO Version
`ollod version` , should be latest

## Init
```
ollod init $NODENAME --chain-id $OLLO_CHAIN_ID
```


## Create your wallet
To create new Wallet use the command below 
```
ollod keys add $WALLET
```

To recover your existing wallet (OPTIONAL) run the command below
```
ollod keys add $WALLET --recover
```

## Save Wallet Info
```
OLLO_WALLET_ADDRESS=$(ollod keys show $WALLET -a)
OLLO_VALOPER_ADDRESS=$(ollod keys show $WALLET --bech val -a)
echo 'export OLLO_WALLET_ADDRESS='${OLLO_WALLET_ADDRESS} >> $HOME/.bash_profile
echo 'export OLLO_VALOPER_ADDRESS='${OLLO_VALOPER_ADDRESS} >> $HOME/.bash_profile
source $HOME/.bash_profile
```

## Download Genesis file
```
wget -O $HOME/.ollo/config/genesis.json https://raw.githubusercontent.com/elangrr/testnet_guide/main/ollo/genesis.json
```

check the genesis `sha256sum $HOME/.ollo/config/genesis.json` , the output should be :
`edd83397147598bd203996bd3c4495c1249291a24376028174c32e8bad862f2d`

## Set Minimum gas price / Seeds / filter peers / and max peers
```
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0utollo\"/" $HOME/.ollo/config/app.toml
sed -i -e "s/^filter_peers *=.*/filter_peers = \"true\"/" $HOME/.ollo/config/config.toml
external_address=$(wget -qO- eth0.me) 
sed -i.bak -e "s/^external_address *=.*/external_address = \"$external_address:26656\"/" $HOME/.ollo/config/config.toml
peers="06658ccd5c119578fb662633234a2ef154881b94@172.31.19.104:26656"
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$peers\"/" $HOME/.ollo/config/config.toml
seeds=""
sed -i.bak -e "s/^seeds =.*/seeds = \"$seeds\"/" $HOME/.ollo/config/config.toml
sed -i 's/max_num_inbound_peers =.*/max_num_inbound_peers = 100/g' $HOME/.ollo/config/config.toml
sed -i 's/max_num_outbound_peers =.*/max_num_outbound_peers = 100/g' $HOME/.ollo/config/config.toml
```

## Prunning and Indexer (OPTIONAL)
Prunning :
```
pruning="custom" && \
pruning_keep_recent="100" && \
pruning_keep_every="0" && \
pruning_interval="10" && \
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" ~/.ollo/config/app.toml && \
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" ~/.ollo/config/app.toml && \
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" ~/.ollo/config/app.toml && \
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" ~/.ollo/config/app.toml
```
Indexer :
```
indexer="null" && \
sed -i -e "s/^indexer *=.*/indexer = \"$indexer\"/" $HOME/.ollo/config/config.toml
```

## Download AddrBook.json
```
wget -O $HOME/.ollo/config/addrbook.json "https://raw.githubusercontent.com/elangrr/testnet_guide/main/ollo/addrbook.json"
```

## State-Sync (OPTIONAL)
Sync your node in minutes
```
SNAP_RPC=213.239.217.52:35657
peers="3c0104dae0eb6266432b5aef6af1f2a83300d824@213.239.217.52:35656"
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$peers\"/" $HOME/.ollo/config/config.toml
LATEST_HEIGHT=$(curl -s $SNAP_RPC/block | jq -r .result.block.header.height); \
BLOCK_HEIGHT=$((LATEST_HEIGHT - 500)); \
TRUST_HASH=$(curl -s "$SNAP_RPC/block?height=$BLOCK_HEIGHT" | jq -r .result.block_id.hash)

echo $LATEST_HEIGHT $BLOCK_HEIGHT $TRUST_HASH

sed -i.bak -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1true| ; \
s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"$SNAP_RPC,$SNAP_RPC\"| ; \
s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1$BLOCK_HEIGHT| ; \
s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"| ; \
s|^(seeds[[:space:]]+=[[:space:]]+).*$|\1\"\"|" $HOME/.ollo/config/config.toml
ollod tendermint unsafe-reset-all --home $HOME/.ollo --keep-addr-book
systemctl restart ollod && journalctl -u ollod -f -o cat
```
### Turn off state-sync after synced
```
sed -i.bak -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1false|" $HOME/.ollo/config/config.toml
```

## Create and start your service
```
sudo tee /etc/systemd/system/ollod.service > /dev/null <<EOF
[Unit]
Description=ollo
After=network-online.target

[Service]
User=$USER
ExecStart=$(which ollod) start
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable ollod
sudo systemctl restart ollod && sudo journalctl -u ollod -f -o cat
```

## Create your validator
```
ollod tx staking create-validator \
--amount=50000000utollo \
--pubkey=$(ollod tendermint show-validator) \
--moniker=$NODENAME \
--chain-id=$OLLO_CHAIN_ID \
--commission-rate="0.10" \
--commission-max-rate="0.20" \
--commission-max-change-rate="0.1" \
--min-self-delegation="1" \
--from=$WALLET \
--identity="" \
--details="" \
--website="" \
```

## Delete your node ( DONT FORGET TO BACKUP )
```
sudo systemctl stop ollod && \
sudo systemctl disable ollod && \
rm /etc/systemd/system/ollod.service && \
sudo systemctl daemon-reload && \
cd $HOME && \
rm -rf ollo && \
rm -rf .ollo && \
rm -rf $(which ollod)
```

