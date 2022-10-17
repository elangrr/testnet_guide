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
### [Bifrost Official Website](https://www.lambda.im/)
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
```

### Create directory and set ownership
```
sudo mkdir -p /var/lib/bifrost-data
sudo chown -R $(id -u):$(id -g) /var/lib/bifrost-data
```

### Run docker container
```
docker run -d -p 30333:30333 -p 9933:9933 -v "/var/lib/bifrost-data:/data" --name "NODENAME" thebifrost/bifrost-node:latest \ 
--base-path /data \ --chain /specs/bifrost-testnet.json \ 
--port 30333 \ 
--validator \ 
--state-cache-size 0 \ 
--runtime-cache-size 64 \ 
--telemetry-url "wss://telemetry-connector.testnet.thebifrost.io/submit 0" \ 
--name "CONTROLLER ADDRESS"
```
Change `CONTROLLER ADDRESS` To your controller address or your desired node name

Check the logs 
```
docker logs -f bifrost-validator
```

After node is synced (`Target` value are the same as `Best` value) and node start importing blocks
<p align="center">
 <img height="250" height="auto" src="https://user-images.githubusercontent.com/34649601/196219287-e925f558-b795-4597-b42c-f8b8018481bf.png">
</p>

You can also see your node in [Telemetry](https://telemetry.testnet.thebifrost.io/#/0x15b34a3b7443c73fa1f687cce2d8e5981f6a2eaad54809a6b6af28e83d2adaff) By typing your node name
<p align="center">
 <img height="300" height="auto" src="https://user-images.githubusercontent.com/34649601/196220022-086fe23b-eb07-4fcd-bdc1-37072a858dad.png">
</p>

Access the docker container
```
docker exec -it bifrost-validator /bin/bash
```

Move to tools and install npm
```
cd tools
npm install
```

### Set session keys
Next, the validator node must issue and register session keys to be used in the consensus algorithm. 

The process can be performed by executing the following command. 

You should to need your private key which you was registered in form: 

If you are using private key from metamask add `0x` in front of the private key
 
Example : if your private key is `be6f3d6baefddc86984f6b8ba7481944af23814d9810xxxxxxxxxxxxxxxxx`

change it to `0xbe6f3d6baefddc86984f6b8ba7481944af23814d9810xxxxxxxxxxxxxxxxxx`

Command:
```
npm run set_session_keys -- \
 --controllerPrivate "YOUR_CONTROLLER_0xPRIVATE_KEY"
```
Successfull output will be
<p align="center">
 <img height="250" height="auto" src="https://user-images.githubusercontent.com/34649601/196214834-69851229-7b22-4b7b-8659-2489a4d74682.png">
</p>

### Bonding

### Basic Node
```
npm run join_validators -- \
  --controllerPrivate "0xYOUR_CONTROLLER_PRIVATE_KEY" \
  --stashPrivate "0xYOUR_STASH_PRIVATE_KEY" \
  --bond "50000"
```
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

### Explorer
[Bifrost Explorer](https://explorer.testnet.thebifrost.io/validators-tier-full)

## Usefull commands

Check node logs
```
docker logs -f bifrost-validator
```

Restart docker
```
docker restart bifrost-validator
```

To delete node
```
sudo  docker stop bifrost-validator &&  sudo  docker  rm bifrost-validator
 sudo  rm -rf /var/lib/bifrost-data
```
