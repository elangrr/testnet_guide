</p>
<p style="font-size:14px" align="right">
<a href="https://discord.gg/d4wbfZCtTG" target="_blank">Join Ollo Station Discord<img src="https://user-images.githubusercontent.com/50621007/176236430-53b0f4de-41ff-41f7-92a1-4233890a90c8.png" width="30"/></a>
</p>

<p style="font-size:14px" align="right">
<a href="https://github.com/elangrr/testnet_manuals" target="_blank">More Guide Tutorials<img src="https://avatars.githubusercontent.com/u/34649601?v=4" width="30"/></a>
</p>

<p style="font-size:14px" align="right">
<a href="https://indonode.dev/" target="_blank">Visit my website <img src="https://avatars.githubusercontent.com/u/34649601?v=4" width="30"/></a>
</p>

<p align="center">
  <img height="150" height="auto" src="https://user-images.githubusercontent.com/50621007/192699071-461d8ff6-6ddf-4d4f-aba7-d3ddcc4a5563.png">
</p>

# Point Network Mainnet

## [Official Guide](https://docs.ollo.zone/validators/running_a_node)


## Minimum Requirements
- 4x CPUs; the faster clock speed the better
- 8GB RAM
- 100GB of storage (SSD or NVME)
- Permanent Internet connection (traffic will be minimal during testnet; 10Mbps will be plenty - for production at least 100Mbps is expected)

## Ollo Validator Setup

### Setting up variable
```
NODENAME=<YOUR MONIKER>
```
Change `<YOUR MONIKER>` To any moniker you like

Save and import variables
```
echo "export NODENAME=$NODENAME" >> $HOME/.bash_profile
if [ ! $WALLET ]; then
	echo "export WALLET=wallet" >> $HOME/.bash_profile
fi
echo "export OLLO_CHAIN_ID=ollo-testnet-0" >> $HOME/.bash_profile
source $HOME/.bash_profile
```

### Packages and Depencies
Update Package
```
sudo apt update && sudo apt upgrade -y
```
Install Depencies
```
sudo apt install curl build-essential git wget jq make gcc tmux chrony -y
```

### Install GO 1.18+
```
if ! [ -x "$(command -v go)" ]; then
  ver="1.18.3"
  cd $HOME
  wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz"
  sudo rm -rf /usr/local/go
  sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
  rm "go$ver.linux-amd64.tar.gz"
  echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> ~/.bash_profile
  source ~/.bash_profile
fi
```

### Download and build binaries
```
cd $HOME
git clone https://github.com/OllO-Station/ollo.git
cd ollo
make install
```

### Config
```
ollod config chain-id $OLLO_CHAIN_ID
ollod config keyring-backend test
```

### Init
```
ollod init $NODENAME --chain-id $OLLO_CHAIN_ID
```

### Download Genesis and Addrbook
```
curl https://raw.githubusercontent.com/OllO-Station/ollo/master/networks/ollo-testnet-0/genesis.json | jq .result.genesis > $HOME/.ollo/config/genesis.json
```

