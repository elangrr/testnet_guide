<p style="font-size:14px" align="right">
<a href="https://hetzner.cloud/?ref=tmLum9o8NxAI" target="_blank">Deploy your VPS using our referral link to get 20€ bonus <img src="https://user-images.githubusercontent.com/50621007/174612278-11716b2a-d662-487e-8085-3686278dd869.png" width="30"/></a>
</p>

<p style="font-size:14px" align="right">
<a href="https://github.com/elangrr/testnet_guide" target="_blank">More Guide Tutorials<img src="https://avatars.githubusercontent.com/u/34649601?v=4" width="30"/></a>
</p>

<p style="font-size:14px" align="right">
<a href="https://indonode.dev/" target="_blank">Visit my website <img src="https://avatars.githubusercontent.com/u/34649601?v=4" width="30"/></a>
</p>

<p align="center">
 <img height="200" height="auto" src="https://user-images.githubusercontent.com/34649601/212465601-af700240-f0a6-4fff-95ab-39d6fda3e8c0.png">

# Official Links
### [Official Document](https://docs.realio.network/validators/setup)
### [Realio Official Discord](https://discord.gg/YeAfZnd7dm)

# Explorer
### [Explorer](https://explorer.indonode.dev/realio/staking)

## Minimum Requirements 
- 2 or more physical CPU cores
- At least 160GB of SSD disk storage
- At least 4GB of memory (RAM)
- At least 120mbps network bandwidth

# Mars Testnet Node Guide (Custom Port 18)  
# [Manual Install](https://github.com/elangrr/testnet_guide/blob/main/realio/manual_install.md)



# Auto Install
```
wget -O realion.sh https://raw.githubusercontent.com/elangrr/testnet_guide/main/realio/realion.sh && chmod +x realion.sh && ./realion.sh
```

After install node run 
```
source $HOME/.bash_profile
```

### Create Wallet 
To create wallet you can create in the `CLI` or `Manual by running these commands`

To create new wallet use 
```
realio-networkd keys add wallet
```

To recover existing keys use 
```
realio-networkd keys add wallet --recover
```

To see current keys 
```
realio-networkd keys list
```

### Faucet
Ask one of the Admin in Discord server

### Create validator
After your node is synced, create validator

To check if your node is synced simply run
`curl http://localhost:18657/status sync_info "catching_up": false`

```
realio-networkd tx staking create-validator \
  --amount=1000000000000000000ario \
  --pubkey=$(realio-networkd tendermint show-validator) \
  --moniker="$MONIKER" \
  --chain-id=realionetwork_1110-2 \
  --commission-rate="0.10" \
  --commission-max-rate="0.20" \
  --commission-max-change-rate="0.1" \
  --min-self-delegation="1" \
  --fees 5000000000000000ario \
  --gas 800000 \
  --identity= \
  --website="" \
  --details="" \
  --from=wallet
```

## Usefull commands
### Service management
Check logs
```
journalctl -fu realio-networkd -o cat
```

Start service
```
sudo systemctl start realio-networkd
```

Stop service
```
sudo systemctl stop realio-networkd
```

Restart service
```
sudo systemctl restart realio-networkd
```

### Node info
Synchronization info
```
realio-networkd status 2>&1 | jq .SyncInfo
```

Validator info
```
realio-networkd status 2>&1 | jq .ValidatorInfo
```

Node info
```
realio-networkd status 2>&1 | jq .NodeInfo
```

Show node id
```
realio-networkd tendermint show-node-id
```

Get Node Peer
```
echo $(realio-networkd tendermint show-node-id)'@'$(curl -s ifconfig.me)':'$(cat $HOME/.realio-network/config/config.toml | sed -n '/Address to listen for incoming connection/{n;p;}' | sed 's/.*://; s/".*//')
```

Get Live Peer
```
curl -sS http://localhost:18657/net_info | jq -r '.result.peers[] | "\(.node_info.id)@\(.remote_ip):\(.node_info.listen_addr)"' | awk -F ':' '{print $1":"$(NF)}'
```

### Wallet operations
List of wallets
```
realio-networkd keys list
```

Recover wallet
```
realio-networkd keys add wallet --recover
```

Delete wallet
```
realio-networkd keys delete wallet
```

Get wallet balance
```
realio-networkd query bank balances <address>
```

Transfer funds
```
realio-networkd tx bank send <FROM ADDRESS> <TO_realio_WALLET_ADDRESS> 10000000ario
```

### Voting
```
realio-networkd tx gov vote 1 yes --from wallet --chain-id=realionetwork_1110-2
```

### Staking, Delegation and Rewards
Delegate Stake to your own validator
```
realio-networkd tx staking delegate $(realio-networkd keys show wallet --bech val -a) 1000000ario --from wallet --chain-id realionetwork_1110-2 --gas-adjustment 1.4 --gas auto --gas-prices 0.001ario -y
```

Delegate stake
```
realio-networkd tx staking delegate <realio valoper> 10000000ario --from=wallet --chain-id=realionetwork_1110-2 --gas=auto
```

Redelegate stake from validator to another validator
```
realio-networkd tx staking redelegate <srcValidatorAddress> <destValidatorAddress> 10000000ario --from=wallet --chain-id=realionetwork_1110-2 --gas=auto
```

Withdraw all rewards
```
realio-networkd tx distribution withdraw-all-rewards --from=wallet --chain-id=realionetwork_1110-2 --gas=auto
```

Withdraw rewards with commision
```
realio-networkd tx distribution withdraw-rewards <realio valoper> --from=wallet --commission --chain-id=realionetwork_1110-2
```

### Validator management
Edit validator
```
realio-networkd tx staking edit-validator \
  --moniker=$MONIKER \
  --identity=<your_keybase_id> \
  --website="<your_website>" \
  --details="<your_validator_description>" \
  --chain-id=realionetwork_1110-2 \
  --from=wallet
```

Unjail validator
```
realio-networkd tx slashing unjail \
  --broadcast-mode=block \
  --from=wallet \
  --chain-id=realionetwork_1110-2 \
  --gas=auto
```

### Delete node
```
sudo systemctl stop realio-networkd && \
sudo systemctl disable realio-networkd && \
rm /etc/systemd/system/realio-networkd.service && \
sudo systemctl daemon-reload && \
cd $HOME && \
rm -rf .realio-network && \
rm -rf $(which realio-networkd)
rm -rf realio-network
```
