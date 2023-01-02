<p style="font-size:14px" align="right">
<a href="https://github.com/elangrr/testnet_guide" target="_blank">More Guide Tutorials<img src="https://avatars.githubusercontent.com/u/34649601?v=4" width="30"/></a>
</p>

<p style="font-size:14px" align="right">
<a href="https://indonode.dev/" target="_blank">Visit my website <img src="https://avatars.githubusercontent.com/u/34649601?v=4" width="30"/></a>
</p>

<p align="center">
 <img height="200" height="auto" src="https://user-images.githubusercontent.com/34649601/210251979-8dfab2c0-e9dd-4d62-81ae-8e78e24f2209.png">


# Official Links
### [Official Document](https://docs.gitopia.com/validator-overview)
### [Gitopia Official Discord](https://discord.gg/ytz9jtwa2E)

# Explorer
### [Explorer](https://explorer.planq.network/gitopia-janus-testnet-2/staking)

## Minimum Requirements 
- 4 or more physical CPU cores
- At least 160GB of SSD disk storage
- At least 8GB of memory (RAM)
- At least 120mbps network bandwidth


# Gitopia Mainnet Node Guide (Custom Port 16)  
# [Manual Install](https://github.com/elangrr/testnet_guide/blob/main/gitopia/manual_install.md)


### Download Git Remote Gitopia
```
curl https://get.gitopia.com | bash
``` 

`If you are facing an error saying` : `mv: rename ./git-remote-gitopia to /usr/local/bin/git-remote-gitopia: Permission denied ============ Error: mv failed`

Run this command 
```
sudo mv /tmp/tmpinstalldir/git-remote-gitopia /usr/local/bin/
``` 

# Auto Install
```
wget -O git.sh https://raw.githubusercontent.com/elangrr/testnet_guide/main/gitopia/git.sh && chmod +x git.sh && ./git.sh
```

After install node run 
```
source $HOME/.bash_profile
```

### Create Wallet 
To create wallet you can create in the CLI or manual by running these commands

To create new wallet use 
```
gitopiad keys add wallet
```

To recover existing keys use 
```
gitopiad keys add wallet --recover
```

To see current keys 
```
gitopiad keys list
```

### Ask for faucet in Discord

### Create validator
After your node is synced, create validator

To check if your node is synced simply run
`curl http://localhost:16657/status sync_info "catching_up": false`

```
gitopiad tx staking create-validator \
--amount=1000000utlore \
--pubkey=$(gitopiad tendermint show-validator) \
--moniker="YOUR_MONIKER_NAME" \
--identity="YOUR_KEYBASE_ID" \
--details="YOUR_DETAILS" \
--website="YOUR_WEBSITE_URL" \
--chain-id=gitopia-janus-testnet-2 \
--commission-rate=0.05 \
--commission-max-rate=0.20 \
--commission-max-change-rate=0.01 \
--min-self-delegation=1 \
--from=wallet \
--gas-adjustment=1.4 \
--gas=auto \
--gas-prices=0.001utlore \
-y
```

## Usefull commands
### Service management
Check logs
```
journalctl -fu gitopiad -o cat
```

Start service
```
sudo systemctl start gitopiad
```

Stop service
```
sudo systemctl stop gitopiad
```

Restart service
```
sudo systemctl restart gitopiad
```

### Node info
Synchronization info
```
gitopiad status 2>&1 | jq .SyncInfo
```

Validator info
```
gitopiad status 2>&1 | jq .ValidatorInfo
```

Node info
```
gitopiad status 2>&1 | jq .NodeInfo
```

Show node id
```
gitopiad tendermint show-node-id
```

### Wallet operations
List of wallets
```
gitopiad keys list
```

Recover wallet
```
gitopiad keys add wallet --recover
```

Delete wallet
```
gitopiad keys delete wallet
```

Get wallet balance
```
gitopiad query bank balances <address>
```

Transfer funds
```
gitopiad tx bank send <FROM ADDRESS> <TO_gitopia_WALLET_ADDRESS> 10000000utlore
```

### Voting
```
gitopiad tx gov vote 1 yes --from wallet --chain-id=gitopia-janus-testnet-2
```

### Staking, Delegation and Rewards
Delegate stake
```
gitopiad tx staking delegate <gitopia valoper> 10000000utlore --from=wallet --chain-id=gitopia-janus-testnet-2 --gas=auto
```

Redelegate stake from validator to another validator
```
gitopiad tx staking redelegate <srcValidatorAddress> <destValidatorAddress> 10000000utlore --from=wallet --chain-id=gitopia-janus-testnet-2 --gas=auto
```

Withdraw all rewards
```
gitopiad tx distribution withdraw-all-rewards --from=wallet --chain-id=gitopia-janus-testnet-2 --gas=auto
```

Withdraw rewards with commision
```
gitopiad tx distribution withdraw-rewards <gitopia valoper> --from=wallet --commission --chain-id=gitopia-janus-testnet-2
```

### Validator management
Edit validator
```
gitopiad tx staking edit-validator \
  --moniker=$MONIKER \
  --identity=<your_keybase_id> \
  --website="<your_website>" \
  --details="<your_validator_description>" \
  --chain-id=gitopia-janus-testnet-2 \
  --from=wallet
```

Unjail validator
```
gitopiad tx slashing unjail \
  --broadcast-mode=block \
  --from=wallet \
  --chain-id=gitopia-janus-testnet-2 \
  --gas=auto
```

### Delete node
```
sudo systemctl stop gitopiad && \
sudo systemctl disable gitopiad && \
rm /etc/systemd/system/gitopiad.service && \
sudo systemctl daemon-reload && \
cd $HOME && \
rm -rf .gitopiad && \
rm -rf $(which gitopiad)
```
