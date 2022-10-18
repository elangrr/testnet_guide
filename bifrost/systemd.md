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
### [Bifrost Official Website](https://thebifrost.io/)
### [Bifrost Discord](https://discord.gg/HpK7kGzXBh)

## Minimum Requirements 
- 4 or more physical CPU cores
- At least 1TB of SSD disk storage
- At least 16GB of memory (RAM)
- At least 100mbps network bandwidth

# Install Node Guide

### Update Packages and Depencies
```
cd $HOME
sudo apt update && sudo apt upgrade -y
sudo apt install curl build-essential git wget npm nodejs jq make gcc tmux -y && apt purge docker docker-engine docker.io containerd docker-compose -y
```

### Create directory
```
sudo mkdir -p /var/lib/bifrost-data
```

### Download Binary
```
wget "https://github.com/bifrost-platform/bifrost-node/releases/download/v1.0.0/bifrost-node"
wget "https://github.com/bifrost-platform/bifrost-node/releases/download/v1.0.0/bifrost-testnet.json"
```

### Set permission , move file and set ownership
```
sudo chmod +x bifrost-node
sudo mv bifrost-node bifrost-testnet.json /var/lib/bifrost-data
sudo chown -R $(id -u):$(id -g) /var/lib/bifrost-data
```

### Create Service
```
sudo tee /etc/systemd/system/bifrost.service > /dev/null <<EOF
[Unit]
Description="Bifrost-node systemd service"
After=network.target
StartLimitIntervalSec=0

[Service]
Type=simple
User=BIFROST_SERVICE
SyslogIdentifier=bifrost
SyslogFacility=local7
KillSignal=SIGHUP
ExecStart=/var/lib/bifrost-data/bifrost-node \
    --base-path /var/lib/bifrost-data \
    --chain /var/lib/bifrost-data/bifrost-testnet.json \
    --port 30333 \
    --validator \
    --state-cache-size 0 \
    --runtime-cache-size 64 \
    --name "YOUR CONTROLLER"

[Install]
WantedBy=multi-user.target
EOF
```
Change `YOUR CONTROLLER` To your controller address

### Start your node and check logs
```
sudo systemctl daemon-reload && sudo systemctl enable bifrost.service && sudo systemctl restart bifrost.service && sudo journalctl -u bifrost.service -f -o cat
```

After your node is synced proceed to next step

### Clone github
```
cd ~
git clone https://github.com/bifrost-platform/bifrost-node
```

### Install required packages
```
cd bifrost-node/
npm install
```

## Bonding
### Basic Node
```
npm run join_validators -- \
  --controllerPrivate "0xYOUR_CONTROLLER_PRIVATE_KEY" \
  --stashPrivate "0xYOUR_STASH_PRIVATE_KEY" \
  --bond "50000"
````
Add `0x` before every private key

### Full Node
```
npm run join_validators -- \
  --controllerPrivate "0xYOUR_CONTROLLER_PRIVATE_KEY" \
  --stashPrivate "0xYOUR_STASH_PRIVATE_KEY" \
  --relayerPrivate "0xYOUR_RELAYER_PRIVATE_KEY" \
  --bond "100000"
```
Add `0x` before every private key


