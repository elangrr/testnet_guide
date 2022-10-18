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

## Automatic Install ##
```
wget -O point.sh https://raw.githubusercontent.com/elangrr/testnet_guide/main/point/point.sh && chmod +x point.sh && ./point.sh
```
## After install please Load Variable! (Post Installation)
```
source $HOME/.bash_profile
```

### Update Binary (OPTIONAL)
Check version by typing `pointd version` if it shows version lower than v.0.0.3 then you need to update or else dont.
```
cd $HOME
rm -rf point-chain
git clone https://github.com/pointnetwork/point-chain && cd point-chain
git fetch --all
git checkout tags/v0.0.3
make install
sudo systemctl restart pointd && sudo journalctl -u pointd -f -o cat
```

### Check info Sync
Note : You have to synced to the lastest block , check the sync status with this command
```
pointd status 2>&1 | jq .SyncInfo
```

## Create Wallet
Create validator wallet using this command, Dont forget to save the Mnemonic!
```
pointd keys add $VALIDATORKEY 
```
(OPTIONAL) To recover using your previous saved wallet
```
pointd keys add $VALIDATORKEY --recover
```
To get current list of wallet
```
pointd keys list 
```
To get private key of validator wallet (SAVE IT SOMEWHERE SAFE!)
```
pointd keys unsafe-export-eth-key validatorkey --keyring-backend file
```
## Safe wallet Info
```
POINTD_WALLET_ADDRESS=$(pointd keys show $VALIDATORKEY -a)
POINTD_VALOPER_ADDRESS=$(pointd keys show $VALIDATORKEY --bech val -a)
echo 'export POINTD_WALLET_ADDRESS='${POINTD_WALLET_ADDRESS} >> $HOME/.bash_profile
echo 'export POINTD_VALOPER_ADDRESS='${POITD_VALOPER_ADDRESS} >> $HOME/.bash_profile
source $HOME/.bash_profile
```
## Fund your wallet
Wait for Point sent to your address

## Sending your first transaction
### Add custom network
Now while you're waiting for the node to sync, you need to send funds to your validator address. You will need to import a custom network into your wallet, e.g. for Metamask:

```
Network Title: Point
RPC URL: https://rpc-mainnet-1.point.space/
Chain ID: 10687
SYMBOL: POINT
```
### Find out which address is your validator wallet
point has two wallet formats: Cosmos format, and Ethereum format. Cosmos format starts with `point` prefix, and Ethereum format starts with `0x`. Most people don't need to know about Cosmos format, but validators should have a way to change from one to another.

Run 
```
pointd keys list
```
you will see a list of keys attached to your node. Look at the one which has the name `validatorkey`, and note its address (it should be in Cosmos format and start with `point` prefix).

(In most cases it is not needed, but if something goes wrong and if you ever want to import your validator wallet in your Metamask you will need the private key. You can get it with this command: 
```
pointd keys unsafe-export-eth-key validatorkey --keyring-backend file
```

Use this tool to convert it to Ethereum format: https://pointnetwork.io/converter.html

This is your validator address in Ethereum format.

### Fund the validator
Finally, send enough POINT to your validator address

## Create Validator
Before creating validator please make sure you have the funds already in your wallet
To check wallet balance :
```
pointd query bank balances $POINT_WALLET_ADDRESS
```
To create a validator with 1000point delegation use this command below :

```
pointd tx staking create-validator \
--amount=1000000000000000000000apoint \
--pubkey=$(pointd tendermint show-validator) \
--moniker=$NODENAME \
--chain-id=$POINT_CHAIN_ID \
--commission-rate="0.10" \
--commission-max-rate="0.20" \
--commission-max-change-rate="0.01" \
--min-self-delegation="1" \
--gas="400000" \
--gas-prices="0.025apoint" \
--from=validatorkey \
```
NOTE : 1000000000000000000000apoint is 1000 Point

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
pointd tx staking delegate <point valoper> 1000000000000000000000apoint --from=validatorkey --chain-id=$POINT_CHAIN_ID --gas-prices=0.025apoint --gas=400000 
```
Change `<point valoper>` to your valoper address 

To Withdraw all rewards without commision
```
pointd tx distribution withdraw-all-rewards --from=validatorkey --chain-id $POINT_CHAIN_ID --gas-prices=0.025apoint
```
To Withdraw rewards with commision
```
pointd tx distribution withdraw-rewards <point val> --from=validatorkey --commission --chain-id $POINT_CHAIN_ID --gas-prices=0.025apoint
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
pointd tx slashing unjail --from=validatorkey --chain-id=$POINT_CHAIN_ID --gas-prices=0.025apoint
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

  
