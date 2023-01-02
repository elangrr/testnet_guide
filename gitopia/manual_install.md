<p style="font-size:14px" align="right">
<a href="https://github.com/elangrr/testnet_guide" target="_blank">More Guide Tutorials<img src="https://avatars.githubusercontent.com/u/34649601?v=4" width="30"/></a>
</p>

<p style="font-size:14px" align="right">
<a href="https://indonode.dev/" target="_blank">Visit my website <img src="https://avatars.githubusercontent.com/u/34649601?v=4" width="30"/></a>
</p>

<p align="center">
 <img height="200" height="auto" src="https://user-images.githubusercontent.com/34649601/210251979-8dfab2c0-e9dd-4d62-81ae-8e78e24f2209.png">


# Official Links
### [Official Document](https://docs.gitopia.com/validator-overview)
### [Gitopia Official Discord](https://discord.gg/ytz9jtwa2E)

# Explorer
### [Explorer](https://explorer.planq.network/gitopia-janus-testnet-2/staking)

## Minimum Requirements 
- 4 or more physical CPU cores
- At least 160GB of SSD disk storage
- At least 8GB of memory (RAM)
- At least 120mbps network bandwidth


# Manual Install Node Guide with custom port 16

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
     ver="1.19"
     cd $HOME
     wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz"
     sudo rm -rf /usr/local/go
     sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
     rm "go$ver.linux-amd64.tar.gz"
     echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> ~/.bash_profile
     source ~/.bash_profile
fi
```

### Download Git Remote Gitopia
```
curl https://get.gitopia.com | bash
``` 

`If you are facing an error saying` : `mv: rename ./git-remote-gitopia to /usr/local/bin/git-remote-gitopia: Permission denied ============ Error: mv failed`

Run this command 
```
sudo mv /tmp/tmpinstalldir/git-remote-gitopia /usr/local/bin/
``` 
  
### Download binaries
```
cd $HOME
rm -rf gitopia
git clone gitopia://gitopia/gitopia
cd gitopia
```
Build Binaries
```
git checkout v1.2.0
make build
mkdir -p $HOME/.gitopia/cosmovisor/genesis/bin
mv build/gitopiad $HOME/.gitopia/cosmovisor/genesis/bin/
rm -rf build
```

### Download Cosmovisor
```
curl -Ls https://github.com/cosmos/cosmos-sdk/releases/download/cosmovisor%2Fv1.3.0/cosmovisor-v1.3.0-linux-amd64.tar.gz | tar xz
chmod 755 cosmovisor
sudo mv cosmovisor /usr/bin/cosmovisor
```
  
### Config
```
gitopiad config chain-id gitopia-janus-testnet-2
gitopiad config keyring-backend file
gitopiad config node tcp://localhost:16657
```

### Init 
```
gitopiad init $MONIKER --chain-id gitopia-janus-testnet-2
```

### Download genesis file and addrbook
```

```

### Set minimum gas price , seeds , and peers
```
SEEDS="3f472746f46493309650e5a033076689996c8881@gitopia-testnet.rpc.kjnodes.com:41659,399d4e19186577b04c23296c4f7ecc53e61080cb@seed.gitopia.com:26656" 
PEERS=""
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.gitopia/config/config.toml
sed -i -e "s|^minimum-gas-prices *=.*|minimum-gas-prices = \"0.001utlore\"|" $HOME/.gitopia/config/app.toml
```

### Pruning (Optional)
```
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="19"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.gitopia/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.gitopia/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.gitopia/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.gitopia/config/app.toml
```

### Indexer (Optional)
```
indexer="null" && \
sed -i -e "s/^indexer *=.*/indexer = \"$indexer\"/" $HOME/.gitopia/config/config.toml
```

### Custom Port 
```
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:16658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:16657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:16060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:16656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \"16660\"%" $HOME/.gitopia/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:1617\"%; s%^address = \":8080\"%address = \":1680\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:1690\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:1691\"%; s%^address = \"0.0.0.0:8545\"%address = \"0.0.0.0:1645\"%; s%^ws-address = \"0.0.0.0:8546\"%ws-address = \"0.0.0.0:1646\"%" $HOME/.gitopia/config/app.toml
```

### Create service file and start the node
```
sudo tee /etc/systemd/system/gitopiad.service > /dev/null << EOF
[Unit]
Description=gitopia-testnet node service
After=network-online.target
[Service]
User=$USER
ExecStart=/usr/bin/cosmovisor run start
Restart=on-failure
RestartSec=10
LimitNOFILE=65535
Environment="DAEMON_HOME=$HOME/.gitopia"
Environment="DAEMON_NAME=gitopiad"
Environment="UNSAFE_SKIP_BACKUP=true"
[Install]
WantedBy=multi-user.target
EOF
    
