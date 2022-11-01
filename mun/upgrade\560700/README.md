# (Option 1) Manual
when the block reached `560700` you will get an error , then proceed to upgrade your node :
```
sudo systemctl stop mund
cd $HOME && sudo rm -rf $HOME/mun
git clone https://github.com/munblockchain/mun.git
cd mun
make install
sudo systemctl restart mund && journalctl -fu mund -o cat
```

# (Option 2) Auto upgrade
Will upgrade your node to v.2.0.0 when block reached `560700`

But first you need to run it on screen so it doesnt stop when session get disconnected 
```
sudo apt install screen
screen -S upgrade
```
Then run the automatic command
```
wget -O upgrade.sh https://raw.githubusercontent.com/elangrr/testnet_guide/main/mun/upgrade%5C560700/upgrade.sh && chmod +x upgrade.sh && ./upgrade.sh
```

After running you will see the node is counting the blocks , press `CTRL+A+D` to detach from screen session.

To reattach run `screen -Rd upgrade`
