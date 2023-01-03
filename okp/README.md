<p style="font-size:14px" align="right">
<a href="https://github.com/elangrr/testnet_guide" target="_blank">More Guide Tutorials<img src="https://avatars.githubusercontent.com/u/34649601?v=4" width="30"/></a>
</p>

<p style="font-size:14px" align="right">
<a href="https://indonode.dev/" target="_blank">Visit my website <img src="https://avatars.githubusercontent.com/u/34649601?v=4" width="30"/></a>
</p>

<p align="center">
 <img height="100" height="auto" src="https://user-images.githubusercontent.com/34649601/197785294-543d0ae0-ec0e-44c1-9b24-a631ef598967.png">


# Official Links
### [Official Document](https://github.com/okp4)
### [OKP4 Official Discord](https://discord.gg/9VRwHvTN4w)

# Explorer
## [Explorer](https://explorer.bccnodes.com/okp4/staking)

## Minimum Requirements 
- 4 or more physical CPU cores
- At least 100GB of SSD disk storage
- At least 8GB of memory (RAM)
- At least 500mbps network bandwidth

# Install Node Guide

### Update Packages and Depencies
```
sudo apt update && sudo apt upgrade -y
```

Install Depencies
```
sudo apt install curl tar wget tmux htop net-tools clang pkg-config libssl-dev jq build-essential git make ncdu -y
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

### Download binaries
```
cd $HOME
git clone https://github.com/okp4/okp4d.git
cd okp4d
make install
```

### Init 
```
okp4d init <moniker> --chain-id okp4-nemeton
```
Change `<moniker>` to your moniker

### Create wallet
To create new wallet use 
```
okp4d keys add <wallet>
```
Change `<wallet>` to your wallet name

To recover existing keys use 
```
okp4d keys add <wallet> --recover
```
Change `<wallet>` to your wallet name

To see current keys 
```
okp4d keys list
```

### Download genesis file
```
wget -qO $HOME/.okp4d/config/genesis.json "https://raw.githubusercontent.com/okp4/networks/main/chains/nemeton/genesis.json"
```

### Set minimum gas price , seeds , and peers
```
sed -i.bak -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.0uknow\"/;" ~/.okp4d/config/app.toml
peers="994c9398e55947b2f1f45f33fbdbffcbcad655db@okp4-testnet.nodejumper.io:29656,370a5d94910f2367ce15c7af07b4a4f552824085@138.68.158.147:26656,671148ff955125a7201621cbf46653365470ea42@194.163.177.203:26656,52b385e6eed8bd92974a13fb02e7bb30da3791c2@37.230.114.114:26656,0007478807ab460738faac0758d94bdabeffd5d9@167.235.143.135:26656,6401459caad72c00fcb6704149dbe7025213281c@54.82.98.80:26656,9aad7337869f0f3caf5744d0679859670316f381@65.108.63.58:26656,2bfd405e8f0f176428e2127f98b5ec53164ae1f0@142.132.149.118:26656,b8fddd530b2d8347212615b6a68c447aba0aed64@161.35.37.194:26656,5c5b4e55c3af67875efba1b78fbeee77db54cef5@88.198.39.43:26776,bbf1fb5c94a9938a09af845b8cc89cac69257e33@185.202.238.254:26656,38db262effc2a904a0a902edfb99c55f6825edd8@52.231.156.226:26656,9917f412470344841e913415a5ea5da9da96a8fa@65.108.238.217:11014,92a51dc2424d5d19412fa1c1fcafb8af3b5c4137@77.51.200.79:26656,75d27d10f38155f2ffbcd89b7323badf4f3c7baf@65.108.253.94:26656,4b2e5c9baa158478f3e76dc2af35082b8cc4eb25@46.101.9.115:26656,394ee378f82a2c7e73dbb601b4e266d3f5185b47@65.108.124.54:37656,33cdd436b0dfaefb9fe9f834330ccbc0510120c3@5.161.54.117:26656,5fc8c51583a51477114d7df0e553b02096e2c860@161.35.168.89:26656,ad3fc9dba2defa0618d8821f93510c3682d7eb45@161.97.73.102:26656,9a6164543754d30077d2b2834dfa096b8a8a45b1@45.88.188.27:26656,43f1673b5dba00c921abebe71fd760483a1be506@154.53.52.32:36656,b30bb30eb86cd3964846f1e93acdb80d66394e32@34.135.192.16:26656,612aa2378a2741dcc423263bba6426946e2f0da7@137.184.53.242:26656,dd4cdfde3788c9f6387ea7f32ecacb0a8a4932e7@65.21.247.135:26656,2bdac5e68872b28fed6a3ae114612bfe643c25c9@38.242.146.53:26656,f5263e4ab184f6990aacfaa5388a4cb6c7f6dd1c@45.85.249.116:26656,b800cd6918d9cb7c769bf42fb257ccaef7b571b0@65.108.230.161:11156,9e3109ba10d8cdb18d37dde787665ad1b38a85ed@65.108.235.107:12656,81cf0d0ae52dc92f1a0f89c306a37ae2b57cffe8@20.243.106.99:26656,8a6f55d50bb1b22483ae40ddd19d40486f720c42@5.161.93.248:26656,e488d1126edce82f9faa68f201811df6d2006d8e@38.242.244.72:26656,f27cfc89e60166c4dcb859710a5d12051fb20fbd@154.12.225.88:26656,c3e1646029109c374bedb4c1737c86a8d389a419@146.190.209.11:26656,2590f28592a97137de0b6f68043225e2890054b0@65.108.229.225:37656,4d3c89d534f0e97cc00cbfc63bd427d447812dc9@154.53.59.87:36656,0b7a7bb8251ab238bf292911055cd752138546de@194.5.152.172:26656,5dd460566b63d929fc8dd1e1ae52c9a26920fab3@162.55.43.133:26656,7da790c663d678cb064ff4fba04556dcf18bda2c@65.109.70.23:17656,7447f19178cbb41330bf7112a1b2e17ae6007071@199.204.45.15:2456,270a714b6ea789d9a6472f158118043e643a5491@77.232.37.67:26656,2911ca079d686d75fea411e5dea83fb305269f93@116.202.161.165:27656,ee16105fc680d8690c395cee8f01456464a09b11@5.161.72.10:26656,aa5cc52860381e60f38e88fc3c7f47e04078eaf4@45.87.104.113:61656,8db12a66e6381fad19b3d8d96cc9371ba7e2ff25@38.242.247.183:26656,16a604f8433df064bfa9c958c20dde16d9f2f0ec@165.227.236.144:26656,cc15ceec925e511f9f660deb3671770341abee18@86.48.20.122:26656,080f51ee75de47fa74aa35b87cc46051da47b20b@165.22.203.183:26656,873851ddeee527352fc16802c866e41cd36565d8@65.109.30.197:22656,4d1932884301c338810fe47b150f8a4149e02937@114.246.198.208:2506,401226f612a3137256509dc2dee4c39196c21caa@46.101.35.219:26656,f1fc62c9554a2682cba2961bde18c19ebea5c1a0@34.125.207.91:26656,9b8cd8bac2fa12f68e2c759042c982901f9527fe@86.48.1.142:26656,b3698769d3fcede4d6b383aab606d09ae890d679@206.189.120.109:26656,6fc2bb503dc47b5a9ce2b51582f56259f180b09b@174.138.34.33:26656,040eda0ef66608bd5455a944dcaefa1411753582@185.192.97.161:26656,02d428f4933c832e4a24307704b5181bc7cd43f0@137.184.225.125:2456,49554e7e24afbdf04b5ba50ec0266f0aef989280@40.114.199.194:26656,170075552fd531f92f24ccf69300e2a4d25173e9@87.246.173.246:26656,3664b233b8d63ef9f65733271fc2a646716a4f26@190.2.155.67:28656,7dc9e97aba15de7055d4ea98114aa231bed4f064@34.127.75.186:26656,c0864edb1e36c52dbee47ce38d8b47ec364a9eb9@135.181.24.128:28656,7269c0c69310de9f26cb030a7be2e8bd4561997c@143.198.60.85:26656,ff201c380cc1fe22039a627ffbe22ffb594aec46@95.217.1.37:26656,27d76871eff24b4871ce938e6e46833682531a86@65.108.42.97:26656,e0b2d3c6e03a5c4ff9f93eaf11fd809e4d419402@209.97.135.135:26656,a6401a34c3c7bd94ee29e7d2d5c46b0f2c653d44@164.92.218.193:26656,8a068dcc7fee91f02b49defade79de00e4467a9a@154.53.53.202:36656,a337fda5620b3624e82459a2e1d4a38ebde24bed@194.146.13.126:26656,5d0ada752728ad5dd8c62d9866fdef2b7322cc26@45.79.250.108:26656,1419aab2e0c25d559e5e213e81667af1e96e95f6@45.10.154.127:26656,505061abd18857b22c354bedb3bd755c76b10ba0@157.230.85.65:26656,dc48a2e124a0667504c6f6b74db0511e8ffba516@65.108.68.233:26601,6c1dfe43d9c0c06f639f7deb6c3b8bb3cabc2647@68.183.12.38:26656,23bf0ceca59442aa869ab95e55c573f2a7b6819b@46.101.159.195:26656,58b5a8b2c6c8945cd478668f2e148b0458753ede@178.62.1.156:26656,36a9b03ae5418c296481f1420dae7442050150fb@174.138.1.118:26656,3084dd928a8263277ac69dc0e4f830f702b0da1b@65.109.60.239:34656,c327443ba07332c6d03eaaff81405bf7eb89ec68@194.146.13.229:26656,187239e6534515df119904481b812b52ab0b2a27@209.97.177.123:26656,aa9190840ec2125148c1fcc61b2bcdb01aacce35@188.166.49.152:26656,803422dc38606dd62017d433e4cbbd65edd6089d@51.15.143.254:26656,3384179374755adcadc666170e22f504167fa8e0@38.242.214.172:2456,52f195ea69bb2f4e4c0ffe15a1814ae5ccbc4d8f@38.242.132.159:26656,4d8406189309d6afb008e87f893d35dd10a9a2ec@45.88.223.161:26656,4bb02c1155e43b54b7e458a771afa5f80c8207f0@89.163.231.30:26656,b576762786c937362c7b5884bcbc3774b4df8f60@128.199.49.113:26656,bf5802cfd8688e84ac9a8358a090e99b5b769047@135.181.176.109:53656,604042c495368c0b3513b8541dbf88e217d52cdf@207.180.223.111:26656,8a9395393163fe97ff6a45203fd4a59b5171664a@91.230.110.94:26656,2596ec3b54d2c628ffb6c3f0b43cbd46eadbf11f@65.108.129.29:60656,e39f99ef512beef680e588c363715991485406d9@194.146.13.106:26656,5a4865ccf89affef7a99e83b31f96ac898cfb3ef@159.65.206.7:26656,93afa43fa4ebf0fa7144fd0a15024caac1f4f87e@45.91.170.80:26656,03d719f115066060976adb6e45270d319bc9de21@143.198.150.51:26656,951bae8787569f0c33651edbac40c97afc6ae198@88.255.100.129:26656,4c4258747e1b94826694b8e946707c20d544ab29@137.184.86.70:26656,41d5b172abaf694eb30d05625c6d187b48ad4585@95.216.217.85:26656,0bc82a3608bf73761e05ac592686891a40d90e5a@195.3.222.188:26656,7f3a30c3a7663bb91f1fe16e1eb45dbe91988a4d@178.63.102.172:56656"
sed -i 's|^persistent_peers *=.*|persistent_peers = "'$peers'"|' $HOME/.okp4d/config/config.toml
seeds=""
sed -i.bak -e "s/^seeds =.*/seeds = \"$seeds\"/" $HOME/.okp4d/config/config.toml
```

### Pruning (Optional)
```
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="10"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.okp4d/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.okp4d/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.okp4d/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.okp4d/config/app.toml
```

### Indexer (Optional)
```
indexer="null" && \
sed -i -e "s/^indexer *=.*/indexer = \"$indexer\"/" $HOME/.okp4d/config/config.toml
```

### Download addrbook
```
wget -O $HOME/.okp4d/config/addrbook.json "https://raw.githubusercontent.com/elangrr/testnet_guide/main/okp/addrbook.json"
```

### Create service file and start the node
```
sudo tee /etc/systemd/system/okp4d.service > /dev/null <<EOF
[Unit]
Description=okp4d
After=network-online.target

