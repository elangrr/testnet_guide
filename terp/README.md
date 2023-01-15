<p style="font-size:14px" align="right">
<a href="https://hetzner.cloud/?ref=tmLum9o8NxAI" target="_blank">Deploy your VPS using our referral link to get 20€ bonus <img src="https://user-images.githubusercontent.com/50621007/174612278-11716b2a-d662-487e-8085-3686278dd869.png" width="30"/></a>
</p>

<p style="font-size:14px" align="right">
<a href="https://github.com/elangrr/testnet_guide" target="_blank">More Guide Tutorials<img src="https://avatars.githubusercontent.com/u/34649601?v=4" width="30"/></a>
</p>

<p style="font-size:14px" align="right">
<a href="https://indonode.dev/" target="_blank">Visit my website <img src="https://avatars.githubusercontent.com/u/34649601?v=4" width="30"/></a>

<p align="center">
 <img height="200" height="auto" src="https://user-images.githubusercontent.com/34649601/212522416-fb05a26b-b81b-4c10-9e1d-43c4965db650.png">


# Official Links
### [Official Document](https://docs.terp.network/)
### [Terp Official Discord](https://discord.gg/qFfUyNZnPG)

# Explorer
### [Explorer](https://explorer.indonode.dev/terp/staking)

## Minimum Requirements 
- 3 or more physical CPU cores
- At least 160GB of SSD disk storage
- At least 4GB of memory (RAM)
- At least 120mbps network bandwidth
  
# Terp Testnet Node Guide (Custom Port 32)  
# [Manual Install](https://github.com/elangrr/testnet_guide/blob/main/terp/manual_install.md)


# Auto Install
```
wget -O ter.sh https://raw.githubusercontent.com/elangrr/testnet_guide/main/terp/ter.sh && chmod +x ter.sh && ./ter.sh
```

After install node run 
```
source $HOME/.bash_profile
```

### Create Wallet 
To create wallet you can create in the `CLI` or `Manual by running these commands`

To create new wallet use 
```
terpd keys add wallet
```

To recover existing keys use 
```
terpd keys add wallet --recover
```

To see current keys 
```
terpd keys list
```

### Faucet
Ask one of the Admin in Discord server

### Create validator
After your node is synced, create validator

To check if your node is synced simply run
`curl http://localhost:32657/status sync_info "catching_up": false`

```
terpd tx staking create-validator \
--amount=1000000uterpx \
--pubkey=$(terpd tendermint show-validator) \
--moniker="$MONIKER" \
--chain-id=athena-3 \
--commission-rate=0.1 \
--commission-max-rate=0.2 \
--commission-max-change-rate=0.05 \
--min-self-delegation=1 \
--from=wallet \
--identity= \
--details="" \
--website="" \
--gas-adjustment=1.4 \
--gas=auto \
--gas-prices=0.001upersyx \
-y
```

## Usefull commands
### Service management
Check logs
```
journalctl -fu terpd -o cat
```

Start service
```
sudo systemctl start terpd
```

Stop service
```
sudo systemctl stop terpd
```

Restart service
```
sudo systemctl restart terpd
```

### Node info
Synchronization info
```
terpd status 2>&1 | jq .SyncInfo
```

Validator info
```
terpd status 2>&1 | jq .ValidatorInfo
```

Node info
```
terpd status 2>&1 | jq .NodeInfo
```

Show node id
```
terpd tendermint show-node-id
```

Get Node Peer
```
echo $(terpd tendermint show-node-id)'@'$(curl -s ifconfig.me)':'$(cat $HOME/.terp/config/config.toml | sed -n '/Address to listen for incoming connection/{n;p;}' | sed 's/.*://; s/".*//')
```

Get Live Peer
```
curl -sS http://localhost:32657/net_info | jq -r '.result.peers[] | "\(.node_info.id)@\(.remote_ip):\(.node_info.listen_addr)"' | awk -F ':' '{print $1":"$(NF)}'
```

### Wallet operations
List of wallets
```
terpd keys list
```

Recover wallet
```
terpd keys add wallet --recover
```

Delete wallet
```
terpd keys delete wallet
```

Get wallet balance
```
terpd query bank balances <address>
```

Transfer funds
```
terpd tx bank send <FROM ADDRESS> <TO_terp_WALLET_ADDRESS> 10000000upersyx
```

### Voting
```
terpd tx gov vote 1 yes --from wallet --chain-id=athena-3
```

### Staking, Delegation and Rewards
Delegate Stake to your own validator
```
terpd tx staking delegate $(terpd keys show wallet --bech val -a) 1000000upersyx --from wallet --chain-id athena-3 --gas-adjustment 1.4 --gas auto --gas-prices 0.001upersyx -y
```

Delegate stake
```
terpd tx staking delegate <terp valoper> 10000000upersyx --from=wallet --chain-id=athena-3 --gas=auto
```

Redelegate stake from validator to another validator
```
terpd tx staking redelegate <srcValidatorAddress> <destValidatorAddress> 10000000upersyx --from=wallet --chain-id=athena-3 --gas=auto
```

Withdraw all rewards
```
terpd tx distribution withdraw-all-rewards --from=wallet --chain-id=athena-3 --gas=auto
```

Withdraw rewards with commision
```
terpd tx distribution withdraw-rewards <terp valoper> --from=wallet --commission --chain-id=athena-3
```

### Validator management
Edit validator
```
terpd tx staking edit-validator \
  --moniker=$MONIKER \
  --identity=<your_keybase_id> \
  --website="<your_website>" \
  --details="<your_validator_description>" \
  --chain-id=athena-3 \
  --from=wallet
```

Unjail validator
```
terpd tx slashing unjail \
  --broadcast-mode=block \
  --from=wallet \
  --chain-id=athena-3 \
  --gas=auto
```

### Delete node
```
sudo systemctl stop terpd && \
sudo systemctl disable terpd && \
rm /etc/systemd/system/terpd.service && \
sudo systemctl daemon-reload && \
cd $HOME && \
rm -rf .terp && \
rm -rf $(which terpd)
rm -rf terp
```
