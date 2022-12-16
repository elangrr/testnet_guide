### Manual Upgrade Block 5554316

DO NOT UPGRADE TILL IT REACH BLOCK `5554316`
```
sudo systemctl stop defundd
cd $HOME && rm -rf defund
git clone https://github.com/defund-labs/defund
cd defund
git checkout $VERSION
make install
sudo systemctl restart defundd && journalctl -fu defundd -o cat
```

### Auto Upgrade : 
```
sudo apt install screen 
screen -S upgrade
```
```
wget -O upgrade.sh https://raw.githubusercontent.com/elangrr/testnet_guide/main/defund/upgrade/5554316/upgrade.sh && chmod +x upgrade.sh && ./upgrade.sh
```

Exit screen `CTRL+A+D` Reattach screen `screen -r upgrade`
