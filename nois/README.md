<p style="font-size:14px" align="right">
<a href="https://github.com/elangrr/testnet_guide" target="_blank">More Guide Tutorials<img src="https://avatars.githubusercontent.com/u/34649601?v=4" width="30"/></a>
</p>

<p style="font-size:14px" align="right">
<a href="https://indonode.dev/" target="_blank">Visit my website <img src="https://avatars.githubusercontent.com/u/34649601?v=4" width="30"/></a>
</p>

<p align="center">
 <img height="250" height="auto" src="https://user-images.githubusercontent.com/50621007/194469665-36158a7f-b85b-4048-baa4-87199508d3f0.png">



# Official Links
### [Official Document](https://docs.nois.network/use-cases/for-validators)
### [Nois Official Discord](https://discord.gg/GuVv7Sn796)

# Explorer
[Kjnodes Explorer](https://explorer.kjnodes.com/nois/staking)

## Minimum Requirements 
- 4 or more physical CPU cores
- At least 100GB of SSD disk storage
- At least 8GB of memory (RAM)
- At least 100mbps network bandwidth

# Pre-Installation

Run as Sudo user by type `sudo -i` and open port `26657` and `26656`
```
sudo ufw allow 26657
sudo ufw allow 26656
sudo ufw allow ssh
sudo ufw enable
```

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
git clone https://github.com/noislabs/full-node.git 
cd full-node/full-node/
./build.sh
mv out/noisd usr/local/go/bin/
```

### Config
```
noisd config chain-id nois-testnet-003
noisd config keyring-backend test
```

### Init 
```
noisd init <moniker> --chain-id nois-testnet-003
```
Change `<moniker>` to your moniker

### Create wallet
To create new wallet use 
```
noisd keys add <wallet>
```
Change `<wallet>` to your wallet name

To recover existing keys use 
```
noisd keys add <wallet> --recover
```
Change `<wallet>` to your wallet name

To see current keys 
```
noisd keys list
```

### Donwload genesis
```
wget -qO $HOME/.noisd/config/genesis.json "https://raw.githubusercontent.com/noislabs/testnets/main/nois-testnet-003/genesis.json"
```

### Set peers
```
PEERS="bf5bbdf9ac1ccd72d7b29c3fbcc7e99ff89fd053@node-0.noislabs.com:26656"
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.noisd/config/config.toml
```

### Pruning (Optional)
```
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="50"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.noisd/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.noisd/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.noisd/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.noisd/config/app.toml
```

### Set minimum gas and timeout commit
```
export DENOM=unois
export CONFIG_DIR=$HOME/.noisd/config
sed -i 's/minimum-gas-prices = ""/minimum-gas-prices = "0.05'"${DENOM}"'"/' $CONFIG_DIR/app.toml \
  && sed -i 's/^timeout_propose =.*$/timeout_propose = "2s"/' $CONFIG_DIR/config.toml \
  && sed -i 's/^timeout_propose_delta =.*$/timeout_propose_delta = "500ms"/' $CONFIG_DIR/config.toml \
  && sed -i 's/^timeout_prevote =.*$/timeout_prevote = "1s"/' $CONFIG_DIR/config.toml \
  && sed -i 's/^timeout_prevote_delta =.*$/timeout_prevote_delta = "500ms"/' $CONFIG_DIR/config.toml \
  && sed -i 's/^timeout_precommit =.*$/timeout_precommit = "1s"/' $CONFIG_DIR/config.toml \
  && sed -i 's/^timeout_precommit_delta =.*$/timeout_precommit_delta = "500ms"/' $CONFIG_DIR/config.toml \
  && sed -i 's/^timeout_commit =.*$/timeout_commit = "2s"/' $CONFIG_DIR/config.toml
```

### Reset
```
noisd tendermint unsafe-reset-all --home $HOME/.noisd
```

### Create service and run node
```
sudo tee /etc/systemd/system/noisd.service > /dev/null <<EOF
[Unit]
Description=nois
After=network-online.target

[Service]
User=$USER
ExecStart=$(which noisd) start --home $HOME/.noisd
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable noisd
sudo systemctl restart noisd && sudo journalctl -u noisd -f -o cat
```

### Check sync
```
source $HOME/.bash_profile
noisd status 2>&1 | jq .SyncInfo
```

### Ask for faucet
Go to [Nois Official Discord](https://discord.gg/GuVv7Sn796) and ask faucet in faucet channel


### Create validator
After your node is synced, create validator

To check if your node is synced simply run
`curl http://localhost:26657/status sync_info "catching_up": false`

To check your nois balance
```
noisd query bank balances <nois wallet addr>
```

```
noisd tx staking create-validator \
  --amount 100000000unois \
  --from <wallet> \
  --commission-max-change-rate "0.01" \
  --commission-max-rate "0.2" \
  --commission-rate "0.07" \
  --min-self-delegation "1" \
  --pubkey  $(noisd tendermint show-validator) \
  --moniker <moniker> \
  --chain-id nois-testnet-003
```
Change `<wallet>` and `<moniker>` 


## Usefull comunoiss
### Service management
Check logs
```
journalctl -fu noisd -o cat
```

Start service
```
sudo systemctl start noisd
```

Stop service
```
sudo systemctl stop noisd
```

Restart service
```
sudo systemctl restart noisd
```

### Node info
Synchronization info
```
noisd status 2>&1 | jq .SyncInfo
```

Validator info
```
noisd status 2>&1 | jq .ValidatorInfo
```

Node info
```
noisd status 2>&1 | jq .NodeInfo
```

Show node id
```
noisd tendermint show-node-id
```

### Wallet operations
List of wallets
```
noisd keys list
```

Recover wallet
```
noisd keys add <wallet> --recover
```

Delete wallet
```
noisd keys delete <wallet>
```

Get wallet balance
```
noisd query bank balances <address>
```

Transfer funds
```
noisd tx bank send <FROM ADDRESS> <TO_NOIS_WALLET_ADDRESS> 10000000unois
```

### Voting
```
noisd tx gov vote 1 yes --from <wallet> --chain-id=nois-testnet-003
```

### Staking, Delegation and Rewards
Delegate stake
```
noisd tx staking delegate <noise valoper> 10000000unois --from=<wallet> --chain-id=nois-testnet-003 --gas=auto
```

Redelegate stake from validator to another validator
```
noisd tx staking redelegate <srcValidatorAddress> <destValidatorAddress> 10000000unois --from=<wallet> --chain-id=nois-testnet-003 --gas=auto
```

Withdraw all rewards
```
noisd tx distribution withdraw-all-rewards --from=<wallet> --chain-id=nois-testnet-003 --gas=auto
```

Withdraw rewards with commision
```
noisd tx distribution withdraw-rewards <unoise valoper> --from=<wallet> --commission --chain-id=nois-testnet-003
```

### Validator management
Edit validator
```
noisd tx staking edit-validator \
  --moniker=<moniker> \
  --identity=<your_keybase_id> \
  --website="<your_website>" \
  --details="<your_validator_description>" \
  --chain-id=nois-testnet-003 \
  --from=<wallet>
```

Unjail validator
```
noisd tx slashing unjail \
  --broadcast-mode=block \
  --from=<wallet> \
  --chain-id=nois-testnet-003 \
  --gas=auto
```

### Delete node
```
sudo systemctl stop noisd && \
sudo systemctl disable noisd && \
rm /etc/systemd/system/noisd.service && \
sudo systemctl daemon-reload && \
cd $HOME && \
rm -rf .noisd && \
rm -rf $(which noisd)
```

