</p>
<p style="font-size:14px" align="right">
<a href="https://discord.gg/HqBRaeR96N" target="_blank">Join Nulink Discord<img src="https://user-images.githubusercontent.com/50621007/176236430-53b0f4de-41ff-41f7-92a1-4233890a90c8.png" width="30"/></a>
</p>

<p style="font-size:14px" align="right">
<a href="https://github.com/elangrr/testnet_manuals" target="_blank">More Guide Tutorials<img src="https://avatars.githubusercontent.com/u/34649601?v=4" width="30"/></a>
</p>

<p style="font-size:14px" align="right">
<a href="https://indonode.dev/" target="_blank">Visit my website <img src="https://avatars.githubusercontent.com/u/34649601?v=4" width="30"/></a>
</p>

</p>
<p style="font-size:14px" align="right">
<a href="https://discord.gg/gru6MuGPgP" target="_blank">Join NodeX Capital Network Discord<img src="https://user-images.githubusercontent.com/50621007/176236430-53b0f4de-41ff-41f7-92a1-4233890a90c8.png" width="30"/></a>
</p>

<p align="center">
 <img height="250" height="auto" src="https://user-images.githubusercontent.com/107190154/190568136-14f5a7d8-5b15-46fb-8132-4d38a0779171.gif">
</p>

# Nulink Update Guide

# Official Links
### [Official Document](https://docs.nulink.org/products/testnet)
### [Nulink Official Website](https://www.nulink.org/)
### [Nulink Official Telegram](https://t.me/NuLinkChannel)

## Minimum Requirements 
- 2-4vCPU
- 4GB of Ram
- 30GB SSD

# Pre-Update !!!
First run as Super user and open port
```
sudo su
sudo ufw enable
sudo ufw allow ssh
sudo ufw allow 9151
sudo ufw allow 9152
```
`NOTE : AZURE USER OPEN PORT IN THEIR PANEL !!!`

# There is 2 Case here so please choose your scenario

## Case #1
## #1 My Staking account and worker account is available

### Update Case #1
### If you still have Staking account and worker account simply stop the docker

- Run `docker ps` to see currently running container
```
docker ps
```
- Then 
```
docker kill <containerID>
```
change `<containerID>` with container ID after you run `docker ps` to stop the node

### Then pull the latest nulink image
```
docker pull nulink/nulink:latest
```
  
### Relaunch the worker node
```
docker run --restart on-failure -d \
--name ursula \
-p 9151:9151 \
-v /root/nulink:/code \
-v /root/nulink:/home/circleci/.local/share/nulink \
-e NULINK_KEYSTORE_PASSWORD \
-e NULINK_OPERATOR_ETH_PASSWORD \
nulink/nulink nulink ursula run --no-block-until-read
```

## Case #2
### Staking account or worker account is lost

### Update Case #2
Case #2 Is a little bit tricky since you have to switch port to 9152

If the staking account or the worker account is lost(this means either you can not login your staking account in Metamask or your keystore file in host directory is deleted), then the update procedure is a little bit complex. Here is the suggest way.

### Stop and remove the running node in Docker

- Run `docker ps` to see the containerID
```
docker ps
```
- Kill the running containerID
```
docker kill <containerID>
```
change `<containerID>` with container ID after you run `docker ps` to stop the node

- Remove the running docker node
```
docker rm ursula
```

### delete the old host directory and create a new host directory 

```
cd /root
rm -rf nulink
```
- make new nulink folder
```
mkdir nulink
```
### Copy the keystore file of the Worker account to the host directory 
```
cp <keystore path> /root/nulink
```
change `<keystore path>` with the keystore path of your key `MY COMMAND EXAMPLE:`


`cp /root/geth-linux-amd64-1.10.24-972007a5/keystore/UTC--2022-09-17T05-27-00.315775527Z--b045627fd6c57577bba32192d8XXXXXXXX /root/nulink`

- Then give permission to `/root/nulink`
```
chmod -R 777 /root/nulink
```

### OPTIONAL !!!! (if you lost the old worker account, you could generate a new one using this simple command then copy the keystore file )
```
wget -O nulink.sh https://raw.githubusercontent.com/elangrr/testnet_guide/main/nulink/nulink.sh && chmod +x nulink.sh && ./nulink.sh
```

### Set Variable
```
export NULINK_KEYSTORE_PASSWORD=<YOUR PASSWORD>


export NULINK_OPERATOR_ETH_PASSWORD=<YOUR PASSWORD>
```
change `<YOUR PASSWORD>` with password you entered earlier just so you can remember it .

