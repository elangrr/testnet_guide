<p style="font-size:14px" align="right">
<a href="https://github.com/elangrr/testnet_manuals" target="_blank">More Guide Tutorials<img src="https://avatars.githubusercontent.com/u/34649601?v=4" width="30"/></a>
</p>

<p style="font-size:14px" align="right">
<a href="https://indonode.dev/" target="_blank">Visit my website <img src="https://avatars.githubusercontent.com/u/34649601?v=4" width="30"/></a>
</p>

</p>
<p style="font-size:14px" align="right">
<a href="https://discord.gg/gru6MuGPgP" target="_blank">Join NodeX Capital Network Discord<img src="https://user-images.githubusercontent.com/50621007/176236430-53b0f4de-41ff-41f7-92a1-4233890a90c8.png" width="30"/></a>
</p>

<p align="center">
  <img height="150" height="auto" src="https://pbs.twimg.com/profile_images/1516984530413887488/9sqwHPD7_400x400.jpg">
</p>


## Auto Install Gentx
```
wget -O stateset-gentx.sh https://raw.githubusercontent.com/elangrr/testnet_guide/main/stateset/stateset-gentx.sh && chmod +x stateset-gentx.sh && ./stateset-gentx.sh
```
## Post Installation (Load variable)
```
source $HOME/.bash_profile
```

## Set your wallet genesis
```
WALLET_ADDRESS=$(statesetd keys show $WALLET -a)
statesetd add-genesis-account $WALLET_ADDRESS 10000000000ustate
```

## Create wallet
Create new wallet with this command
```
statesetd keys add $WALLET
```

Or recover your existing wallet 
```
statesetd keys add $WALLET --recover
```

## Create Gentx
```
statesetd gentx $WALLET 9000000000ustate \
--chain-id $STATESET_CHAIN_ID \
--moniker=$NODENAME \
--commission-max-change-rate=0.01 \
--commission-max-rate=1.0 \
--commission-rate=0.05 \
--identity="" \
--website="" \
--details="" \
--min-self-delegation=100000000000
```

## Things you have to Backup
- `24 word mnemonic` of your generated wallet
- contents of `$HOME/.stateset/config/*`

## Submit your PR
- Copy the contents of ${HOME}/.stateset/config/gentx/gentx-XXXXXXXX.json.
- Fork https://github.com/stateset/networks
- Create a file gentx-<VALIDATOR_NAME>.json under the testnets/stateset-1-testnet/gentx/ folder in the forked repo, paste the copied text into the file.
- Create a Pull Request to the main branch of the repository
- Await further instructions!
