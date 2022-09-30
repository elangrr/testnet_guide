![image](https://user-images.githubusercontent.com/34649601/193186845-aacfef1b-6091-4f61-bea7-9f2d9c698f7d.png)

# Ollo Testnet validator guide

## Minimum System Requirements
- 8vCPU
- 16GB Ram
- 160 of Storage
- Internet Connection

## Installing Depencies
```
sudo apt update && sudo apt upgrade -y
sudo apt install curl tar wget clang pkg-config libssl-dev jq build-essential bsdmainutils git make ncdu gcc git jq chrony liblz4-tool -y
```

## Install GO 
```
cd $HOME
ver="1.18.5"
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
rm "go$ver.linux-amd64.tar.gz"
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> $HOME/.bash_profile
source $HOME/.bash_profile
go version
```

## Install Binary
```
git clone https://github.com/OLLO-Station/ollo
cd ollo
make install
```
Check OLLO Version
`ollod version` , should be latest

## Init
```
ollod init <Moniker> --chain-id ollo-testnet-0
```
Change `<Moniker>` as you like

