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
 <img height="200" height="auto" src="https://user-images.githubusercontent.com/34649601/212463121-6d4c05af-c46b-4ca5-8a1b-a84169dcc2b2.png">


# Official Links
### [Official Document](https://validatordocs.marsprotocol.io/TfYZfjcaUzFmiAkWDf7P/infrastructure/validators)
### [Mars Official Discord](https://discord.gg/marsprotocol)

# Explorer
### [Explorer](https://explorer.indonode.dev/mars/staking)

## Minimum Requirements 
- 4 or more physical CPU cores
- At least 160GB of SSD disk storage
- At least 8GB of memory (RAM)
- At least 120mbps network bandwidth


# Mars Testnet Node Guide (Custom Port 20)  
# [Manual Install](https://github.com/elangrr/testnet_guide/blob/main/mars/manual_install.md)



# Auto Install
```
wget -O mar.sh https://raw.githubusercontent.com/elangrr/testnet_guide/main/mars/mar.sh && chmod +x mar.sh && ./mar.sh
```

After install node run 
```
source $HOME/.bash_profile
```

### Create Wallet 
To create wallet you can create in the `CLI` or `Manual by running these commands`

To create new wallet use 
```
marsd keys add wallet
```

To recover existing keys use 
```
marsd keys add wallet --recover
```

To see current keys 
```
marsd keys list
```

### Create validator
After your node is synced, create validator

To check if your node is synced simply run
`curl http://localhost:20657/status sync_info "catching_up": false`

```
marsd tx staking create-validator \
  --amount 1000000umars \
  --from wallet \
  --commission-max-change-rate "0.1" \
  --commission-max-rate "0.2" \
  --commission-rate "0.1" \
  --min-self-delegation "1" \
  --pubkey $(marsd tendermint show-validator) \
  --moniker $MONIKER \
  --chain-id mars-1 \
  --identity="" \
  --details="" \
  --website="" -y
```

## Usefull commands
### Service management
Check logs
```
journalctl -fu marsd -o cat
```

Start service
```
sudo systemctl start marsd
```

Stop service
```
sudo systemctl stop marsd
```

Restart service
```
sudo systemctl restart marsd
```

### Node info
Synchronization info
```
marsd status 2>&1 | jq .SyncInfo
```

Validator info
```
marsd status 2>&1 | jq .ValidatorInfo
```

Node info
```
marsd status 2>&1 | jq .NodeInfo
```

Show node id
```
marsd tendermint show-node-id
```

### Wallet operations
List of wallets
```
marsd keys list
```

Recover wallet
```
marsd keys add wallet --recover
```

Delete wallet
```
marsd keys delete wallet
```

Get wallet balance
```
marsd query bank balances <address>
```

Transfer funds
```
marsd tx bank send <FROM ADDRESS> <TO_mars_WALLET_ADDRESS> 10000000umars
```

### Voting
```
marsd tx gov vote 1 yes --from wallet --chain-id=mars-1
```

### Staking, Delegation and Rewards
Delegate stake
```
marsd tx staking delegate <mars valoper> 10000000umars --from=wallet --chain-id=mars-1 --gas=auto
```

Redelegate stake from validator to another validator
```
marsd tx staking redelegate <srcValidatorAddress> <destValidatorAddress> 10000000umars --from=wallet --chain-id=mars-1 --gas=auto
```

Withdraw all rewards
```
marsd tx distribution withdraw-all-rewards --from=wallet --chain-id=mars-1 --gas=auto
```

Withdraw rewards with commision
```
marsd tx distribution withdraw-rewards <mars valoper> --from=wallet --commission --chain-id=mars-1
```

### Validator management
Edit validator
```
marsd tx staking edit-validator \
  --moniker=$MONIKER \
  --identity=<your_keybase_id> \
  --website="<your_website>" \
  --details="<your_validator_description>" \
  --chain-id=mars-1 \
  --from=wallet
```

Unjail validator
```
marsd tx slashing unjail \
  --broadcast-mode=block \
  --from=wallet \
  --chain-id=mars-1 \
  --gas=auto
```

### Delete node
```
sudo systemctl stop marsd && \
sudo systemctl disable marsd && \
rm /etc/systemd/system/marsd.service && \
sudo systemctl daemon-reload && \
cd $HOME && \
rm -rf .marsd && \
rm -rf $(which marsd)
```
