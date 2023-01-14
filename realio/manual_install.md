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
 <img height="200" height="auto" src="https://user-images.githubusercontent.com/34649601/212465601-af700240-f0a6-4fff-95ab-39d6fda3e8c0.png">

# Official Links
### [Official Document](https://docs.realio.network/validators/setup)
### [Realio Official Discord](https://discord.gg/YeAfZnd7dm)

# Explorer
### [Explorer](https://explorer.indonode.dev/realio/staking)

## Minimum Requirements 
- 2 or more physical CPU cores
- At least 160GB of SSD disk storage
- At least 4GB of memory (RAM)
- At least 120mbps network bandwidth


# Manual Install Node Guide with custom port 18

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
git clone https://github.com/realiotech/realio-network.git && cd realio-network
git checkout v0.6.3
```
Build Binaries
```
make build
mkdir -p $HOME/.realio-network/cosmovisor/genesis/bin
mv build/realio-networkd $HOME/.realio-network/cosmovisor/genesis/bin/
rm -rf build
```

### Download Cosmovisor
```
go install cosmossdk.io/tools/cosmovisor/cmd/cosmovisor@v1.4.0
```
  
### Config
```
realio-networkd config chain-id realionetwork_1110-2
realio-networkd config keyring-backend test
realio-networkd config node tcp://localhost:18657
```

### Init 
```
realio-networkd init $MONIKER --chain-id realionetwork_1110-2
```

### Download genesis file and addrbook
```
wget -O $HOME/.realio-network/config/addrbook.json "https://raw.githubusercontent.com/elangrr/testnet_guide/main/realio/addrbook.json"
wget -O $HOME/.realio-network/config/genesis.json "https://raw.githubusercontent.com/elangrr/testnet_guide/main/realio/genesis.json"
```

### Set minimum gas price , seeds , and peers
```
peers=""
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$peers\"/" $HOME/.realio-network/config/config.toml
seeds="aa194e9f9add331ee8ba15d2c3d8860c5a50713f@143.110.230.177:26656"
sed -i.bak -e "s/^seeds =.*/seeds = \"$seeds\"/" $HOME/.realio-network/config/config.toml
sed -i 's/max_num_inbound_peers =.*/max_num_inbound_peers = 100/g' $HOME/.realio-network/config/config.toml
sed -i 's/max_num_outbound_peers =.*/max_num_outbound_peers = 100/g' $HOME/.realio-network/config/config.toml
sed -i -e "s|^minimum-gas-prices *=.*|minimum-gas-prices = \"0.0ario\"|" $HOME/.realio-network/config/app.toml
```

### Pruning (Optional)
```
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="19"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.realio-network/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.realio-network/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.realio-network/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.realio-network/config/app.toml
```

### Indexer (Optional)
```
indexer="null" && \
sed -i -e "s/^indexer *=.*/indexer = \"$indexer\"/" $HOME/.realio-network/config/config.toml
```

### Custom Port 
```
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:18658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:18657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:18060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:18656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \"18660\"%" $HOME/.realio-network/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:1817\"%; s%^address = \":8080\"%address = \":1880\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:1890\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:1891\"%; s%^address = \"0.0.0.0:8545\"%address = \"0.0.0.0:1845\"%; s%^ws-address = \"0.0.0.0:8546\"%ws-address = \"0.0.0.0:1846\"%" $HOME/.realio-network/config/app.toml
```

### Create service file and start the node
```
sudo tee /etc/systemd/system/realio-networkd.service > /dev/null << EOF
[Unit]
Description=realio-testnet node service
After=network-online.target
[Service]
User=$USER
ExecStart=$(which cosmovisor) run start
Restart=on-failure
RestartSec=10
LimitNOFILE=65535
Environment="DAEMON_HOME=$HOME/.realio-network"
Environment="DAEMON_NAME=realio-networkd"
Environment="UNSAFE_SKIP_BACKUP=true"
[Install]
WantedBy=multi-user.target
EOF
    
sudo systemctl daemon-reload
sudo systemctl enable realio-networkd
```

Create Symlinks
```
sudo ln -s $HOME/.realio-network/cosmovisor/genesis $HOME/.realio-network/cosmovisor/current
sudo ln -s $HOME/.realio-network/cosmovisor/current/bin/realio-networkd /usr/local/bin/realio-networkd
```

Start Cosmovisor
```
sudo systemctl restart realio-networkd && sudo journalctl -u realio-networkd -f -o cat
```

### Create wallet
To create new wallet use 
```
realio-networkd keys add wallet
```
Change `wallet` to your wallet name

To recover existing keys use 
```
realio-networkd keys add wallet --recover
```
Change `wallet` to your wallet name

To see current keys 
```
realio-networkd keys list
```

### Snapshot (SOON)
```
sudo apt update
sudo apt install snapd -y
sudo snap install lz4
   
