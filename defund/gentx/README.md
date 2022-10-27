<p style="font-size:14px" align="right">
<a href="https://github.com/elangrr/testnet_guide" target="_blank">More Guide Tutorials<img src="https://avatars.githubusercontent.com/u/34649601?v=4" width="30"/></a>
</p>

<p style="font-size:14px" align="right">
<a href="https://indonode.dev/" target="_blank">Visit my website <img src="https://avatars.githubusercontent.com/u/34649601?v=4" width="30"/></a>
</p>

<p align="center">
 <img height="200" height="auto" src="https://user-images.githubusercontent.com/50621007/171904810-664af00a-e78a-4602-b66b-20bfd874fa82.png">



# Official Links
### [Official Document](https://github.com/defund-labs/testnet/tree/main/defund-private-2)
### [Defund Official Discord](https://discord.gg/Rx2gdHmsRn)

# Explorer

## Minimum Requirements 
- 4 or more physical CPU cores
- At least 200GB of SSD disk storage
- At least 16GB of memory (RAM)
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
ver="1.19.1" && \
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
git clone https://github.com/defund-labs/defund.git
cd defund
git checkout v0.1.0-alpha
make install
```

### Init 
```
defundd config chain id defund-private-2
defundd config keyring-backend test
defundd init <moniker> --chain-id defund-private-2
```
Change `<moniker>` to your moniker

### Create wallet
To create new wallet use 
```
defundd keys add <wallet>
```
Change `<wallet>` to your wallet name

To recover existing keys use 
```
defundd keys add <wallet> --recover
```
Change `<wallet>` to your wallet name

To see current keys 
```
defundd keys list
```

### Add Genesis 
```
defundd add-genesis-account <wallet address> 100000000ufetf
```
Change `<wallet address>` To your defund wallet address

### Create Gentx
```
defundd gentx <wallet> 90000000ufetf \
--chain-id defund-private-2 \
--moniker=<moniker> \
--commission-max-change-rate=0.01 \
--commission-max-rate=0.20 \
--commission-rate=0.05 \
--details="" \
--security-contact="" \
--website=""
```

Change `<moniker>` and `<wallet>`

### Backup 

Dont forget to backup `Mnemonic` and every file in `$HOME/.defundd/config/*`

### Submit PR (28 Oct 00:00 UTC)

- Copy the contents of $HOME/.defundd/config/gentx/gentx-XXXXXXXX.json.
- Fork https://github.com/defund-labs/testnet
- Create a file gentx-VALIDATOR_NAME.json under the defund-private-2/gentx folder in the forked repo, paste the copied text into the file.
- Create a Pull Request to the main branch of the repository
