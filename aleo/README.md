<p style="font-size:14px" align="right">
<a href="https://github.com/elangrr/testnet_guide" target="_blank">More Guide Tutorials<img src="https://avatars.githubusercontent.com/u/34649601?v=4" width="30"/></a>
</p>

<p style="font-size:14px" align="right">
<a href="https://indonode.dev/" target="_blank">Visit my website <img src="https://avatars.githubusercontent.com/u/34649601?v=4" width="30"/></a>
</p>

<p align="center">
 <img height="150" height="auto" src="https://user-images.githubusercontent.com/34649601/196217517-3e2c030f-7af3-46f2-9042-81176ce9d143.png">
</p>

# Official Links
### [Aleo Official Website](https://www.aleo.org/)
### [Aleo Discord](https://discord.gg/aleohq)

## Minimum Requirements 
- CPU	16 cores (32 preferred)
- RAM	16GB (32 preferred)
- OS	Ubuntu 20.04 recommended, 18.04 should work
- Storage	128GB
- Network	50 Mbps upload/download
- Note:	You will require more than these requirement in order to be competitive

`NOTE2 : Run as ROOT User!!`

# Aleo Incentivized Testnet Guide

### Update depencies
```
apt update
apt upgrade -y
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

### Create new account (account store in $HOME/aleo/account_new.txt)
```
mkdir $HOME/aleo
> $HOME/aleo/account_new.txt
date >> $HOME/aleo/account_new.txt
snarkos account new >>$HOME/aleo/account_new.txt
```
Backup your account `cat $HOME/aleo/account_new.txt`

### Set Private key to your prover
```
mkdir -p /var/aleo/
cat $HOME/aleo/account_new.txt >>/var/aleo/account_backup.txt
echo 'export PROVER_PRIVATE_KEY'=$(grep "Private Key" $HOME/aleo/account_new.txt | awk '{print $3}') >> $HOME/.bash_profile
source $HOME/.bash_profile
```

### Create Service File for Aleo Client Node
```
echo "[Unit]
Description=Aleo Client Node
After=network-online.target
[Service]
User=$USER
ExecStart=$(which snarkos) start --nodisplay --client ${PROVER_PRIVATE_KEY}
Restart=always
RestartSec=10
LimitNOFILE=10000
[Install]
WantedBy=multi-user.target
" > $HOME/aleo-client.service
 mv $HOME/aleo-client.service /etc/systemd/system
 tee <<EOF >/dev/null /etc/systemd/journald.conf
Storage=persistent
EOF
```
Start your client
```
systemctl restart systemd-journald
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
 
