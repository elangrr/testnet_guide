<p style="font-size:14px" align="right">
<a href="https://github.com/elangrr/testnet_manuals" target="_blank">More Guide Tutorials<img src="https://avatars.githubusercontent.com/u/34649601?v=4" width="30"/></a>
</p>

<p style="font-size:14px" align="right">
<a href="https://indonode.dev/" target="_blank">Visit my website <img src="https://avatars.githubusercontent.com/u/34649601?v=4" width="30"/></a>
</p>

<p align="center">
 <img height="420" height="auto" src="https://user-images.githubusercontent.com/44331529/193969092-38e7ec7f-bca0-4bd9-a31d-5ba52b71ec81.png">
</p>

# Official Links
### [Official Document](https://github.com/empowerchain/empowerchain/tree/main/testnets/altruistic-1)
### [Empowerchain Official Website](https://www.empowerchain.io/)
### [Empowerchain Discord](https://discord.gg/wCdUabQNBk)

## Minimum Requirements 
- 4vCPU
- 8GB of Ram
- 160 GB SSD


## Pre-Installation
### Set Vars
```
NODENAME=<YOUR_MONIKER>
```
change `<YOUR_MONIKER>` to whatever moniker you like.


Save and import variable to system
```
echo "export NODENAME=$NODENAME" >> $HOME/.bash_profile
if [ ! $WALLET ]; then
	echo "export WALLET=wallet" >> $HOME/.bash_profile
fi
echo "export EMPOWER_CHAIN_ID=altruistic-1" >> $HOME/.bash_profile
source $HOME/.bash_profile
```
# Empowerchain Validator Guide
### Install depencies
```
sudo apt update && sudo apt upgrade -y && \
sudo apt install curl tar wget clang pkg-config libssl-dev jq build-essential bsdmainutils git make ncdu gcc git jq chrony liblz4-tool -y
```

### Install GO (1.18.3)
```
cd $HOME && version="1.18.3" && \
wget "https://golang.org/dl/go$version.linux-amd64.tar.gz" && \
sudo rm -rf /usr/local/go && \
sudo tar -C /usr/local -xzf "go$version.linux-amd64.tar.gz" && \
rm "go$version.linux-amd64.tar.gz" && \
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> $HOME/.bash_profile && \
source $HOME/.bash_profile && \
go version
```

### Download and set binaries
```
cd $HOME && git clone https://github.com/empowerchain/empowerchain && \
cd empowerchain/chain && \
make install && \
empowerd version --long | head
```

### Config your node
```
empowerd config chain-id $EMPOWER_CHAIN_ID
empowerd config keyring-backend file
```

### Init your node
```
empowerd init $NODENAME --chain-id $EMPOWER_CHAIN_ID
```

### Set genesis
```
rm -rf $HOME/.empowerchain/config/genesis.json && cd $HOME/.empowerchain/config && wget https://raw.githubusercontent.com/empowerchain/empowerchain/main/testnets/altruistic-1/genesis.json
```
Check with `sha256sum $HOME/.empowerchain/config/genesis.json`

Output : `fcae4a283488be14181fdc55f46705d9e11a32f8e3e8e25da5374914915d5ca8`

### Config Prunning (OPTIONAL)
```
pruning="custom" && \
pruning_keep_recent="100" && \
pruning_keep_every="0" && \
pruning_interval="10" && \
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.empowerchain/config/app.toml && \
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.empowerchain/config/app.toml && \
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.empowerchain/config/app.toml && \
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.empowerchain/config/app.toml
```

### Set indexer (OPTIONAL)
```
indexer="null" && \
sed -i -e "s/^indexer *=.*/indexer = \"$indexer\"/" $HOME/.empowerchain/config/config.toml
```

