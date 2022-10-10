</p>
<p style="font-size:14px" align="right">
<a href="https://discord.gg/4BqRm2vbxB" target="_blank">Join MUN Discord<img src="https://user-images.githubusercontent.com/50621007/176236430-53b0f4de-41ff-41f7-92a1-4233890a90c8.png" width="30"/></a>
</p>

<p style="font-size:14px" align="right">
<a href="https://github.com/elangrr/testnet_manuals" target="_blank">More Guide Tutorials<img src="https://avatars.githubusercontent.com/u/34649601?v=4" width="30"/></a>
</p>

<p style="font-size:14px" align="right">
<a href="https://indonode.dev/" target="_blank">Visit my website <img src="https://avatars.githubusercontent.com/u/34649601?v=4" width="30"/></a>
</p>

<p align="center">
 <img height="150" height="auto" src="https://avatars.githubusercontent.com/u/111688630?v=4">
</p>

# Official Links
### [Official Document](https://github.com/munblockchain/mun)
### [MUN Official Website](https://www.mun.money/)

## Minimum Requirements 
- 4vCPU
- 8GB of Ram
- 160 GB SSD

# Pre-Installation !!!
First open port
```
sudo ufw allow ssh
sudo ufw allow 26657
sudo ufw allow 26656
sudo ufw enable
```
`NOTE : AZURE USER OPEN PORT IN THEIR PANEL !!!`

## Auto Install Script
```
wget -O mun.sh https://raw.githubusercontent.com/elangrr/testnet_guide/main/mun/mun.sh && chmod +x mun.sh && ./mun.sh
```

## Manual Installation
### Set Vars
```
NODENAME=<YOUR_MONIKER>
```
change `<YOUR_MONIKER>` to whatever moniker you like.

NOTE !! MONIKER NAME FORMAT SHOULD BE : `YOUR-MONIKER-FORMAT`

Example : `indo-node-dev`


Save and import variable to system
```
echo "export NODENAME=$NODENAME" >> $HOME/.bash_profile
if [ ! $WALLET ]; then
	echo "export WALLET=wallet" >> $HOME/.bash_profile
fi
echo "export MUN_CHAIN_ID=testmun" >> $HOME/.bash_profile
source $HOME/.bash_profile
```

# Installation
### Install Depencies
```
sudo apt update && sudo apt upgrade -y && sudo apt install curl build-essential git wget jq make gcc tmux chrony -y
```

### Install Latest version of GO (1.18+)
```
wget -q -O - https://raw.githubusercontent.com/canha/golang-tools-install-script/master/goinstall.sh | bash -s -- --version 1.18
source ~/.profile
```

### Install Binaries
```
git clone https://github.com/munblockchain/mun
cd mun
sudo rm -rf ~/.mun
go mod tidy
make install
```

### Init your node
```
mund init $NODENAME --chain-id $MUN_CHAIN_ID
```

### Download genesis 
```
curl --tlsv1 https://node1.mun.money/genesis? | jq ".result.genesis" > ~/.mun/config/genesis.json
```

### Update seed
```
SEEDS="9240277fca3bfa0c3b94efa60215ca10cf54f249@45.76.68.116:26656"
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.mun/config/config.toml
```
If the seeds doesnt work use one of these seeds :
- seed1 = "b4eeaf7ca17e5186b181885714cedc6a78d20c9b@167.99.6.48:26656" 
- seed2 = "6a08f2f76baed249d3e3c666aaef5884e4b1005c@167.71.0.38:26656" 
- seed3 = "9240277fca3bfa0c3b94efa60215ca10cf54f249@45.76.68.116:26656"

### Replace token format
```
sed -i 's/stake/utmun/g' ~/.mun/config/genesis.json
```

### Create Service
```
sudo tee /etc/systemd/system/mund.service > /dev/null <<EOF
[Unit]
Description=mun
After=network-online.target

[Service]
User=$USER
ExecStart=$(which mund) start --home $HOME/.mun --pruning="nothing" --rpc.laddr "tcp://0.0.0.0:26657"
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF
```

### Register and start service
```
sudo systemctl daemon-reload
sudo systemctl enable mund
sudo systemctl restart mund && sudo journalctl -u mund -f -o cat
```

### Create wallet
to create new wallet : 
```
mund keys add $WALLET
```

