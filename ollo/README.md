</p>
<p style="font-size:14px" align="right">
<a href="https://discord.gg/d4wbfZCtTG" target="_blank">Join Ollo Station Discord<img src="https://user-images.githubusercontent.com/50621007/176236430-53b0f4de-41ff-41f7-92a1-4233890a90c8.png" width="30"/></a>
</p>

<p style="font-size:14px" align="right">
<a href="https://github.com/elangrr/testnet_manuals" target="_blank">More Guide Tutorials<img src="https://avatars.githubusercontent.com/u/34649601?v=4" width="30"/></a>
</p>

<p style="font-size:14px" align="right">
<a href="https://indonode.dev/" target="_blank">Visit my website <img src="https://avatars.githubusercontent.com/u/34649601?v=4" width="30"/></a>
</p>

<p align="center">
  <img height="150" height="auto" src="https://user-images.githubusercontent.com/50621007/192699071-461d8ff6-6ddf-4d4f-aba7-d3ddcc4a5563.png">
</p>

# Point Network Mainnet

## [Official Guide](https://docs.ollo.zone/validators/running_a_node)


## Minimum Requirements
- 4x CPUs; the faster clock speed the better
- 8GB RAM
- 100GB of storage (SSD or NVME)
- Permanent Internet connection (traffic will be minimal during testnet; 10Mbps will be plenty - for production at least 100Mbps is expected)

## Ollo Validator Setup

### Setting up variable
```
NODENAME=<YOUR MONIKER>
```
Change `<YOUR MONIKER>` To any moniker you like

Save and import variables
```
echo "export NODENAME=$NODENAME" >> $HOME/.bash_profile
if [ ! $WALLET ]; then
	echo "export WALLET=wallet" >> $HOME/.bash_profile
fi
echo "export OLLO_CHAIN_ID=ollo-testnet-0" >> $HOME/.bash_profile
source $HOME/.bash_profile
```

### Packages and Depencies
Update Package
```
sudo apt update && sudo apt upgrade -y
```
Install Depencies
```
sudo apt install curl build-essential git wget jq make gcc tmux chrony -y
```

### Install GO 1.18+
```
if ! [ -x "$(command -v go)" ]; then
  ver="1.18.3"
  cd $HOME
  wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz"
  sudo rm -rf /usr/local/go
  sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
  rm "go$ver.linux-amd64.tar.gz"
  echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> ~/.bash_profile
  source ~/.bash_profile
fi
```

### Download and build binaries
```
cd $HOME
git clone https://github.com/OllO-Station/ollo.git
cd ollo
make install
```

### Config
```
ollod config chain-id $OLLO_CHAIN_ID
ollod config keyring-backend test
```

### Init
```
ollod init $NODENAME --chain-id $OLLO_CHAIN_ID
```

### Download Genesis and Addrbook
```
curl https://raw.githubusercontent.com/OllO-Station/ollo/master/networks/ollo-testnet-0/genesis.json | jq .result.genesis > $HOME/.ollo/config/genesis.json
```

### Set Peers 
```
SEEDS=""
PEERS="764988cb3a9de4afa34c666019510ea5b5856c60@65.108.238.61:46656,4dd3f3897ab77c7aa981bf4e928659f867093361@198.244.179.62:25456,1be12d239ca70a906264de0f09e0ffa01c4211ba@138.201.136.49:26656,ffbc66ef617ec910e453bec28d2750951d964f89@154.53.59.87:32656,9316bed278b94c3e8a298b0649d62ca9c57bd210@94.103.93.45:15656,6368702dd71e69035dff6f7830eb45b2bae92d53@65.109.57.161:15656,d24d7968f2377a1488c057c79f39e6c7a0d5698b@95.217.12.175:32656,7735cb5a04ad60437c575ecc5280c43b2df9a038@161.97.99.247:11656,362c9af972fb9bbc058a48786a097c74e2606504@176.9.106.43:36656,3498a07e5e79b269a3e445e8073d58bf42b6a5b8@185.173.37.47:32656"
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.ollo/config/config.toml
```
`NOTE : IF PEERS DEAD USE THIS` NEW PEERS LIST 03/10/22

