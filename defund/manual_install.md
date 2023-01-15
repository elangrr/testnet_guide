<p style="font-size:14px" align="right">
<a href="https://github.com/elangrr/testnet_guide" target="_blank">More Guide Tutorials<img src="https://avatars.githubusercontent.com/u/34649601?v=4" width="30"/></a>
</p>

<p style="font-size:14px" align="right">
<a href="https://indonode.dev/" target="_blank">Visit my website <img src="https://avatars.githubusercontent.com/u/34649601?v=4" width="30"/></a>
</p>

<p align="center">
 <img height="200" height="auto" src="https://user-images.githubusercontent.com/50621007/171904810-664af00a-e78a-4602-b66b-20bfd874fa82.png">



# Official Links
### [Official Document](https://github.com/defund-labs/testnet/)
### [Defund Official Discord](https://discord.gg/Rx2gdHmsRn)

# Explorer
### [Indonode Explorer](https://explorer.indonode.dev/defund/staking)

## Minimum Requirements 
- 4 or more physical CPU cores
- At least 100GB of SSD disk storage
- At least 8GB of memory (RAM)
- At least 100mbps network bandwidth

# Manual Install Defund Node Guide with custom port 19

### Set vars
```
MONIKER=$MONIKER
```
Change `$MONIKER` to your moniker
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
ver="1.19.4" && \
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz" && \
sudo rm -rf /usr/local/go && \
sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz" && \
rm "go$ver.linux-amd64.tar.gz" && \
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> $HOME/.bash_profile && \
source $HOME/.bash_profile && \
go version
```

### Download & build binary
```
cd $HOME
rm -rf defund
git clone https://github.com/defund-labs/defund.git
cd defund
git checkout v0.2.2
make build

mkdir -p $HOME/.defund/cosmovisor/genesis/bin
mv build/defundd $HOME/.defund/cosmovisor/genesis/bin/
rm -rf build
```

### Create Symlinks
```
sudo ln -s $HOME/.defund/cosmovisor/genesis $HOME/.defund/cosmovisor/current
sudo ln -s $HOME/.defund/cosmovisor/current/bin/defundd /usr/local/bin/defundd
```

### Config
```
defundd config chain-id defund-private-4
defundd config keyring-backend test
defundd config node tcp://localhost:19657
```

### Init 
```
defundd init $MONIKER --chain-id defund-private-4
```
Change `$MONIKER` to your moniker

### Download Cosmovisor
```
go install cosmossdk.io/tools/cosmovisor/cmd/cosmovisor@v1.4.0
```

### Download genesis file and addrbook
```
wget -O $HOME/.defund/config/addrbook.json "https://raw.githubusercontent.com/elangrr/testnet_guide/main/defund/addrbook.json"
wget -O $HOME/.defund/config/genesis.json "https://raw.githubusercontent.com/elangrr/testnet_guide/main/defund/genesis.json"
```

### Set minimum gas price , seeds , and peers
```
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0ufetf\"/" $HOME/.defund/config/app.toml
SEEDS="3f472746f46493309650e5a033076689996c8881@defund-testnet.rpc.kjnodes.com:40659"
PEERS=""
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.defund/config/config.toml
```

### Pruning (Optional)
```
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="19"
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

### Custom Port 19
```
sed -i -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:19658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:19657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:19060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:19656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":19660\"%" $HOME/.defund/config/config.toml
sed -i -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:19317\"%; s%^address = \":8080\"%address = \":19080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:19090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:19091\"%; s%^address = \"0.0.0.0:8545\"%address = \"0.0.0.0:19545\"%; s%^ws-address = \"0.0.0.0:8546\"%ws-address = \"0.0.0.0:19546\"%" $HOME/.defund/config/app.toml
```

### Create service file and start the node
```
sudo tee /etc/systemd/system/defundd.service > /dev/null << EOF
[Unit]
Description=defund-testnet node service
After=network-online.target

[Service]
User=$USER
ExecStart=$(which cosmovisor) run start
Restart=on-failure
RestartSec=10
LimitNOFILE=65535
Environment="DAEMON_HOME=$HOME/.defund"
Environment="DAEMON_NAME=defundd"
Environment="UNSAFE_SKIP_BACKUP=true"

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable defundd
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

### State-Sync (Not Supported)
Sync your node in minutes
```
```

### Ask for faucet in Discord

### Create validator
After your node is synced, create validator

To check if your node is synced simply run
`curl http://localhost:19657/status sync_info "catching_up": false`

```
defundd tx staking create-validator \
--amount=1000000ufetf \
--pubkey=$(defundd tendermint show-validator) \
--moniker="$MONIKER" \
--identity="" \
--details="" \
--website="" \
--chain-id=defund-private-4 \
--commission-rate=0.1 \
--commission-max-rate=0.20 \
--commission-max-change-rate=0.01 \
--min-self-delegation=1 \
--from=wallet \
--gas-adjustment=1.4 \
--gas=auto \
--gas-prices=0ufetf \
-y
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

Get Node Peer
```
echo $(defundd tendermint show-node-id)'@'$(curl -s ifconfig.me)':'$(cat $HOME/.defund/config/config.toml | sed -n '/Address to listen for incoming connection/{n;p;}' | sed 's/.*://; s/".*//')
```

Get Live Peer
```
curl -sS http://localhost:19657/net_info | jq -r '.result.peers[] | "\(.node_info.id)@\(.remote_ip):\(.node_info.listen_addr)"' | awk -F ':' '{print $1":"$(NF)}'
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
defundd tx gov vote 1 yes --from wallet --chain-id=defund-private-4
```

### Staking, Delegation and Rewards
Delegate Stake to your own validator
```
defundd tx staking delegate $(defundd keys show wallet --bech val -a) 1000000ufetf --from wallet --chain-id defund-private-4 --gas-adjustment 1.4 --gas auto --gas-prices 0.001ufetf -y
```

Delegate stake
```
defundd tx staking delegate <defund valoper> 10000000ufetf --from=wallet --chain-id=defund-private-4 --gas=auto
```

Redelegate stake from validator to another validator
```
defundd tx staking redelegate <srcValidatorAddress> <destValidatorAddress> 10000000ufetf --from=wallet --chain-id=defund-private-4 --gas=auto
```

Withdraw all rewards
```
defundd tx distribution withdraw-all-rewards --from=wallet --chain-id=defund-private-4 --gas=auto
```

Withdraw rewards with commision
```
defundd tx distribution withdraw-rewards <defund valoper> --from=wallet --commission --chain-id=defund-private-4
```

### Validator management
Edit validator
```
defundd tx staking edit-validator \
  --moniker=$MONIKER \
  --identity=<your_keybase_id> \
  --website="<your_website>" \
  --details="<your_validator_description>" \
  --chain-id=defund-private-4 \
  --from=wallet
```

Unjail validator
```
defundd tx slashing unjail \
  --broadcast-mode=block \
  --from=wallet \
  --chain-id=defund-private-4 \
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
rm -rf defund
```
