[Service]
User=$USER
ExecStart=$(which okp4d) start
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF
```

### Start node
```
sudo systemctl daemon-reload
sudo systemctl enable okp4d
sudo systemctl restart okp4d && sudo journalctl -u okp4d -f -o cat
```

### State-Sync (OPTIONAL)
```
```

### Faucet
Get your faucet at https://faucet.okp4.network/

### Create Validator
```
okp4d tx staking create-validator \
  --amount 1000000uknow \
  --from <wallet> \
  --commission-max-change-rate "0.1" \
  --commission-max-rate "0.2" \
  --commission-rate "0.1" \
  --min-self-delegation "1" \
  --pubkey  $(okp4d tendermint show-validator) \
  --moniker <moniker> \
  --chain-id okp4-nemeton \
  --identity="" \
  --details="" \
  --website="" -y
```
Change `<wallet>` and `<moniker>` 

### Snapshot (Nodejumper)
```
sudo systemctl stop okp4d
cp $HOME/.okp4d/data/priv_validator_state.json $HOME/.okp4d/priv_validator_state.json.backup
rm -rf $HOME/.okp4d/data

curl -L https://snapshot.okp4.indonode.net/okp4-snapshot-2023-01-03.tar.lz4 | lz4 -dc - | tar -xf - -C $HOME/.okp4d
mv $HOME/.okp4d/priv_validator_state.json.backup $HOME/.okp4d/data/priv_validator_state.json