sudo systemctl stop realio-networkd
	cp $HOME/.realio-network/data/priv_validator_state.json $HOME/.realio-network/priv_validator_state.json.backup
	rm -rf $HOME/.realio-network/data

	curl -L https://snapshot.realio.indonode.net/realio-snapshot-2023-01-14.tar.lz4 | lz4 -dc - | tar -xf - -C $HOME/.realio-network
	mv $HOME/.realio-network/priv_validator_state.json.backup $HOME/.realio-network/data/priv_validator_state.json

	sudo systemctl restart realio-networkd && journalctl -u realio-networkd -f --no-hostname -o cat
```

### Faucet
Ask the admin in discord

  
### Create validator
After your node is synced, create validator

To check if your node is synced simply run
`curl http://localhost:18657/status sync_info "catching_up": false`

Creating validator 

```
realio-networkd tx staking create-validator \
  --amount=1000000000000000000ario \
  --pubkey=$(realio-networkd tendermint show-validator) \
  --moniker="$MONIKER" \
  --chain-id=realionetwork_1110-2 \
  --commission-rate="0.10" \
  --commission-max-rate="0.20" \
  --commission-max-change-rate="0.1" \
  --min-self-delegation="1" \
  --fees 5000000000000000ario \
  --gas 800000 \
  --identity= \
  --website="" \
  --details="" \
  --from=wallet
```

## Usefull commands
### Service management
Check logs
```
journalctl -fu realio-networkd -o cat
```

Start service
```
sudo systemctl start realio-networkd
```

Stop service
```
sudo systemctl stop realio-networkd
```

Restart service
```
sudo systemctl restart realio-networkd
```

### Node info
Synchronization info
```
realio-networkd status 2>&1 | jq .SyncInfo
```

Validator info
```
realio-networkd status 2>&1 | jq .ValidatorInfo
```

Node info
```
realio-networkd status 2>&1 | jq .NodeInfo
```

Show node id
```
realio-networkd tendermint show-node-id
```

Get Node Peer
```
echo $(realio-networkd tendermint show-node-id)'@'$(curl -s ifconfig.me)':'$(cat $HOME/.realio-network/config/config.toml | sed -n '/Address to listen for incoming connection/{n;p;}' | sed 's/.*://; s/".*//')
```

Get Live Peer
```
curl -sS http://localhost:18657/net_info | jq -r '.result.peers[] | "\(.node_info.id)@\(.remote_ip):\(.node_info.listen_addr)"' | awk -F ':' '{print $1":"$(NF)}'
```

### Wallet operations
List of wallets
```
realio-networkd keys list
```

Recover wallet
```
realio-networkd keys add wallet --recover
```

Delete wallet
```
realio-networkd keys delete wallet
```

Get wallet balance
```
realio-networkd query bank balances <address>
```

Transfer funds
```
realio-networkd tx bank send <FROM ADDRESS> <TO_realio_WALLET_ADDRESS> 10000000ario
```

### Voting
```
realio-networkd tx gov vote 1 yes --from wallet --chain-id=realionetwork_1110-2
```

### Staking, Delegation and Rewards
Delegate Stake to your own validator
```
realio-networkd tx staking delegate $(realio-networkd keys show wallet --bech val -a) 1000000ario --from wallet --chain-id realionetwork_1110-2 --gas-adjustment 1.4 --gas auto --gas-prices 0.001ario -y
```

Delegate stake
```
realio-networkd tx staking delegate <realio valoper> 10000000ario --from=wallet --chain-id=realionetwork_1110-2 --gas=auto
```

Redelegate stake from validator to another validator
```
realio-networkd tx staking redelegate <srcValidatorAddress> <destValidatorAddress> 10000000ario --from=wallet --chain-id=realionetwork_1110-2 --gas=auto
```

Withdraw all rewards
```
realio-networkd tx distribution withdraw-all-rewards --from=wallet --chain-id=realionetwork_1110-2 --gas=auto
```

Withdraw rewards with commision
```
realio-networkd tx distribution withdraw-rewards <realio valoper> --from=wallet --commission --chain-id=realionetwork_1110-2
```

### Validator management
Edit validator
```
realio-networkd tx staking edit-validator \
  --moniker=$MONIKER \
  --identity=<your_keybase_id> \
  --website="<your_website>" \
  --details="<your_validator_description>" \
  --chain-id=realionetwork_1110-2 \
  --from=wallet
```

Unjail validator
```
realio-networkd tx slashing unjail \
  --broadcast-mode=block \
  --from=wallet \
  --chain-id=realionetwork_1110-2 \
  --gas=auto
```

### Delete node
```
sudo systemctl stop realio-networkd && \
sudo systemctl disable realio-networkd && \
rm /etc/systemd/system/realio-networkd.service && \
sudo systemctl daemon-reload && \
cd $HOME && \
rm -rf .realio-network && \
rm -rf $(which realio-networkd)
rm -rf realio-network
```




