### initialize Node Configuration with port 9152 since you lost your account and old url is always bonded
```
docker run -it --rm \
-p 9152:9152 \
-v /root/nulink:/code \
-v /root/nulink:/home/circleci/.local/share/nulink \
-e NULINK_KEYSTORE_PASSWORD \
nulink/nulink nulink ursula init \
--signer keystore:///code/<Path of the secret key file> \
--eth-provider https://data-seed-prebsc-2-s2.binance.org:8545  \
--network horus \
--payment-provider https://data-seed-prebsc-2-s2.binance.org:8545 \
--payment-network bsc_testnet \
--operator-address <YOUR PUBLIC ADDRESS> \
--max-gas-price 100
```
Change `<Path of the secret key file>` With the path of your keystore, Only Copy the name after UTC , `UTC--2022-09-17T05-27-00.315775527Z--b045627fd6c57577bba32192d8e47XXXXXXXX`

Change `<YOUR PUBLIC ADDRESS>` With your public address generated after you Use Auto install script

`MY COMMAND EXCAMPLE!`
```
docker run -it --rm \
-p 9152:9152 \
-v /root/nulink:/code \
-v /root/nulink:/home/circleci/.local/share/nulink \
-e NULINK_KEYSTORE_PASSWORD \
nulink/nulink nulink ursula init \
--signer keystore:///code/UTC--2022-09-17T05-27-00.315775527Z--XXXXXXXXXXXXXXXX \
--eth-provider https://data-seed-prebsc-2-s2.binance.org:8545  \
--network horus \
--payment-provider https://data-seed-prebsc-2-s2.binance.org:8545 \
--payment-network bsc_testnet \
--operator-address 0xB045627Fd6c57577Bba32192d8EXXXXXXXXXXXXXXX \
--max-gas-price 100
```
### Launch the node with new configuration
```
docker run --restart on-failure -d \
--name ursula \
-p 9152:9152 \
-v /root/nulink:/code \
-v /root/nulink:/home/circleci/.local/share/nulink \
-e NULINK_KEYSTORE_PASSWORD \
-e NULINK_OPERATOR_ETH_PASSWORD \
nulink/nulink nulink ursula run \
--rest-port 9152 \
--config-file /root/nulink/ursula.config \
 --no-block-until-ready
```
### Check logs 
To check logs we can use screen to constantly look at the log
```
apt install screen
```
``` 
screen -S log
```
```
docker logs -f ursula
```
Output : 
![image](https://user-images.githubusercontent.com/34649601/190843374-510026ec-7996-483f-a7a1-a42ed800cd82.png)
After that your job to run node is complete now lets go to the next step.

# Staking 
- Go to Staking page [https://test-staking.nulink.org/faucet](https://test-staking.nulink.org/faucet)
- Connect your Metamask , You can use any Metamask account
- Get BSC Testnet token in [BNB Faucet](https://testnet.binance.org/faucet-smart) 
- When you get your test BSC now ask for faucet in Nulink Faucet
- Go to [Staking](https://test-staking.nulink.org/) Page and Stake your Nulink and Press Confirm and approve transaction in your Metamask
![image](https://user-images.githubusercontent.com/34649601/190844037-d1d9c0a6-f186-4597-a18d-8a776c598291.png)
 ### Bond Worker
 Scroll down and click `Bond Worker`
![image](https://user-images.githubusercontent.com/34649601/190844089-ab76c8e4-d0f5-4269-958d-7c368347ecea.png)
 Fill the form (PICTURE ONLY EXAMPLE )
- `Worker Adress` Should be your public address
- `Node Url` Should be `https://IP:9152/` for Example `https://123.45.67.890:9152/` ( Make sure to Copy everything ! dont miss any `/` Or else you will get an error Node Offline)
- Click Bond and Approve Transaction in your Metamask

# Final Words
After that your node will appear `Online`, if it still appear to be `Offline` Do not worry it will be `Online` Soon.
## [FEEDBACK FORM (MUST!!)](https://docs.google.com/forms/d/e/1FAIpQLSep0rgPRcMd2kUhz53GYmBoktu-u-8npU2DakmzGpmpCmYZPw/viewform)
Submit feedback regarding to bugs or improvements for nulink services !

If you did not submit form you won't be eligible!

Only good submission on feedback form will get rewards

Thats it! You are done and make sure your node is not shutdown!!
 