### Set minimum gas price and peers
```
sed -i.bak -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.025umpwr\"/" $HOME/.empowerchain/config/app.toml
sed -i -e "s/^filter_peers *=.*/filter_peers = \"true\"/" $HOME/.empowerchain/config/config.toml
external_address=$(wget -qO- eth0.me) 
sed -i.bak -e "s/^external_address *=.*/external_address = \"$external_address:26656\"/" $HOME/.empowerchain/config/config.toml

peers="ca8b9d5fecd3258cb8bb4164017114898cd63ad5@empower-testnet.nodejumper.io:31656,46b552c62df0523a2bfff285eb384e4b197484aa@65.21.133.125:33656,0314ad645ce08401d190521643503c803e9335dd@65.108.127.215:26696,c3ade1fb182d5cb6a4ed56ce05b84b872c5b5b3e@65.108.229.225:54656,ab4b4331d161cf0e98d3244e30225e4f38ac8d2f@65.109.28.177:44656,d14dd1b664c30270be84e94d456014d847e33c91@65.21.193.112:26616,d9307a7ba665a54e65f4fa5dbb5401448e1c3456@65.109.30.117:30656,3b41eaba864fa4d10b00685e6bad4318700b2583@65.108.124.54:54656,9a6b638b3a6ae693c6e51208da832718c35f8f39@65.108.234.126:38656,6e65e245f41de513ad7dad22fb47acc59698b655@167.235.77.194:26656,e8f6d75ab37bf4f08c018f306416df1e138fd21c@95.217.135.41:26656,ab8730768fa3689a5e58eb1504a3802b29973014@65.21.138.123:33656,5f4bef848ad7a8265387742b78638afcfe5ac751@34.125.154.234:26656,c8d488e8ce1dc25dcdb6a420d6406982c46edfe6@135.181.255.131:26656,86669cd5e5914f862578d43de483f49e93d396b1@51.83.35.129:26656,aeb6bdbf28b3883a206570a29cda164e889fc807@194.163.155.84:26656,07e2aac37ac8e337214b53f1fe9121d6d6f238b8@195.201.103.54:26656,a2ed6f01e454d3469a95edee6580e750d79d4297@142.132.199.236:22656,b405572f7bf70f681d1e82f196e1399bf90a9d8a@138.201.197.163:26656,c5d44acd2f0ee122352d2f8154d9b29aeb9bf0ec@159.69.65.97:36656,bd8274637720d5338b31fe143c62e83e938fdeac@194.163.131.83:26676,76537229c17d0d09d4ec672d7c8baa0c0c12e9d2@38.242.246.181:26656,12426ec181f1aef0e7a2aa99a88bde9c357cc8e9@38.242.251.1:26656,7722e5d0f84d72da7bd17aee50184d52999ff7f4@45.84.138.224:26656,24e10413764bccfd91dda196b62cd732be414bf9@46.138.244.152:26656,8abceaabc650d81a751e40382f80af6c98ba466f@185.239.209.180:35656,f0ac01503193e1f1eb63ee1407726e4da940f17d@161.97.105.150:15656,c6d783f058a722b9d4fd6a3c7acf5328963c8227@5.161.112.84:26656,8fabf4b8d1f41530412269493199faaa1e2d2571@80.82.215.243:26666,8498049b61177a53b3f0e6b8f7c4a574251a2bbb@149.102.157.96:36656,409d8644100d1eaa95ac55afb9505060316ba859@5.189.178.222:46656,21787f4466839fd5375914711d83c0ae48305ef8@46.138.245.164:24436,5a68fe7914a170ef3ebbdc404703ac8b5d828bcf@137.184.146.226:26656,326a9806fca6c45ef75c9fcf594cb8f56d6ee63f@5.161.111.18:26656,55f8978c0024c59ad5dcdee0874a9dab2cf916c8@194.180.176.59:26656,56d05d4ae0e1440ad7c68e52cc841c424d59badd@96.234.160.22:26656,50725c195e46b3863ad7de26f044a14941dbe815@193.46.243.171:26656,ff18196236e62eb564cbeb1343eb6a7ecfdfcc77@194.163.175.30:26656,b72e6976e21ccda63c019a956899b374c7fc21fa@149.102.137.255:26656,ed638559942030c6b18a9ebd2bfaab572e9c4f42@65.108.68.233:26756,c2d4fd99f12be0b406cbc4e9416043f39722b4f6@38.242.128.227:26656,3c0374af8de23bb8379b3149516f2c3d8499d4be@65.109.34.133:60956,e1f5eca7423d9a4f422ff00f80609321e32e6862@190.102.106.50:26656,5935c103703407ba314fe9e20be82c318b99ca58@45.85.146.224:26656,c5f73ce5526e32d1c43eeb1afa29b7928acab9b4@185.169.252.86:26656,707d0e3f757bedaaff6fd92e12c6089b1ebe50d8@194.163.179.16:26656,12917731184e3499a26d614f9542724e2bfcf63a@193.46.243.95:26656,0871e0e36e83453bdea04e93a85e4cace90b4323@139.144.173.65:26656,ec4cbf95e9c2a62b8d9d71a8c8b9b2679dc9d656@167.86.127.111:26656,bd6ddd430e158a6d4da22dab90152a8ca07a5e40@135.181.98.172:26656,9dcaea7968bcca694f85c3dddb743e38ab48343d@20.237.174.242:26656,70978f162a0fa5bf4245b1a94b06e9b1804d0c27@185.196.21.104:26656,39ae78479c3cdb569a0532846c15c6d38f5a2b34@95.217.0.223:26656,9fe8cff1e057086c357b6b83b7cf49c2af6c6adb@159.203.41.233:26656,6c523db71cf49a658a747ba952be83de3dd0fc5b@178.79.191.243:26656,f5a5df8a5d168613c2c152a231b9cac88a58be2b@149.102.149.20:26656,671c980d0f0ea6eb5753e2358262ba02a0619eb5@194.247.12.102:26656,cc39a6017d9dc20ff1dab94e93ac8af02962df29@38.242.236.206:26656,f5f2697fef536365789a07d1908417babfbc3464@38.242.251.167:26656,b138999b35c50ce7dc62bab6928c923bd8d91682@195.201.194.188:11045,7ba7609b37eea967abe94d233ae74245530e8877@135.181.221.186:31656,bfbf8e0b04435cabf87f7db43e68df39e2bcdf44@38.242.242.196:26656,1c13bffa07861f7317d44e11c06336902602803e@65.21.144.234:26656,6fa57fc737fa9d33ecac359f8ca62d84d5fe7a22@149.102.137.217:26656,71511855c7bdee9c8d19d253238ebac8d367d7cb@178.238.229.107:26656,42020b7c9520f387bad61cbb2da705d383f38840@95.111.234.147:26656,f44370a859b58f471a8ce9c3ca4584132dbe9717@45.94.209.38:26656,1531672b7b11a1ce673c472c565431b7b484f1ae@45.84.138.151:26656,f26af8b833e2dc2c890daedfd2dcd2fe3b641ccf@161.97.132.207:26656,2bcbfbe6d9a1677d16e4e745066ea84aa3af0731@162.55.234.70:54856,8721e086acb679c4c48d507096fe0fe532ff70d0@134.122.39.157:26656,596f6892efa7473ea2930ffde0f8c4d60a16eb50@38.242.154.155:26656,3525fd3a8a96a67e150d9a04f493a60f22b2e11a@147.182.246.192:26656,d07725c5dceb916810bf31606e380ea763e80184@38.242.159.119:26656,843646b8c43df057635cf1d063e72e26fba55c2d@138.197.158.127:26656,7ce890789ed7521399a34427c60f1f9d10edaf93@159.223.167.63:26656,ede8257e4be3d7dc369f652263a139c8c083e97e@149.102.129.159:26656,773a76711d9a99fb3ef1bf72621af547bc77c58e@167.235.50.65:26656,c7eb93b0ad5a3d79ee921cf20fe1aba866d673e6@46.101.183.146:26656,df91c557d873b37ef98644911852b83ce3f1894f@134.122.43.152:26656,f73c4eb3749984a6d5717753fce85fa6b085dc5d@185.182.185.145:26656,d006a4875c91bb5febde6d49bd65daa30112a1f0@109.107.182.46:26656,2409fd7723ced295651f913f93f667ed2062bb29@138.68.141.214:10656,ae7ca3688e313aa1d8acf168a2a6efd27a0e9e2e@217.199.117.158:26656,ad19d0fedb825a05a64189bff2b23e617f26eda6@134.122.38.167:26656,8a9559d240c3e89031e1e254c4170f7055f45405@167.86.91.34:26656,ae03dd3ab682d62048808a088bc7621c3baedc22@157.230.183.146:26656,6a3f47a50548cc7a9b91c1446378faab398c7d3b@75.119.146.75:26656,6fcd814ed30f16a516aaef9e089d6de77be3d530@134.122.23.155:26656,76a88e13f1d0f957b93b84375783cfeb11714b67@38.242.146.28:26656,0f42474c058db28cc450d92ff30e127ff16d0b0d@94.130.140.145:26656,bd057ea7df5b109b97d4a7fae2d0e3df244af89b@137.184.178.158:26656,5f31d621b9d348386e1145fdfdeefe0d45cf2030@104.199.121.169:26656,62d27d651195f384be7bf8c29545c02ed87b0067@139.59.169.187:26656,15b370f9fa0663c227c9a91827752546be587c53@142.132.253.112:26656,259763d6393938d8861aadaf224c10f746d9ad3b@38.242.245.119:26656,dc5e42affe639a14780cf95bc36aba9c0378772e@142.93.150.84:26656,704e223abd5ab11165593a8a1e53bdcbdc8dae69@34.127.20.71:26656,20e9588cbf23d6918d32cfc63bd1f9dc6e6ebebb@134.122.43.96:26656,1224ae5aac563920b1fe2e2b496820509db83403@142.93.158.71:26656"
sed -i 's|^persistent_peers *=.*|persistent_peers = "'$peers'"|' $HOME/.empowerchain/config/config.toml
```

