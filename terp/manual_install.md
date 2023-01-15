<p style="font-size:14px" align="right">
<a href="https://hetzner.cloud/?ref=tmLum9o8NxAI" target="_blank">Deploy your VPS using our referral link to get 20€ bonus <img src="https://user-images.githubusercontent.com/50621007/174612278-11716b2a-d662-487e-8085-3686278dd869.png" width="30"/></a>
</p>

<p style="font-size:14px" align="right">
<a href="https://github.com/elangrr/testnet_guide" target="_blank">More Guide Tutorials<img src="https://avatars.githubusercontent.com/u/34649601?v=4" width="30"/></a>
</p>

<p style="font-size:14px" align="right">
<a href="https://indonode.dev/" target="_blank">Visit my website <img src="https://avatars.githubusercontent.com/u/34649601?v=4" width="30"/></a>

<p align="center">
 <img height="200" height="auto" src="https://user-images.githubusercontent.com/34649601/212522416-fb05a26b-b81b-4c10-9e1d-43c4965db650.png">


# Official Links
### [Official Document](https://docs.terp.network/)
### [Terp Official Discord](https://discord.gg/qFfUyNZnPG)

# Explorer
### [Explorer](https://explorer.indonode.dev/terp/staking)

## Minimum Requirements 
- 3 or more physical CPU cores
- At least 160GB of SSD disk storage
- At least 4GB of memory (RAM)
- At least 120mbps network bandwidth


# Manual Install Node Guide with custom port 32

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
  
### Download binary
```
cd || return
rm -rf terp-core
git clone https://github.com/terpnetwork/terp-core.git
cd terp-core || return
git checkout v0.2.0
```

### Build Binary  
```
make build
sudo mkdir -p $HOME/.terp/cosmovisor/genesis/bin
sudo mv build/terpd $HOME/.terp/cosmovisor/genesis/bin/
```

### Config
```
terpd config keyring-backend test
terpd config chain-id athena-3
terpd config node tcp://localhost:32657
```
### Init
```
terpd init "MONIKER" --chain-id athena-3
```

### Download Cosmovisor
```
go install cosmossdk.io/tools/cosmovisor/cmd/cosmovisor@v1.4.0
```
  
### Download genesis file and addrbook
```
wget -O $HOME/.terp/config/addrbook.json "https://raw.githubusercontent.com/elangrr/testnet_guide/main/terp/addrbook.json"
wget -O $HOME/.terp/config/genesis.json "https://raw.githubusercontent.com/elangrr/testnet_guide/main/terp/genesis.json"
```

### Set minimum gas price , seeds , and peers
```
peers=""
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$peers\"/" $HOME/.terp/config/config.toml
seeds=""
sed -i.bak -e "s/^seeds =.*/seeds = \"$seeds\"/" $HOME/.terp/config/config.toml
sed -i -e "s/^filter_peers *=.*/filter_peers = \"true\"/" $HOME/.terp/config/config.toml
sed -i 's/max_num_inbound_peers =.*/max_num_inbound_peers = 100/g' $HOME/.terp/config/config.toml
sed -i 's/max_num_outbound_peers =.*/max_num_outbound_peers = 100/g' $HOME/.terp/config/config.toml
sed -i -e "s|^minimum-gas-prices *=.*|minimum-gas-prices = \"0.001upersyx\"|" $HOME/.terp/config/app.toml
```

### Pruning (Optional)
```
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="19"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.terp/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.terp/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.terp/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.terp/config/app.toml
```

### Indexer (Optional)
```
indexer="null" && \
sed -i -e "s/^indexer *=.*/indexer = \"$indexer\"/" $HOME/.terp/config/config.toml
```

### Custom Port 
```
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:32658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:32657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:32060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:32656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \"32660\"%" $HOME/.terp/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:3217\"%; s%^address = \":8080\"%address = \":3280\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:3290\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:3291\"%; s%^address = \"0.0.0.0:8545\"%address = \"0.0.0.0:3245\"%; s%^ws-address = \"0.0.0.0:8546\"%ws-address = \"0.0.0.0:3246\"%" $HOME/.terp/config/app.toml
```

### Create service file and start the node
```
sudo tee /etc/systemd/system/terpd.service > /dev/null << EOF
[Unit]
Description=terp-testnet node service
After=network-online.target
[Service]
User=$USER
ExecStart=$(which cosmovisor) run start
Restart=on-failure
RestartSec=10
LimitNOFILE=65535
Environment="DAEMON_HOME=$HOME/.terp"
Environment="DAEMON_NAME=terpd"
Environment="UNSAFE_SKIP_BACKUP=true"
[Install]
WantedBy=multi-user.target
EOF
    
sudo systemctl daemon-reload
sudo systemctl enable terpd
```

Create Symlinks
```
sudo ln -s $HOME/.terp/cosmovisor/genesis $HOME/.terp/cosmovisor/current
sudo ln -s $HOME/.terp/cosmovisor/current/bin/terpd /usr/local/bin/terpd
```

