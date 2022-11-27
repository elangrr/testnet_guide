</p>
<p style="font-size:14px" align="right">
<a href="https://discord.gg/NtFMGGRn" target="_blank">Join Point Network Discord<img src="https://user-images.githubusercontent.com/50621007/176236430-53b0f4de-41ff-41f7-92a1-4233890a90c8.png" width="30"/></a>
</p>

<p style="font-size:14px" align="right">
<a href="https://github.com/elangrr/testnet_manuals" target="_blank">More Guide Tutorials<img src="https://avatars.githubusercontent.com/u/34649601?v=4" width="30"/></a>
</p>

<p style="font-size:14px" align="right">
<a href="https://indonode.dev/" target="_blank">Visit my website <img src="https://avatars.githubusercontent.com/u/34649601?v=4" width="30"/></a>
</p>

<p align="center">
  <img height="150" height="auto" src="https://user-images.githubusercontent.com/38981255/185550018-bf5220fa-7858-4353-905c-9bbd5b256c30.jpg">
</p>

# Point Network Mainnet

## [Official Guide](https://github.com/pointnetwork/point-chain/blob/mainnet/VALIDATORS.md)


## Minimum Requirements
 - 4 or more physical CPU cores
 - At least 500GB of SSD disk storage
 - At least 32GB of memory (RAM)
 - At least 100mbps network bandwidth


## Installation

## Set Vars
```
NODENAME=YOUR_MONIKER
```
Change `YOUR_MONIKER` To your Moniker
```
echo 'export NODENAME='$NODENAME >> $HOME/.bash_profile
source $HOME/.bash_profile
```

### Download Update Prequisites
```
sudo apt update && sudo apt upgrade -y
sudo apt install curl build-essential git wget jq make gcc tmux -y
```
### Install GO (1.18.2)
```
if ! [ -x "$(command -v go)" ]; then
  ver="1.18.2"
  cd $HOME
  wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz"
  sudo rm -rf /usr/local/go
  sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
  rm "go$ver.linux-amd64.tar.gz"
  echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> ~/.bash_profile
  source ~/.bash_profile
fi
```

### Download Binary 
```
cd $HOME
rm -rf point-chain
git clone https://github.com/pointnetwork/point-chain && cd point-chain
git fetch --all
git checkout tags/v0.0.4
make install
```

### Init
```
pointd init $NODENAME --chain-id point_10687-1
```

### Download Genesis and Config
```
wget https://raw.githubusercontent.com/pointnetwork/point-chain-config/main/mainnet-1/config.toml
wget https://raw.githubusercontent.com/pointnetwork/point-chain-config/main/mainnet-1/genesis.json
mv config.toml genesis.json ~/.pointd/config/
```

### Set Peers
```
PEERS=`curl -s https://raw.githubusercontent.com/pointnetwork/point-chain-config/main/mainnet-1/peers.txt`
sed -i.bak -e "s/^persistent_peers *=.*/persistent	_peers = \"$PEERS\"/" $HOME/.pointd/config/config.toml
```

### Indexer and Pruning (OPTIONAL)
```
indexer="null"
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="10"

sed -i -e "s/^indexer *=.*/indexer = \"$indexer\"/" $HOME/.pointd/config/config.toml
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.pointd/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.pointd/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.pointd/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.pointd/config/app.toml
```
### Reset
```
pointd tendermint unsafe-reset-all --home $HOME/.pointd
```

### Create Service and Start Node
```
sudo tee /etc/systemd/system/pointd.service > /dev/null <<EOF
[Unit]
Description=point
After=network-online.target

[Service]
User=$USER
ExecStart=$(which pointd) start --home $HOME/.pointd
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF
```
```
sudo systemctl daemon-reload
sudo systemctl enable pointd
sudo systemctl restart pointd
```

## Create Wallet
Create validator wallet using this command, Dont forget to save the Mnemonic!
```
pointd keys add wallet 
```
(OPTIONAL) To recover using your previous saved wallet
```
pointd keys add wallet --recover
```
To get current list of wallet
```
pointd keys list 
```

## Create Validator
Before creating validator please make sure you have the funds already in your wallet
To check wallet balance :
```
pointd query bank balances $POINT_WALLET_ADDRESS
```
To create a validator with 1000point delegation use this command below :

```
pointd tx staking create-validator \
--amount=100000000000000000000apoint \
--pubkey=$(pointd tendermint show-validator) \
--moniker=$NODENAME \
--chain-id=point_10687-1 \
--commission-rate="0.05" \
--commission-max-rate="0.10" \
--commission-max-change-rate="0.01" \
--min-self-delegation="1" \
--gas="400000" \
--gas-prices="0.025apoint" \
--from=wallet
```
NOTE : 100000000000000000000apoint is 100 Point

`commision rate : 5%`

### State-Sync (OPTIONAL)
```
sudo systemctl stop pointd

