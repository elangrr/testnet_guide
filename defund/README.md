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

# Defund Testnet Node Guide (Custom Port 19)  
# [Manual Install](https://github.com/elangrr/testnet_guide/blob/main/defund/manual_install.md)


# Auto Install
```
wget -O def.sh https://raw.githubusercontent.com/elangrr/testnet_guide/main/defund/def.sh && chmod +x def.sh && ./def.sh
```

After install node run 
```
source $HOME/.bash_profile
```

### Create Wallet 
To create wallet you can create in the `CLI` or `Manual by running these commands`

To create new wallet use 
```
defundd keys add wallet
```

To recover existing keys use 
```
defundd keys add wallet --recover
```

To see current keys 
```
defundd keys list
```

### Faucet
Ask one of the Admin in Discord server

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
