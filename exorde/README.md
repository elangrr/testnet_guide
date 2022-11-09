<p style="font-size:14px" align="right">
<a href="https://github.com/elangrr/testnet_guide" target="_blank">More Guide Tutorials<img src="https://avatars.githubusercontent.com/u/34649601?v=4" width="30"/></a>
</p>

<p style="font-size:14px" align="right">
<a href="https://indonode.dev/" target="_blank">Visit my website <img src="https://avatars.githubusercontent.com/u/34649601?v=4" width="30"/></a>
</p>

<p align="center">
 <img height="150" height="auto" src="https://pbs.twimg.com/profile_images/1486712389777068043/tXqjiR3t_400x400.jpg">
</p>

# Official Links
### [Exorde Official Website](https://exorde.network/)
### [Exorde Discord](https://discord.gg/qQtmJ2FMwJ)

## Minimum Requirements 
- 2 or more physical CPU cores
- At least 20GB of SSD disk storage
- At least 4GB of memory (RAM)
- At least 100mbps network bandwidth

# Install Node Guide

### Set Vars
```
WALLET_ADDRESS=<METAMASK WALLET ADDRESS>
```

Change `<METAMASK WALLET ADDRESS>` To your Metamask Wallet Address

```
echo export WALLET_ADDRESS=${WALLET_ADDRESS} >> $HOME/.bash_profile
source ~/.bash_profile
```

### Update Packages and Depencies
```
cd $HOME
sudo apt update && sudo apt upgrade -y
sudo apt install curl build-essential git wget npm jq make gcc tmux -y && apt purge docker docker-engine docker.io containerd docker-compose -y
```

### Install Docker
```
rm /usr/bin/docker-compose /usr/local/bin/docker-compose
curl -fsSL https://get.docker.com -o get-docker.sh && sh get-docker.sh
systemctl restart docker
curl -SL https://github.com/docker/compose/releases/download/v2.5.0/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
docker --version
```

### Clone Repository and Build docker image
```
git clone https://github.com/exorde-labs/ExordeModuleCLI.git
cd ExordeModuleCLI
```
```
docker build -t exorde-cli .
```

### Run Exorder CLI through Docker
This runs in the background
```
docker run -d -it --name Exorde exorde-cli -m $WALLET_ADDRESS -l 4
```
You can change the logs by changing `4` :

- 0 = no logs
- 1 = general logs
- 2 = validation logs
- 3 = validation + scraping logs
- 4 = detailed validation + scraping logs (e.g. for troubleshooting)

### Check the logs 
To check logs 
```
docker logs Exorde
```

To check logs constantly
```
docker logs --follow Exorde
```

To delete node
```
sudo  docker stop Exorde &&  sudo  docker  rm Exorde
 sudo  rm -rf ExordeModuleCLI
```
