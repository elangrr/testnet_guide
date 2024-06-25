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
