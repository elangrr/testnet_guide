# Running nubit Light node phase 2 with service file

Run Nubit Node
```bash
curl -sL1 https://nubit.sh | bash
```

### After got the logs Save your mnemonic , Pubkey , and auth Key !

You can see your mnemnic using this command 
```bash
cat nubit-node/mnemonic.txt
```

Set Nubit light node as Service so you dont have to use screen or tmux

```bash
sudo tee /etc/systemd/system/nubit-light.service > /dev/null << EOF
[Unit]
Description=Nubit Light Node
After=network-online.target

[Service]
User=$USER
ExecStart=/bin/bash -c 'curl -sL https://nubit.sh | bash'
Restart=always
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF
```

Enable Services
```bash
sudo systemctl daemon-reload
sudo systemctl enable nubit-light.service
```
Start the node 
```bash
sudo systemctl start nubit-light.service
```

To check the logs , CTRL + C to quit and your node will run in the background
```bash
sudo journalctl -fu nubit-light.service -o cat
```


# Useful Commands 

To start the node 
```bash
sudo systemctl start nubit-light.service
```

To restart the node 
```bash
sudo systemctl restart nubit-light.service
```
To stop the node

```bash
sudo systemctl stop nubit-light.service
```
To check the logs 
```bash
sudo journalctl -fu nubit-light.service -o cat
```

View your key list
```bash
$HOME/nubit-node/bin/nkey list --p2p.network nubit-alphatestnet-1 --node.type light
```

View your private key
```bash
$HOME/nubit-node/bin/nkey export my_nubit_key --unarmored-hex --unsafe --p2p.network nubit-alphatestnet-1 --node.type light
```

Check Pubkey
```bash
$HOME/nubit-node/bin/nkey list --p2p.network nubit-alphatestnet-1 --node.type light
```

Import keys using Seed phrase
```bash
$HOME/nubit-node/bin/nkey add my_keplr_key --recover --keyring-backend test --node.type light --p2p.network nubit-alphatestnet-1
```

Import keys using private keys
```bash
$HOME/nubit-node/bin/nkey import my_nubit_key ~/nubit-da/nubit-node/account1.private --keyring-backend test --node.type light --p2p.network nubit-alphatestnet-1
```

Delete keys (WARNING!!! THIS WILL DELETE YOUR KEYS FOREVER!!!!)
```bash
rm -rf $HOME/.nubit-light-nubit-alphatestnet-1
```

