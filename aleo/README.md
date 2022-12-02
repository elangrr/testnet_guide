<p style="font-size:14px" align="right">
<a href="https://github.com/elangrr/testnet_guide" target="_blank">More Guide Tutorials<img src="https://avatars.githubusercontent.com/u/34649601?v=4" width="30"/></a>
</p>

<p style="font-size:14px" align="right">
<a href="https://indonode.dev/" target="_blank">Visit my website <img src="https://avatars.githubusercontent.com/u/34649601?v=4" width="30"/></a>
</p>

<p align="center">
 <img height="250" height="auto" src="https://camo.githubusercontent.com/973307a6c53e7088805c6fabbde538c8242f5ce8bbd4b0937b176b4e6df87b69/68747470733a2f2f63646e2e616c656f2e6f72672f736e61726b6f732f62616e6e65722e706e67">
</p>

# Official Links
### [Aleo Official Website](https://www.aleo.org/)
### [Aleo Discord](https://discord.gg/aleohq)
### [SnarkOS Official Guide](https://github.com/AleoHQ/snarkOS)

## Minimum Requirements 
- CPU	16 cores (32 preferred)
- RAM	16GB (32 preferred)
- OS	Ubuntu 20.04 recommended, 18.04 should work
- Storage	128GB
- Network	50 Mbps upload/download
- Note:	You will require more than these requirement in order to be competitive

`NOTE2 : Run as ROOT User!!`

# Aleo Incentivized Testnet Guide (PROVER)

### Update depencies
```
apt update
apt upgrade -y
```
```
apt install make clang pkg-config libssl-dev build-essential gcc xz-utils git curl vim tmux ntp jq llvm ufw -y
```

### Create Swapfile (OPTIONAL)
```
cd $HOME
sudo fallocate -l 4G $HOME/swapfile
sudo dd if=/dev/zero of=swapfile bs=1K count=4M
sudo chmod 600 $HOME/swapfile
sudo mkswap $HOME/swapfile
sudo swapon $HOME/swapfile
sudo swapon --show
echo $HOME'/swapfile swap swap defaults 0 0' >> /etc/fstab
```

### Download Binaries
```
rm -rf $HOME/snarkOS $(which snarkos) $(which snarkos) $HOME/.aleo $HOME/aleo
cd $HOME
git clone https://github.com/AleoHQ/snarkOS.git --depth 1
cd snarkOS
```

### Install SnarkOs
```
bash ./build_ubuntu.sh
source $HOME/.bashrc
source $HOME/.cargo/env
```

### Create new account (account stored in $HOME/aleo/account_new.txt)
```
mkdir $HOME/aleo
> $HOME/aleo/account_new.txt
date >> $HOME/aleo/account_new.txt
snarkos account new >>$HOME/aleo/account_new.txt
```
Backup your account `cat $HOME/aleo/account_new.txt`

### Set Private key to profile
```
mkdir -p /var/aleo/
cat $HOME/aleo/account_new.txt >>/var/aleo/account_backup.txt
echo 'export PROVER_PRIVATE_KEY'=$(grep "Private Key" $HOME/aleo/account_new.txt | awk '{print $3}') >> $HOME/.bash_profile
source $HOME/.bash_profile
```

### Create Service file for Prover
```
echo "[Unit]
Description=Aleo Prover Node
After=network-online.target
[Service]
User=$USER
ExecStart=$(which snarkos) start --nodisplay --prover ${PROVER_PRIVATE_KEY}
Restart=always
RestartSec=10
LimitNOFILE=10000
[Install]
WantedBy=multi-user.target
" > $HOME/aleo-prover.service
 mv $HOME/aleo-prover.service /etc/systemd/system
 ```
 
### Install Updater (OPTIONAL)
```
wget -q -O $HOME/updater.sh https://raw.githubusercontent.com/elangrr/testnet_guide/main/aleo/updater.sh && chmod +x $HOME/updater.sh
```
Create Updater Service file
```
echo "[Unit]
Description=Aleo Updater
After=network-online.target
[Service]
User=$USER
WorkingDirectory=$HOME/snarkOS
ExecStart=/bin/bash $HOME/updater.sh
Restart=always
RestartSec=10
LimitNOFILE=10000
[Install]
WantedBy=multi-user.target
" > $HOME/aleo-updater.service
mv $HOME/aleo-updater.service /etc/systemd/system
```
```
systemctl daemon-reload
systemctl enable aleo-updater
systemctl restart aleo-updater
```
### Start Prover
```
systemctl enable aleo-prover
systemctl restart aleo-prover
```
### Check logs
```
journalctl -u aleo-prover -f -o cat
```

## Cheat Sheet

View you Private key
```
cat $HOME/aleo/account_new.txt
```

Check What Aleo Private Key is used
```
grep "prover" /etc/systemd/system/aleo-prover.service | awk '{print $5}'
```

Check prover Logs
```
journalctl -u aleo-prover -f -o cat
```

## Troubleshootings

- My node is unable to compile.

  Ensure your machine has `ust v1.65+` installed. Instructions to [install Rust can be found here.](https://www.rust-lang.org/tools/install)  
  If large errors appear during compilation, try running `cargo clean`.
 
- My node is unable to connect to peers on the network.

  Ensure ports `4133/tcp` and `3033/tcp` are open on your router and OS firewall.

- I can't generate a new address

  Before running the command above (snarkos account new) try `source ~/.bashrc`
  Also double-check the spelling of snarkos. Note the directory is `/snarkOS`
  
### Remove Aleo Prover ( WARNING! THIS COMMAND WILL REMOVE ALEO FROM YOUR MACHINE! )
```
rm $(which snarkos)
rm -rf /etc/systemd/system/aleo*
rm -rf aleo/
rm -rf aleo .aleo .cargo .rustup snarkOS updater.sh
```
