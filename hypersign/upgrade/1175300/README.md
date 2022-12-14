### Manual upgrade 

DO NOT UPGRADE UNTILL BLOCK REACHES `1175300`
```
sudo systemctl stop hid-noded
cd $HOME && rm -rf hid-node
git clone https://github.com/hypersign-protocol/hid-node.git
cd hid-node
git checkout v0.1.5
make install
sudo systemctl restart hid-noded && journalctl -fu hid-noded -o cat
```


### Automatic Upgrade 
```
sudo apt install screen
screen -S upgrade
```

```
wget -O upgrade.sh https://raw.githubusercontent.com/elangrr/testnet_guide/main/hypersign/upgrade/1175300/upgrade.sh && chmod +x upgrade.sh && ./upgrade.sh
```

Exit screen `CTRL+A+D`

Reattach `screen -r upgrade`