sudo systemctl restart okp4d && journalctl -u okp4d -f --no-hostname -o cat
```

## Usefull commands
### Service management
Check logs
```
journalctl -fu okp4d -o cat
```

Start service
```
sudo systemctl start okp4d
```

Stop service
```
sudo systemctl stop okp4d
```

Restart service
```
sudo systemctl restart okp4d
```

### Node info
Synchronization info
```
okp4d status 2>&1 | jq .SyncInfo
```

Validator info
```
okp4d status 2>&1 | jq .ValidatorInfo
```

Node info
```
okp4d status 2>&1 | jq .NodeInfo
```

Show node id
```
okp4d tendermint show-node-id
```

### Wallet operations
List of wallets
```
okp4d keys list
```

Recover wallet
```
okp4d keys add <wallet> --recover
```

Delete wallet
```
okp4d keys delete <wallet>
```

Get wallet balance
```
okp4d query bank balances <address>
```

Transfer funds
```
okp4d tx bank send <FROM ADDRESS> <TO_okp_WALLET_ADDRESS> 10000000uknow
```

### Voting
```
okp4d tx gov vote 1 yes --from <wallet> --chain-id=okp4-nemeton
```

### Staking, Delegation and Rewards
Delegate stake
```
okp4d tx staking delegate <okp valoper> 10000000uknow --from=<wallet> --chain-id=okp4-nemeton --gas=auto
```

Redelegate stake from validator to another validator
```
okp4d tx staking redelegate <srcValidatorAddress> <destValidatorAddress> 10000000uknow --from=<wallet> --chain-id=okp4-nemeton --gas=auto
```

Withdraw all rewards
```
okp4d tx distribution withdraw-all-rewards --from=<wallet> --chain-id=okp4-nemeton --gas=auto
```

Withdraw rewards with commision
```
okp4d tx distribution withdraw-rewards <okp valoper> --from=<wallet> --commission --chain-id=okp4-nemeton
```

### Validator management
Edit validator
```
okp4d tx staking edit-validator \
  --moniker=<moniker> \
  --identity=<your_keybase_id> \
  --website="<your_website>" \
  --details="<your_validator_description>" \
  --chain-id=okp4-nemeton \
  --from=<wallet>
```

Unjail validator
```
okp4d tx slashing unjail \
  --broadcast-mode=block \
  --from=<wallet> \
  --chain-id=okp4-nemeton \
  --gas=auto
```

### Delete node
```
sudo systemctl stop okp4d && \
sudo systemctl disable okp4d && \
rm /etc/systemd/system/okp4d.service && \
sudo systemctl daemon-reload && \
cd $HOME && \
rm -rf okp4d && \
rm -rf .okp4d && \
rm -rf $(which okp4d)
```




















