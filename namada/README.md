### Update and Install Depencies
```
sudo apt update && sudo apt upgrade -y
sudo apt install curl tar wget clang pkg-config libssl-dev libclang-dev jq build-essential bsdmainutils git make ncdu gcc git jq chrony liblz4-tool -y
sudo apt install -y uidmap dbus-user-session
```

### Install Rust and Nodejs
```
cd $HOME
  sudo apt update
  sudo curl https://sh.rustup.rs -sSf | sh -s -- -y
  . $HOME/.cargo/env
  curl https://deb.nodesource.com/setup_16.x | sudo bash
  sudo apt install cargo nodejs -y < "/dev/null"
```

### Install GO
```
sudo rm -rf /usr/local/go
curl -Ls https://go.dev/dl/go1.19.4.linux-amd64.tar.gz | sudo tar -xzf - -C /usr/local
eval $(echo 'export PATH=$PATH:/usr/local/go/bin' | sudo tee /etc/profile.d/golang.sh)
eval $(echo 'export PATH=$PATH:$HOME/go/bin' | tee -a $HOME/.profile)
```

### Setting up Vars
```
echo "export NAMADA_TAG=v0.13.0" >> ~/.bash_profile
echo "export TM_HASH=v0.1.4-abciplus" >> ~/.bash_profile
echo "export CHAIN_ID=public-testnet-1.0.05ab4adb9db" >> ~/.bash_profile
```

```
echo "export MONIKER=YOUR_MONIKER" >> ~/.bash_profile
echo "export WALLET=wallet" >> ~/.bash_profile
```
Change `YOUR_MONIKER` To your own Moniker

Clean up 
```
source ~/.bash_profile
```

### Download Binaries
```
cd $HOME && git clone https://github.com/anoma/namada && cd namada && \
git checkout $NAMADA_TAG
make build-release
cargo --version
```

### Download Tendermint
```
cd $HOME && git clone https://github.com/heliaxdev/tendermint && cd tendermint && git checkout $TM_HASH
make build
```
### Copy Tendermint and copy Namada Binary
```
cd $HOME && cp $HOME/tendermint/build/tendermint  /usr/local/bin/tendermint && cp "$HOME/namada/target/release/namada" /usr/local/bin/namada && cp "$HOME/namada/target/release/namadac" /usr/local/bin/namadac && cp "$HOME/namada/target/release/namadan" /usr/local/bin/namadan && cp "$HOME/namada/target/release/namadaw" /usr/local/bin/namadaw
tendermint version
namada --version
```





