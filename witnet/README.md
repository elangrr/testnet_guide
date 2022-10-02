<p align="center">
  <img height="300" height="auto" src="https://image.pitchbook.com/vX8zS7OuP2aTzsPv2mw8x5sCLnq1630493558420_200x200">
</p>

## [Witnet Official website](https://witnet.io/)
## [Witner Official Docs](https://docs.witnet.io/node-operators/docker-quick-start-guide)

# Witnet node setup in minutes guide using docker

## Minimum Requirements
- 1-2 vCPU
- 2 GB of Ram
- 100 GB SSD

## Install Witnet node

### Pre Installation
Recommended run as superuser and open port `21337`
```
sudo su
sudo ufw allow ssh
sudo ufw allow 21337
```

### Update Packages
```
sudo apt update && sudo apt upgrade -y
```

### Install Depencies
```
sudo apt install ca-certificates curl gnupg lsb-release ocl-icd-opencl-dev libopencl-clang-dev libgomp1 -y
```

### Install Docker
```
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
$(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin
```

### Run Witnet Docker
```
docker run -d \
    --name witnet_node \
    --volume ~/.witnet:/.witnet \
    --publish 21337:21337 \
    --restart always \
    witnet/witnet-rust
```

## Useful Commands

To Check your sync status 
```
docker exec  witnet_node witnet node nodeStats
```

To Check your balance (Sync first)
```
docker exec witnet_node witnet node balance
```

To check your reputation (Sync first)
```
docker exec witnet_node witnet node reputation
```

To verify that your port is correctly forwarded is using the peers method to look if any of the peer connections is tagged as inbound:
```
docker exec witnet_node witnet node peers
```


## Backups and Import keys

### Backup
Backup your private master key
```
docker exec witnet_node witnet node masterKeyExport
```

### Import
Run this command
```
mkdir -p ~/.witnet/config
chmod 777 ~/.witnet/config
nano ~/.witnet/config/master.ke
```
Now enter your master key into the file editor, 

save with Ctrl+O and exit with Ctrl+X

Then run your node
```
docker run -d \
    --name witnet_node \
    --volume ~/.witnet:/.witnet \
    --publish 21337:21337 \
    --restart always \
    witnet/witnet-rust \
    node server --master-key-import /.witnet/config/master.key
```
