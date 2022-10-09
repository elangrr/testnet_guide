# Migrate your validator to another machine
## What you need
- priv_validator_key.json from the old machine
- seed phrase of your wallet

### 1. Run a new full node on a new machine
To setup full node you can follow my guide [MUN node setup for testnet](https://github.com/elangrr/testnet_guide/blob/main/mun/README.md)

### 2. Confirm that you have the recovery seed phrase information 
#### To backup your key
```
mund keys export mykey
```

#### To get list of keys
```
mund keys list
```

### 3. Recover the active key of the old machine on the new machine

#### This can be done with the mnemonics
```
mund keys add $WALLET --recover
```

### 4. Wait for the new full node on the new machine to finish catching-up

#### To check synchronization status
```
mund status 2>&1 | jq .SyncInfo
```
> _`catching_up` should be equal to `false`_

### 5. After the new node has caught-up, stop the old validator node

> _To prevent double signing, you should stop the validator node before stopping the new full node to ensure the new node is at a greater block height than the validator node_
> _If the new node is behind the old validator node, then you may double-sign blocks_

#### Stop and disable service on old machine
```
sudo systemctl stop mund
sudo systemctl disable mund
```
> _The validator should start missing blocks at this point_

### 6. Stop service on new machine
```
sudo systemctl stop mund
```

### 7. Move the validator's private key from the old machine to the new machine
#### Private key is located in: `~/.mun/config/priv_validator_key.json`

> _After being copied, the key `priv_validator_key.json` should then be removed from the OLD NODE'S config directory to prevent double-signing if the node were to start back up_
```
sudo mv ~/.mun/config/priv_validator_key.json ~/.mun/bak_priv_validator_key.json
```

### 8. Start service on a new validator node
```
sudo systemctl start mund
```
> _The new node should start signing blocks once caught-up_

### 9. Make sure your validator is not jailed
#### To unjail your validator
```
mund tx slashing unjail --chain-id $MUN_CHAIN_ID --from $WALLET --gas=auto -y
```

### 10. After you ensure your validator is producing blocks and is healthy you can shut down old validator server
