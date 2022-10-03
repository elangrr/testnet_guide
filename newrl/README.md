</p>
<p style="font-size:14px" align="right">
<a href="https://discord.gg/FZFU7bBHJf" target="_blank">Join Newrl Discord<img src="https://user-images.githubusercontent.com/50621007/176236430-53b0f4de-41ff-41f7-92a1-4233890a90c8.png" width="30"/></a>
</p>

<p style="font-size:14px" align="right">
<a href="https://github.com/elangrr/testnet_manuals" target="_blank">More Guide Tutorials<img src="https://avatars.githubusercontent.com/u/34649601?v=4" width="30"/></a>
</p>

<p style="font-size:14px" align="right">
<a href="https://indonode.dev/" target="_blank">Visit my website <img src="https://avatars.githubusercontent.com/u/34649601?v=4" width="30"/></a>
</p>

<p align="center">
  <img height="150" height="auto" src="https://newrl.net/img/newrl_logo.png">
</p>

# Newrl Mining Testnet
## [Official Guide](https://docs.newrl.net/Validating/running-validator-node/)

## Newrl Miners Setup Guide

### Ports
Open your VPS port in VPS / Panel
```
sudo ufw allow ssh 
sudo ufw allow 8421
```
NOTE : I choose 8421 because we run Testnet, if you wanna run Devnet / Mainnet use another port

`devnet:8420`

`testnet:8421`

`mainnet:8426`
Or you can just open all the ports


### Packages
```
sudo apt update && sudo apt upgrade -y
```

### Depencies
```
sudo apt install -y build-essential libssl-dev libffi-dev git curl screen
```

### Install Python 3.7+
```
sudo apt install python3.9
```

### Install Pip and Python3 venv
```
curl -sSL https://bootstrap.pypa.io/get-pip.py -o get-pip.py
python3 get-pip.py
sudo apt install python3.9-venv
sudo mkdir newrl-venv
cd newrl-venv
python3.9 -m venv newrl-venv
```

### Activate your environment
```
source newrl-venv/bin/activate
```

### Download and Build Binaries
```
git clone https://github.com/newrlfoundation/newrl.git
cd newrl
scripts/install.sh testnet
```

### Start Node
```
screen -S newrl
scripts/start.sh testnet
```

To detach from the screen simply press `CTRL+A+D`

To see list of running screen type `screen -r` or `screen -ls`

To restore screen simply run `screen -r <sessionid>`






