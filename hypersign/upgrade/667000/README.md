Update Hypersign to ver 1.0.3 Block : `667000`

### (OPTION 1)
Manual Upgrade

`DO NOT UPGRADE BEFORE CHAIN REACHES THE BLOCK 667000`
```
sudo systemctl stop hid-noded
cd $HOME && rm -rf core
git clone https://github.com/hypersign-protocol/hid-node.git
cd hid-node
git checkout v0.1.3
make install
sudo systemctl restart hid-noded && journalctl -fu hid-noded -o cat
```

### (OPTION 2)
Automatic : 

Run on screen
```
sudo apt install screen
screen -S upgrade
```

run auto upgrade script
```
wget -O upgrade.sh https://raw.githubusercontent.com/elangrr/testnet_guide/main/hypersign/upgrade/667000/upgrade.sh && chmod +x upgrade.sh && ./upgrade.sh
```

Detach screen `CTRL+A+D`

to re-attach run `screen -Rd upgrade`