### Download addrbook
```
curl -s https://snapshots2-testnet.nodejumper.io/empower-testnet/addrbook.json > $HOME/.empowerchain/config/addrbook.json
```

### Reset chain data
```
empowerd tendermint unsafe-reset-all --home $HOME/.empowerchain
```

### Create your wallet
To create new wallet use:
```
empowerd keys add $WALLET
```
To recover existing wallet use :
```
empowerd keys add $WALLET --recover
```
To see the current keys :
```
empowerd keys list
```

### Save wallet info
```
EMPOWER_WALLET_ADDRESS=$(empowerd keys show $WALLET -a)
EMPOWER_VALOPER_ADDRESS=$(empowerd keys show $WALLET --bech val -a)
echo 'export EMPOWER_WALLET_ADDRESS='${EMPOWER_WALLET_ADDRESS} >> $HOME/.bash_profile
echo 'export EMPOWER_VALOPER_ADDRESS='${EMPOWER_VALOPER_ADDRESS} >> $HOME/.bash_profile
source $HOME/.bash_profile
```

### Create service
```
sudo tee /etc/systemd/system/empowerd.service > /dev/null <<EOF
[Unit]
Description=EmpowerChain Node
After=network.target

[Service]
User=$USER
Type=simple
ExecStart=$(which empowerd) start
Restart=on-failure
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF
```

