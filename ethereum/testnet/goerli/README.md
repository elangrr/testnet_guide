<p style="font-size:14px" align="right">
<a href="https://github.com/elangrr/testnet_guide" target="_blank">More Guide Tutorials<img src="https://avatars.githubusercontent.com/u/34649601?v=4" width="30"/></a>
</p>

<p style="font-size:14px" align="right">
<a href="https://indonode.dev/" target="_blank">Visit my website <img src="https://avatars.githubusercontent.com/u/34649601?v=4" width="30"/></a>
</p>

<p align="center">
 <img height="200" height="auto" src="https://user-images.githubusercontent.com/34649601/206858367-c99a9a01-d00e-49ae-8fdd-366135b20931.png">



# Official Links
### [Official Document](https://ethereum.org/en/developers/docs/nodes-and-clients/run-a-node/#spinning-up-node)


## Requirements
### Minimum requirements
- CPU with 2+ cores
- 8 GB RAM
- 700GB free disk space
- 10+ MBit/s bandwidth

### Recommended specifications
- Fast CPU with 4+ cores
- 16 GB+ RAM
- Fast SSD with 1+TB
- 25+ MBit/s bandwidth

# Run Ethereum Node via ( GETH --> PRYSM --> BEACON )

Run as `root`
### Update firewall
```
apt install ufw
ufw allow 30303
ufw allow ssh
ufw allow 12000/udp
ufw allow 13000/tcp
ufw allow 8551
ufw enable
```

### Update depencies
```
sudo apt update
sudo apt upgrade
```

### Install Depenceis needed
```
apt install software-properties-common wget jq python3.8 python3-pip curl tar tmux htop net-tools clang pkg-config libssl-dev jq build-essential git make ncdu -y
```

### Install GO 
```
ver="1.19" && \
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz" && \
sudo rm -rf /usr/local/go && \
sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz" && \
rm "go$ver.linux-amd64.tar.gz" && \
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> $HOME/.bash_profile && \
source $HOME/.bash_profile && \
go version
```

### Download GETH
```
sudo add-apt-repository -y ppa:ethereum/ethereum
sudo apt-get update
sudo apt-get install ethereum
```

### Create GETH Service file
```
sudo tee /etc/systemd/system/geth.service > /dev/null <<EOF
[Unit]
Description=geth
After=network-online.target

[Service]
User=$USER
ExecStart=/usr/bin/geth --goerli --http --http.api eth,net,engine,admin --authrpc.jwtsecret /root/ethereum/consensus/prysm/jwt.hex
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
```

### Setup directory
```
cd $HOME
mkdir ethereum
cd ethereum/
mkdir consensus
mkdir execution
cd consensus/
```
### Download Prysm
```
mkdir prysm && cd prysm
curl https://raw.githubusercontent.com/prysmaticlabs/prysm/master/prysm.sh --output prysm.sh && chmod +x prysm.sh
```

Generate JWT file 
```
openssl rand -hex 32 | tr -d "\n" > "jwt.hex"
```

Download Goerli Genesis
```
wget https://github.com/eth-clients/eth2-networks/raw/master/shared/prater/genesis.ssz
```

### Run Beacon Node using Prysm
Create Service file 
```
sudo tee /etc/systemd/system/beacon.service > /dev/null <<EOF
[Unit]
Description=beacon
After=network-online.target

[Service]
User=$USER
ExecStart=/root/ethereum/consensus/prysm/prysm.sh beacon-chain --execution-endpoint=http://localhost:8551 --prater --jwt-secret=/root/ethereum/consensus/prysm/jwt.hex --genesis-state=/root/ethereum/consensus/prysm/genesis.ssz --suggested-fee-recipient=0x952295078a226bf40c8cb076c16e0e7229f77b28
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl restart geth
systemctl restart beacon
```

for the `--suggested-fee-recipient=` I used the `Blockswap` fees recipients for `Goerli Testnet Network`

Your beacon node will now begin syncing. This usually takes a couple days, but it can take longer depending on your network and hardware specs.

To check the logs 

for GETH : `journalctl -fu geth -o cat` 

for Beacon : `journalctl -fu beacon -o cat`

### Run validator Using Prysm
Download ETH CLI
```
cd $HOME
wget https://github.com/ethereum/staking-deposit-cli/releases/download/v2.3.0/staking_deposit-cli-76ed782-linux-amd64.tar.gz
tar -xzvf staking_deposit-cli-76ed782-linux-amd64.tar.gz
cd staking_deposit-cli-76ed782-linux-amd64/
```

To create new address run 
```
./deposit new-mnemonic --num_validators=1 --mnemonic_language=english --chain=prater
```

Copy the `validator_keys` folder to `consensus` folder

Run the following command to import your keystores, replacing `<YOUR_FOLDER_PATH>` with the full path to your `consensus/validator_keys` folder:
```
./prysm.sh validator accounts import --keys-dir=<YOUR_FOLDER_PATH> --prater
```

You’ll be prompted to specify a wallet directory twice. Provide the path to your `consensus` folder for both prompts. 

You should see `Successfully imported 1 accounts, view all of them by running accounts list` when your account has been successfully imported into Prysm.

Next, go to the [Goerli-Prater Launchpad’s deposit data upload page](https://goerli.launchpad.ethereum.org/en/overview) and upload your `deposit_data-*.json` file. You’ll be prompted to connect your wallet.

Someone should be able to give you the GöETH you need. You can then deposit `32 GöETH` into the Prater testnet’s deposit contract via the Launchpad page. 

Exercise extreme caution throughout this procedure - never send real ETH to the testnet deposit contract. 

Finally, run the following command to start your validator, replacing `<YOUR_FOLDER_PATH>` with the full path to your consensus folder:

Create Password File
```
echo '<my_password_goes_here>' > $HOME/.eth2validators/pass.txt
sudo chmod 600 $HOME/.eth2validators/pass.txt
```
change `<my_password_goes_here>` to your secure password

Create Service file 
```
sudo tee /etc/systemd/system/validator.service > /dev/null <<EOF
[Unit]
Description=eth validator service
Wants=network-online.target beacon-chain.service
After=network-online.target

[Service]
Type=simple
User=root
Restart=on-failure
ExecStart=/root/ethereum/consensus/prysm/prysm.sh validator --prater --wallet-dir=/root/.eth2validators/prysm-wallet-v2/ --accept-terms-of-use --wallet-password-file /root/.eth2validators/pass.txt


[Install]
WantedBy=multi-user.target
EOF


sudo systemctl daemon-reload
systemctl restart validator
```

to check validator logs `journalctl -fu validator -o cat`

## Cheat Sheets

### Check geth
Check your Geth execution node's sync status by running `geth attach` (IPC) or `geth attach http://localhost:8545` (HTTP) from a separate terminal. Then type `eth.syncing`. A sync status of `false` indicates that your node is fully synced.

### Check Geth version
Use `geth version` to check Geth's version

### Check Beacon Node Sync Status
Check your beacon node's sync status by running `curl http://localhost:3500/eth/v1/node/syncing | jq` from a separate terminal window. When you see `"is_syncing":false`

### Check Beacon node peer connectivity
`curl http://localhost:8080/healthz` , If you see `currentConnectionError: no contract code at given address`, your execution node may still be syncing. Otherwise, if you don't see any errors, your beacon node is connected to peers.


### Validator status
Paste your validator's public key (available in your `deposit_data-*.json` file) into a [Goerli-Prater blockchain explorer like beaconcha.in](https://prater.beaconcha.in/) to check the status of your validator.