sudo systemctl daemon-reload
sudo systemctl enable gitopiad
```

Create Synlinks
```
ln -s $HOME/.gitopia/cosmovisor/genesis $HOME/.gitopia/cosmovisor/current
sudo ln -s $HOME/.gitopia/cosmovisor/current/bin/gitopiad /usr/local/bin/gitopiad
```

Start Cosmovisor
```
sudo systemctl restart gitopiad && sudo journalctl -u gitopiad -f -o cat
```

### Create wallet
To create new wallet use 
```
gitopiad keys add wallet
```
Change `wallet` to your wallet name

To recover existing keys use 
```
gitopiad keys add wallet --recover
```
Change `wallet` to your wallet name

To see current keys 
```
gitopiad keys list
```

### Snapshot
```
SOON
```

### Create validator
After your node is synced, create validator

To check if your node is synced simply run
`curl http://localhost:16657/status sync_info "catching_up": false`

Creating validator with `10 gitopia` change the value as you like

```
gitopiad tx staking create-validator \
--amount=1000000utlore \
--pubkey=$(gitopiad tendermint show-validator) \
--moniker="YOUR_MONIKER_NAME" \
--identity="YOUR_KEYBASE_ID" \
--details="YOUR_DETAILS" \
--website="YOUR_WEBSITE_URL" \
--chain-id=gitopia-janus-testnet-2 \
--commission-rate=0.05 \
--commission-max-rate=0.20 \
--commission-max-change-rate=0.01 \
--min-self-delegation=1 \
--from=wallet \
--gas-adjustment=1.4 \
--gas=auto \
--gas-prices=0.001utlore \
-y
```

## Usefull commands
### Service management
Check logs
```
journalctl -fu gitopiad -o cat
```

Start service
```
sudo systemctl start gitopiad
```

Stop service
```
sudo systemctl stop gitopiad
```

Restart service
```
sudo systemctl restart gitopiad
```

### Node info
Synchronization info
```
gitopiad status 2>&1 | jq .SyncInfo
```

Validator info
```
gitopiad status 2>&1 | jq .ValidatorInfo
```

Node info
```
gitopiad status 2>&1 | jq .NodeInfo
```

Show node id
```
gitopiad tendermint show-node-id
```

Get Node Peer
```
echo $(gitopiad tendermint show-node-id)'@'$(curl -s ifconfig.me)':'$(cat $HOME/.gitopia/config/config.toml | sed -n '/Address to listen for incoming connection/{n;p;}' | sed 's/.*://; s/".*//')
```

Get Live Peer
```
curl -sS http://localhost:16657/net_info | jq -r '.result.peers[] | "\(.node_info.id)@\(.remote_ip):\(.node_info.listen_addr)"' | awk -F ':' '{print $1":"$(NF)}'
```

### Wallet operations
List of wallets
```
gitopiad keys list
```

Recover wallet
```
gitopiad keys add wallet --recover
```

Delete wallet
```
gitopiad keys delete wallet
```

Get wallet balance
```
gitopiad query bank balances <address>
```

Transfer funds
```
gitopiad tx bank send <FROM ADDRESS> <TO_gitopia_WALLET_ADDRESS> 10000000utlore
```

### Voting
```
gitopiad tx gov vote 1 yes --from wallet --chain-id=gitopia-janus-testnet-2
```

### Staking, Delegation and Rewards
Delegate Stake to your own validator
```
gitopiad tx staking delegate $(gitopiad keys show wallet --bech val -a) 1000000utlore --from wallet --chain-id gitopia-janus-testnet-2 --gas-adjustment 1.4 --gas auto --gas-prices 0.001utlore -y
```

Delegate stake
```
gitopiad tx staking delegate <gitopia valoper> 10000000utlore --from=wallet --chain-id=gitopia-janus-testnet-2 --gas=auto
```

Redelegate stake from validator to another validator
```
gitopiad tx staking redelegate <srcValidatorAddress> <destValidatorAddress> 10000000utlore --from=wallet --chain-id=gitopia-janus-testnet-2 --gas=auto
```

Withdraw all rewards
```
gitopiad tx distribution withdraw-all-rewards --from=wallet --chain-id=gitopia-janus-testnet-2 --gas=auto
```

Withdraw rewards with commision
```
gitopiad tx distribution withdraw-rewards <gitopia valoper> --from=wallet --commission --chain-id=gitopia-janus-testnet-2
```

### Validator management
Edit validator
```
gitopiad tx staking edit-validator \
  --moniker=$MONIKER \
  --identity=<your_keybase_id> \
  --website="<your_website>" \
  --details="<your_validator_description>" \
  --chain-id=gitopia-janus-testnet-2 \
  --from=wallet
```

Unjail validator
```
gitopiad tx slashing unjail \
  --broadcast-mode=block \
  --from=wallet \
  --chain-id=gitopia-janus-testnet-2 \
  --gas=auto
```

### Delete node
```
sudo systemctl stop gitopiad && \
sudo systemctl disable gitopiad && \
rm /etc/systemd/system/gitopiad.service && \
sudo systemctl daemon-reload && \
cd $HOME && \
rm -rf .gitopia && \
rm -rf $(which gitopiad)
```




