### Start your node 
```
sudo systemctl daemon-reload && sudo systemctl enable empowerd
sudo systemctl restart empowerd && sudo journalctl -u empowerd -f -o cat
```

To check your sync status : `empowerd status 2>&1 | jq .SyncInfo`

if the `catching_up` stated `false` then your node is already synced and you can proceed create validator

IF YOUR PEERS IS NOT CONNECTED USE SNAPSHOT BELOW!

Get the faucet on Empower discord server 

`$request <wallet address> altruistic-1`
### Create validator
After your node is synced you can create your node 
```
empowerd tx staking create-validator \
--amount 1000000umpwr \
--from $WALLET \
--commission-max-change-rate "0.10" \
--commission-max-rate "0.20" \
--commission-rate "0.10" \
--min-self-delegation "1" \
--identity="" \
--details="" \
--website="" \
--pubkey $(empowerd tendermint show-validator) \
--moniker $NODENAME \
--chain-id $EMPOWER_CHAIN_ID \
-y
```

## Snapshot (Nodejumper.io)
### Install depencies
```
sudo apt update
sudo apt install lz4 -y
```

### Snapshot
```
sudo systemctl stop empowerd

cp $HOME/.empowerchain/data/priv_validator_state.json $HOME/.empowerchain/priv_validator_state.json.backup
empowerd tendermint unsafe-reset-all --home $HOME/.empowerchain --keep-addr-book

rm -rf $HOME/.empowerchain/data 

SNAP_NAME=$(curl -s https://snapshots2-testnet.nodejumper.io/empower-testnet/ | egrep -o ">altruistic-1.*\.tar.lz4" | tr -d ">")
curl https://snapshots2-testnet.nodejumper.io/empower-testnet/${SNAP_NAME} | lz4 -dc - | tar -xf - -C $HOME/.empowerchain

mv $HOME/.empowerchain/priv_validator_state.json.backup $HOME/.empowerchain/data/priv_validator_state.json

sudo systemctl restart empowerd
sudo journalctl -u empowerd -f --no-hostname -o cat
```