to recover existing wallet (OPTIONAL!!)
```
mund keys add $WALLET --recover
```

to get current list of wallet
```
mund keys list
```

### Save wallet info
```
MUN_WALLET_ADDRESS=$(mund keys show $WALLET -a)
```
```
MUN_VALOPER_ADDRESS=$(mund keys show $WALLET --bech val -a)
```
```
echo 'export MUN_WALLET_ADDRESS='${MUN_WALLET_ADDRESS} >> $HOME/.bash_profile
echo 'export MUN_VALOPER_ADDRESS='${MUN_VALOPER_ADDRESS} >> $HOME/.bash_profile
source $HOME/.bash_profile
```

## Tips

You should wait until the node gets fully synchronized with other nodes. You can cross check with the genesis node by visiting https://node1.mun.money/status and check the latest block height. You can also check your node status through this link http://[Your_Node_IP]:26657/status.

Or visit https://blockexplorer.mun.money

### Create Validator
to become a validator by staking 50K TMUN
```
mund tx staking create-validator \
	--from $WALLET \
	--moniker $NODENAME \
	--pubkey $(mund tendermint show-validator) \
	--chain-id $MUN_CHAIN_ID \
	--amount 50000000000utmun \
	--commission-max-change-rate 0.01 \
	--commission-max-rate 0.2 \
	--commission-rate 0.1 \
	--min-self-delegation 1 \
	--fees 200000utmun \
	--gas auto \
	--gas-adjustment=1.5 -y
```

## Usefull commands
### Service management
Check logs
```
journalctl -fu mund -o cat
```

Start service
```
sudo systemctl start mund
```

Stop service
```
sudo systemctl stop mund
```

Restart service
```
sudo systemctl restart mund
```

### Node info
Synchronization info
```
mund status 2>&1 | jq .SyncInfo
```

Validator info
```
mund status 2>&1 | jq .ValidatorInfo
```

Node info
```
mund status 2>&1 | jq .NodeInfo
```

Show node id
```
mund tendermint show-node-id
```

### Wallet operations
List of wallets
```
mund keys list
```

Recover wallet
```
mund keys add $WALLET --recover
```

Delete wallet
```
mund keys delete $WALLET
```

Get wallet balance
```
mund query bank balances $MUN_WALLET_ADDRESS
```

Transfer funds
```
mund tx bank send $MUN_WALLET_ADDRESS <TO_MUN_WALLET_ADDRESS> 10000000utmun
```

### Voting
```
mund tx gov vote 1 yes --from $WALLET --chain-id=$MUN_CHAIN_ID
```

### Staking, Delegation and Rewards
Delegate stake
```
mund tx staking delegate $MUN_VALOPER_ADDRESS 10000000utmun --from=$WALLET --chain-id=$MUN_CHAIN_ID --gas=auto
```

Redelegate stake from validator to another validator
```
mund tx staking redelegate <srcValidatorAddress> <destValidatorAddress> 10000000utmun --from=$WALLET --chain-id=$MUN_CHAIN_ID --gas=auto
```

Withdraw all rewards
```
mund tx distribution withdraw-all-rewards --from=$WALLET --chain-id=$MUN_CHAIN_ID --gas=auto
```

Withdraw rewards with commision
```
mund tx distribution withdraw-rewards $MUN_VALOPER_ADDRESS --from=$WALLET --commission --chain-id=$MUN_CHAIN_ID
```

### Validator management
Edit validator
```
mund tx staking edit-validator \
  --moniker=$NODENAME \
  --identity=<your_keybase_id> \
  --website="<your_website>" \
  --details="<your_validator_description>" \
  --chain-id=$MUN_CHAIN_ID \
  --from=$WALLET
```

Unjail validator
```
mund tx slashing unjail \
  --broadcast-mode=block \
  --from=$WALLET \
  --chain-id=$MUN_CHAIN_ID \
  --gas=auto
```

### Delete node
This commands will completely remove node from server. Use at your own risk!
```
sudo systemctl stop mund
sudo systemctl disable mund
sudo rm /etc/systemd/system/mun* -rf
sudo rm $(which mund) -rf
sudo rm $HOME/.mun* -rf
sudo rm $HOME/mun -rf
sed -i '/MUN_/d' ~/.bash_profile
```