### Set Peers 
```
SEEDS=""
PEERS="764988cb3a9de4afa34c666019510ea5b5856c60@65.108.238.61:46656,4dd3f3897ab77c7aa981bf4e928659f867093361@198.244.179.62:25456,1be12d239ca70a906264de0f09e0ffa01c4211ba@138.201.136.49:26656,ffbc66ef617ec910e453bec28d2750951d964f89@154.53.59.87:32656,9316bed278b94c3e8a298b0649d62ca9c57bd210@94.103.93.45:15656,6368702dd71e69035dff6f7830eb45b2bae92d53@65.109.57.161:15656,d24d7968f2377a1488c057c79f39e6c7a0d5698b@95.217.12.175:32656,7735cb5a04ad60437c575ecc5280c43b2df9a038@161.97.99.247:11656,362c9af972fb9bbc058a48786a097c74e2606504@176.9.106.43:36656,3498a07e5e79b269a3e445e8073d58bf42b6a5b8@185.173.37.47:32656"
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.ollo/config/config.toml
```
`NOTE : IF PEERS DEAD USE THIS` [NEW PEERS LIST 03/10/22](https://raw.githubusercontent.com/elangrr/testnet_guide/main/ollo/peerslist.txt)

### Config Prunning (Optional)
```
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="50"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.ollo/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.ollo/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.ollo/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.ollo/config/app.toml
```

### Set Minimum Gas Price and commit
```
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0utollo\"/" $HOME/.ollo/config/app.toml
```

### Reset Chain Data
```
ollod tendermint unsafe-reset-all --home $HOME/.ollo
```

### Create Service
```
sudo tee /etc/systemd/system/ollod.service > /dev/null <<EOF
[Unit]
Description=ollo
After=network-online.target

[Service]
User=$USER
ExecStart=$(which ollod) start --home $HOME/.ollo
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF
```

### Start Service
```
sudo systemctl daemon-reload
sudo systemctl enable ollod
sudo systemctl restart ollod && sudo journalctl -u ollod -f -o cat
```

### Create Wallet
Create new wallet 
```
ollod keys add $WALLET
```

Recover existing wallet (Optional)
```
ollod keys add $WALLET --recover
```

Get current list of wallets
```
ollod keys list
```

### Save Wallet info
```
OLLO_WALLET_ADDRESS=$(ollod keys show $WALLET -a)
OLLO_VALOPER_ADDRESS=$(ollod keys show $WALLET --bech val -a)
echo 'export OLLO_WALLET_ADDRESS='${OLLO_WALLET_ADDRESS} >> $HOME/.bash_profile
echo 'export OLLO_VALOPER_ADDRESS='${OLLO_VALOPER_ADDRESS} >> $HOME/.bash_profile
source $HOME/.bash_profile
```

### Fund your wallet 
Go to [Ollo Station Community Discord](https://discord.gg/d4wbfZCtTG) and request token in Faucet by typing

`!request <address>`

### Create validator
To create validator you need Ollo tokens , to check if you have any :
```
ollod query bank balances $OLLO_WALLET_ADDRESS
```
`NOTE : If your wallet is not showing any balance your node is probably still syncing , wait untill your node is fully synced~`

Create your validator with 2 UTOLLO, 1 ollo is equal to 1000000 utollo
```
ollod tx staking create-validator \
  --amount 2000000utollo \
  --from $WALLET \
  --commission-max-change-rate "0.01" \
  --commission-max-rate "0.2" \
  --commission-rate "0.07" \
  --min-self-delegation "1" \
  --pubkey  $(ollod tendermint show-validator) \
  --moniker $NODENAME \
  --chain-id $OLLO_CHAIN_ID
  ```

## Usefull commands
### Service management
Check logs
```
journalctl -fu ollod -o cat
```

Start service
```
sudo systemctl start ollod
```

Stop service
```
sudo systemctl stop ollod
```

Restart service
```
sudo systemctl restart ollod
```

### Node info
Synchronization info
```
ollod status 2>&1 | jq .SyncInfo
```

Validator info
```
ollod status 2>&1 | jq .ValidatorInfo
```

Node info
```
ollod status 2>&1 | jq .NodeInfo
```

Show node id
```
ollod tendermint show-node-id
```

### Wallet operations
List of wallets
```
ollod keys list
```

Recover wallet
```
ollod keys add $WALLET --recover
```

Delete wallet
```
ollod keys delete $WALLET
```

Get wallet balance
```
ollod query bank balances $OLLO_WALLET_ADDRESS
```

Transfer funds
```
ollod tx bank send $OLLO_WALLET_ADDRESS <TO_OLLO_WALLET_ADDRESS> 10000000utollo
```

### Voting
```
ollod tx gov vote 1 yes --from $WALLET --chain-id=$OLLO_CHAIN_ID
```

### Staking, Delegation and Rewards
Delegate stake
```
ollod tx staking delegate $OLLO_VALOPER_ADDRESS 10000000utollo --from=$WALLET --chain-id=$OLLO_CHAIN_ID --gas=auto
```

Redelegate stake from validator to another validator
```
ollod tx staking redelegate <srcValidatorAddress> <destValidatorAddress> 10000000utollo --from=$WALLET --chain-id=$OLLO_CHAIN_ID --gas=auto
```

Withdraw all rewards
```
ollod tx distribution withdraw-all-rewards --from=$WALLET --chain-id=$OLLO_CHAIN_ID --gas=auto
```

Withdraw rewards with commision
```
ollod tx distribution withdraw-rewards $OLLO_VALOPER_ADDRESS --from=$WALLET --commission --chain-id=$OLLO_CHAIN_ID
```

### Validator management
Edit validator
```
ollod tx staking edit-validator \
  --moniker=$NODENAME \
  --identity=<your_keybase_id> \
  --website="<your_website>" \
  --details="<your_validator_description>" \
  --chain-id=$OLLO_CHAIN_ID \
  --from=$WALLET
```

Unjail validator
```
ollod tx slashing unjail \
  --broadcast-mode=block \
  --from=$WALLET \
  --chain-id=$OLLO_CHAIN_ID \
  --gas=auto
```

### Delete node
This commands will completely remove node from server. Use at your own risk!
```
sudo systemctl stop ollod
sudo systemctl disable ollod
sudo rm /etc/systemd/system/ollo* -rf
sudo rm $(which ollod) -rf
sudo rm $HOME/.ollo* -rf
sudo rm $HOME/ollo -rf
sed -i '/OLLO_/d' ~/.bash_profile
```


