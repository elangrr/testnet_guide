<p style="font-size:14px" align="right">
<a href="https://github.com/elangrr/testnet_guide" target="_blank">More Guide Tutorials<img src="https://avatars.githubusercontent.com/u/34649601?v=4" width="30"/></a>
</p>

<p style="font-size:14px" align="right">
<a href="https://indonode.dev/" target="_blank">Visit my website <img src="https://avatars.githubusercontent.com/u/34649601?v=4" width="30"/></a>
</p>

<p align="center">
 <img height="200" height="auto" src="https://user-images.githubusercontent.com/34649601/209423077-9a15c401-77b2-4002-b75f-13d948f31c7d.png">


# Official Links
### [Official Document](https://docs.humans.zone/dev/cli/humansd-binary.html#)
### [Humans Ai Official Discord](https://discord.gg/humansdotai)

# Explorer
### [KJ Explorer](https://explorer.kjnodes.com/defund/staking)

## Minimum Requirements 
- 4 or more physical CPU cores
- At least 120GB of SSD disk storage
- At least 8GB of memory (RAM)
- At least 100mbps network bandwidth

# Humans Node Guide (Custom Port 13)  
# Auto Install
```
wget -O hum https://raw.githubusercontent.com/elangrr/testnet_guide/main/humans/hum.sh && chmod +x hum && ./hum
```

After install node run 
```
source $HOME/.bash_profile
```

### Create Wallet 
To create wallet you can create in the CLI or manual by running these commands

To create new wallet use 
```
humansd keys add wallet
```

To recover existing keys use 
```
humansd keys add wallet --recover
```

To see current keys 
```
humansd keys list
```

### Ask for faucet in Discord

### Create validator
After your node is synced, create validator

To check if your node is synced simply run
`curl http://localhost:13657/status sync_info "catching_up": false`

```
humansd tx staking create-validator \
  --amount 10000000uheart \
  --from wallet \
  --commission-max-change-rate "0.01" \
  --commission-max-rate "0.2" \
  --commission-rate "0.07" \
  --min-self-delegation "1" \
  --pubkey  $(humansd tendermint show-validator) \
  --moniker $MONIKER \
  --chain-id testnet-1
```

## Usefull commands
### Service management
Check logs
```
journalctl -fu humansd -o cat
```

Start service
```
sudo systemctl start humansd
```

Stop service
```
sudo systemctl stop humansd
```

Restart service
```
sudo systemctl restart humansd
```

### Node info
Synchronization info
```
humansd status 2>&1 | jq .SyncInfo
```

Validator info
```
humansd status 2>&1 | jq .ValidatorInfo
```

Node info
```
humansd status 2>&1 | jq .NodeInfo
```

Show node id
```
humansd tendermint show-node-id
```

### Wallet operations
List of wallets
```
humansd keys list
```

Recover wallet
```
humansd keys add wallet --recover
```

Delete wallet
```
humansd keys delete wallet
```

Get wallet balance
```
humansd query bank balances <address>
```

Transfer funds
```
humansd tx bank send <FROM ADDRESS> <TO_defund_WALLET_ADDRESS> 10000000ufetf
```

### Voting
```
humansd tx gov vote 1 yes --from wallet --chain-id=testnet-1
```

### Staking, Delegation and Rewards
Delegate stake
```
humansd tx staking delegate <defund valoper> 10000000ufetf --from=wallet --chain-id=testnet-1 --gas=auto
```

Redelegate stake from validator to another validator
```
humansd tx staking redelegate <srcValidatorAddress> <destValidatorAddress> 10000000ufetf --from=wallet --chain-id=testnet-1 --gas=auto
```

Withdraw all rewards
```
humansd tx distribution withdraw-all-rewards --from=wallet --chain-id=testnet-1 --gas=auto
```

Withdraw rewards with commision
```
humansd tx distribution withdraw-rewards <defund valoper> --from=wallet --commission --chain-id=testnet-1
```

### Validator management
Edit validator
```
humansd tx staking edit-validator \
  --moniker=$MONIKER \
  --identity=<your_keybase_id> \
  --website="<your_website>" \
  --details="<your_validator_description>" \
  --chain-id=testnet-1 \
  --from=wallet
```

Unjail validator
```
humansd tx slashing unjail \
  --broadcast-mode=block \
  --from=wallet \
  --chain-id=testnet-1 \
  --gas=auto
```

### Delete node
```
sudo systemctl stop humansd && \
sudo systemctl disable humansd && \
rm /etc/systemd/system/humansd.service && \
sudo systemctl daemon-reload && \
cd $HOME && \
rm -rf .humans && \
rm -rf $(which humansd)
```