## Usefull commands
### Service management
Check logs
```
journalctl -fu empowerd -o cat
```

Start service
```
sudo systemctl start empowerd
```

Stop service
```
sudo systemctl stop empowerd
```

Restart service
```
sudo systemctl restart empowerd
```

### Node info
Synchronization info
```
empowerd status 2>&1 | jq .SyncInfo
```

Validator info
```
empowerd status 2>&1 | jq .ValidatorInfo
```

Node info
```
empowerd status 2>&1 | jq .NodeInfo
```

Show node id
```
empowerd tendermint show-node-id
```

### Wallet operations
List of wallets
```
empowerd keys list
```

Recover wallet
```
empowerd keys add $WALLET --recover
```

Delete wallet
```
empowerd keys delete $WALLET
```

Get wallet balance
```
empowerd query bank balances $EMPOWER_WALLET_ADDRESS
```

Transfer funds
```
empowerd tx bank send $EMPOWER_WALLET_ADDRESS <TO_EMPOWER_WALLET_ADDRESS> 10000000umpwr
```

### Voting
```
empowerd tx gov vote 1 yes --from $WALLET --chain-id=$EMPOWER_CHAIN_ID
```

### Staking, Delegation and Rewards
Delegate stake
```
empowerd tx staking delegate $EMPOWER_VALOPER_ADDRESS 10000000umpwr --from=$WALLET --chain-id=$EMPOWER_CHAIN_ID --gas=auto
```

Redelegate stake from validator to another validator
```
empowerd tx staking redelegate <srcValidatorAddress> <destValidatorAddress> 10000000umpwr --from=$WALLET --chain-id=$EMPOWER_CHAIN_ID --gas=auto
```

Withdraw all rewards
```
empowerd tx distribution withdraw-all-rewards --from=$WALLET --chain-id=$EMPOWER_CHAIN_ID --gas=auto
```

Withdraw rewards with commision
```
empowerd tx distribution withdraw-rewards $EMPOWER_VALOPER_ADDRESS --from=$WALLET --commission --chain-id=$EMPOWER_CHAIN_ID
```

### Validator management
Edit validator
```
empowerd tx staking edit-validator \
  --moniker=$NODENAME \
  --identity=<your_keybase_id> \
  --website="<your_website>" \
  --details="<your_validator_description>" \
  --chain-id=$EMPOWER_CHAIN_ID \
  --from=$WALLET
```

Unjail validator
```
empowerd tx slashing unjail \
  --broadcast-mode=block \
  --from=$WALLET \
  --chain-id=$EMPOWER_CHAIN_ID \
  --gas=auto
```

### Delete Node
```
sudo systemctl stop empowerd && \
sudo systemctl disable empowerd && \
rm /etc/systemd/system/empowerd.service && \
sudo systemctl daemon-reload && \
cd $HOME && \
rm -rf .empowerchain && \
rm -rf empowerchain && \
rm -rf $(which empowerd)
```

