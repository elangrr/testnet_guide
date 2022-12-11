<p style="font-size:14px" align="right">
<a href="https://github.com/elangrr/testnet_guide" target="_blank">More Guide Tutorials<img src="https://avatars.githubusercontent.com/u/34649601?v=4" width="30"/></a>
</p>

<p style="font-size:14px" align="right">
<a href="https://indonode.dev/" target="_blank">Visit my website <img src="https://avatars.githubusercontent.com/u/34649601?v=4" width="30"/></a>
</p>

<p align="center">
 <img height="200" height="auto" src="https://pbs.twimg.com/profile_images/1577353118597222400/sgCyvge-_400x400.jpg">



# Official Links
### [Official Document](https://github.com/Adamnite/goAdamnite)
### [Adamnite Official Discord](https://discord.gg/adamnite-921093307533230111)

## Requirements
### Minimum requirements
- CPU with 5 cores
- 8 GB RAM
- 10GB free disk space
- 10+ MBit/s bandwidth

Run as `root`
### Update firewall
```
apt install ufw
ufw allow 30900
ufw allow ssh
ufw enable
```

### Update depencies
```
sudo apt update && \
sudo apt upgrade -y
```

### Install Depencies needed
```
apt install software-properties-common wget jq python3.8 python3-pip curl tar tmux htop net-tools clang pkg-config libssl-dev jq build-essential git make ncdu -y
```

### Install GO (1.18.8)
```
ver="1.18.8" && \
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz" && \
sudo rm -rf /usr/local/go && \
sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz" && \
rm "go$ver.linux-amd64.tar.gz" && \
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> $HOME/.bash_profile && \
source $HOME/.bash_profile && \
go version
```

### Create Folder
```
cd $HOME
mkdir goAdamnite
```

### Download Binary 
Download in [goAdamnite Binary for Ubuntu](https://github.com/Adamnite/goAdamnite/tree/test-files/Ubuntu) , and move `gnite` and `gnite-test` to `goAdamnite` Directory.

Can't clone because its Private file

### Run gnite
```
cd goAdamnite
chmod +x gnite-test
chmod +x gnite
```

Create Service file for `gnite`
```
sudo tee /etc/systemd/system/gnite.service > /dev/null <<EOF
[Unit]
Description=gnite
After=network-online.target

[Service]
User=$USER
ExecStart=/root/goAdamnite/gnite
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl restart gnite
```

### Create Adamnite Account
```
./gnite account new
```
`SAVE THE OUTPUT!!!`

Once account created go to Adamnite discord on `#beta-transactions` channel and paste your public address and wait untill team send you `NITE` token


### 