cp $HOME/.pointd/data/priv_validator_state.json $HOME/.pointd/priv_validator_state.json.backup
pointd tendermint unsafe-reset-all --home $HOME/.pointd --keep-addr-book

SNAP_RPC="http://rpc-mainnet-1.point.space:26659"

LATEST_HEIGHT=$(curl -s $SNAP_RPC/block | jq -r .result.block.header.height); \
BLOCK_HEIGHT=$((LATEST_HEIGHT - 2000)); \
TRUST_HASH=$(curl -s "$SNAP_RPC/block?height=$BLOCK_HEIGHT" | jq -r .result.block_id.hash)

echo $LATEST_HEIGHT $BLOCK_HEIGHT $TRUST_HASH

peers="8673c1f04c29c464189e8bf29e51fb0b38da2f19@rpc-mainnet-1.point.space:26656"
sed -i 's|^persistent_peers *=.*|persistent_peers = "'$peers'"|' $HOME/.pointd/config/config.toml

sed -i -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1true| ; \
s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"$SNAP_RPC,$SNAP_RPC\"| ; \
s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1$BLOCK_HEIGHT| ; \
s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"|" $HOME/.pointd/config/config.toml

mv $HOME/.pointd/priv_validator_state.json.backup $HOME/.pointd/data/priv_validator_state.json

sudo systemctl restart pointd
sudo journalctl -u pointd -f --no-hostname -o cat
```

## Monitoring your validator

Check TX HASH ( Which <txhash> is your txhash from the transaction
```
pointd query tx <txhash>
```
If the transaction was correct you should instantly become part of the validators set. Check your pubkey first:
```
pointd tendermint show-validator
```
You will see a key there, you can identify your node among other validators using that key:
```
pointd query tendermint-validator-set
```
There you will find more info like your VotingPower that should be bigger than 0. Also you can check your VotingPower by running:
```
pointd status
```

## Useful Commands
Check Logs
```
journalctl -fu pointd -o cat
```
Start Service
```
sudo systemctl start pointd
```
Stop Service
```
sudo systemctl stop pointd
```
Restart Service
```
sudo systemctl restart pointd
```
## Node Info
Synchronization info
```
pointd status 2>&1 | jq .SyncInfo
```
Validator Info
```
pointd status 2>&1 | jq .ValidatorInfo
```
Node Info
```
pointd status 2>&1 | jq .NodeInfo
```

## Delegation, Withdraw , Etc
To delegate to your validator run this command :
 Note : Change <ammount> to your like , for example : 1000000000000000000000apoint is 1000point
```
pointd tx staking delegate <point valoper> 1000000000000000000000apoint --from=validatorkey --chain-id=point_10687-1 --gas-prices=0.025apoint --gas=400000 
```
Change `<point valoper>` to your valoper address 

To Withdraw all rewards without commision
```
pointd tx distribution withdraw-all-rewards --from=validatorkey --chain-id point_10687-1 --gas-prices=0.025apoint
```
To Withdraw rewards with commision
```
pointd tx distribution withdraw-rewards <point val> --from=validatorkey --commission --chain-id point_10687-1 --gas-prices=0.025apoint
```
If failed remove `--gas-prices=0.025apoint`

NOTE: Change `<point val>` to your valoper address

To check valoper address run this command :
```
pointd debug addr <point address>
```
  
## Validator Management
Unjail Validator (MAKE SURE YOU ARE SYNCED WITH THE LASTEST NODE , and have 1000 Point Delegation!!)
```
pointd tx slashing unjail --from=validatorkey --chain-id=point_10687-1 --gas-prices=0.025apoint
```
Check if your validator is active: (if the output is non-empty, you are a validator)
```
pointd query tendermint-validator-set | grep "$(pointd tendermint show-address)"
```
See the slashing status: (if Jailed until year 1970 means you are not jailed!)
``` 
pointd query slashing signing-info $(pointd tendermint show-validator) 
```

## Delete Node Permanently (Backup your Private key first if you wanna migrate !!)
```
sudo systemctl stop pointd
sudo systemctl disable pointd
sudo rm /etc/systemd/system/point* -rf
sudo rm $(which pointd) -rf
sudo rm $HOME/.pointd -rf
sudo rm $HOME/point-chain -rf
```

  