Start Cosmovisor
```
sudo systemctl restart terpd && sudo journalctl -u terpd -f -o cat
```

### Create wallet
To create new wallet use 
```
terpd keys add wallet
```
Change `wallet` to your wallet name

To recover existing keys use 
```
terpd keys add wallet --recover
```
Change `wallet` to your wallet name

To see current keys 
```
terpd keys list
```

### Snapshot
```
sudo apt update
sudo apt install snapd -y
sudo snap install lz4
   
sudo systemctl stop terpd
	cp $HOME/.terp/data/priv_validator_state.json $HOME/.terp/priv_validator_state.json.backup
	rm -rf $HOME/.terp/data

	curl -L https://snapshot.terp.indonode.net/terp-snapshot-2023-01-15.tar.lz4 | lz4 -dc - | tar -xf - -C $HOME/.terp
	mv $HOME/.terp/priv_validator_state.json.backup $HOME/.terp/data/priv_validator_state.json

	sudo systemctl restart terpd && journalctl -u terpd -f --no-hostname -o cat
```

### Faucet
Seek faucet in Discord 

  
### Create validator
After your node is synced, create validator

To check if your node is synced simply run
`curl http://localhost:32657/status sync_info "catching_up": false`

Creating validator 

```
terpd tx staking create-validator \
--amount=1000000uterpx \
--pubkey=$(terpd tendermint show-validator) \
--moniker="$MONIKER" \
--chain-id=athena-3 \
--commission-rate=0.1 \
--commission-max-rate=0.2 \
--commission-max-change-rate=0.05 \
--min-self-delegation=1 \
--from=wallet \
--identity= \
--details="" \
--website="" \
--gas-adjustment=1.4 \
--gas=auto \
--gas-prices=0.001upersyx \
-y
```

## Usefull commands
### Service management
Check logs
```
journalctl -fu terpd -o cat
```

Start service
```
sudo systemctl start terpd
```

Stop service
```
sudo systemctl stop terpd
```

Restart service
```
sudo systemctl restart terpd
```

### Node info
Synchronization info
```
terpd status 2>&1 | jq .SyncInfo
```

Validator info
```
terpd status 2>&1 | jq .ValidatorInfo
```

Node info
```
terpd status 2>&1 | jq .NodeInfo
```

Show node id
```
terpd tendermint show-node-id
```

Get Node Peer
```
echo $(terpd tendermint show-node-id)'@'$(curl -s ifconfig.me)':'$(cat $HOME/.terp/config/config.toml | sed -n '/Address to listen for incoming connection/{n;p;}' | sed 's/.*://; s/".*//')
```

Get Live Peer
```
curl -sS http://localhost:32657/net_info | jq -r '.result.peers[] | "\(.node_info.id)@\(.remote_ip):\(.node_info.listen_addr)"' | awk -F ':' '{print $1":"$(NF)}'
```

### Wallet operations
List of wallets
```
terpd keys list
```

Recover wallet
```
terpd keys add wallet --recover
```

Delete wallet
```
terpd keys delete wallet
```

Get wallet balance
```
terpd query bank balances <address>
```

Transfer funds
```
terpd tx bank send <FROM ADDRESS> <TO_terp_WALLET_ADDRESS> 10000000upersyx
```

### Voting
```
terpd tx gov vote 1 yes --from wallet --chain-id=athena-3
```

### Staking, Delegation and Rewards
Delegate Stake to your own validator
```
terpd tx staking delegate $(terpd keys show wallet --bech val -a) 1000000upersyx --from wallet --chain-id athena-3 --gas-adjustment 1.4 --gas auto --gas-prices 0.001upersyx -y
```

Delegate stake
```
terpd tx staking delegate <terp valoper> 10000000upersyx --from=wallet --chain-id=athena-3 --gas=auto
```

Redelegate stake from validator to another validator
```
terpd tx staking redelegate <srcValidatorAddress> <destValidatorAddress> 10000000upersyx --from=wallet --chain-id=athena-3 --gas=auto
```

Withdraw all rewards
```
terpd tx distribution withdraw-all-rewards --from=wallet --chain-id=athena-3 --gas=auto
```

Withdraw rewards with commision
```
terpd tx distribution withdraw-rewards <terp valoper> --from=wallet --commission --chain-id=athena-3
```

### Validator management
Edit validator
```
terpd tx staking edit-validator \
  --moniker=$MONIKER \
  --identity=<your_keybase_id> \
  --website="<your_website>" \
  --details="<your_validator_description>" \
  --chain-id=athena-3 \
  --from=wallet
```

Unjail validator
```
terpd tx slashing unjail \
  --broadcast-mode=block \
  --from=wallet \
  --chain-id=athena-3 \
  --gas=auto
```

### Delete node
```
sudo systemctl stop terpd && \
sudo systemctl disable terpd && \
rm /etc/systemd/system/terpd.service && \
sudo systemctl daemon-reload && \
cd $HOME && \
rm -rf .terp && \
rm -rf $(which terpd)
rm -rf terp
```




















