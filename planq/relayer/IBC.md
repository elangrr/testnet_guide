<p style="font-size:14px" align="right">
<a href="https://github.com/elangrr/testnet_guide" target="_blank">More Guide Tutorials<img src="https://avatars.githubusercontent.com/u/34649601?v=4" width="30"/></a>
</p>

<p style="font-size:14px" align="right">
<a href="https://indonode.dev/" target="_blank">Visit my website <img src="https://avatars.githubusercontent.com/u/34649601?v=4" width="30"/></a>
</p>

<p align="center">
 <img height="200" height="auto" src="https://user-images.githubusercontent.com/34649601/209750989-677f97ae-6b49-4e19-8594-5846871a9aef.png">


# Official Links
### [Official Document for IBC](https://docs.planq.network/protocol/ibc.html)
### [Planq Official Discord](https://discord.gg/cwmR8jNrNp)

# Explorer
### [Explorer](https://explorer.indonode.dev/planq_7070-2/staking)

## Minimum Requirements 
- 4 or more physical CPU cores / 8vCPU
- At least 1TB of SSD disk storage
- At least 32GB of memory (RAM)
- At least 120mbps network bandwidth

# Planq Mainnet Node Guide (Custom Port 14)  
# [Manual Install](https://github.com/elangrr/testnet_guide/blob/main/planq/manual_install.md)

# Concept

### IBC Connection
Task : `IBC`
``` 
IBC relayer:
Item 1: Cosmos Hub (channel-446) <--> Planq (channel-2) (visible as relayer operator on https://www.mintscan.io/cosmos/relayers/channel-446 ).
Item 2: Osmosis (channel-492) <--> Planq (channel-1) (visible as relayer operator on https://www.mintscan.io/osmosis/relayers/channel-492 ).
Item 3: Gravitybridge (channel-102) <--> Planq (channel-0) (visible as relayer operator on https://www.mintscan.io/gravity-bridge/relayers/channel-102).
```

# Preparations
Before setting up relayer you need to make sure you already have:

- Fully synchronized RPC nodes for each Cosmos project you want to connect
- RPC endpoints should be available from hermes service
- Indexing is set to `kv` and is enabled on each node
- For each chain you will need to have wallets that are funded with tokens. This wallets will be used to do all relayer stuff and pay commission

I recommended to install relayer in the `same machine` as your node so you can use your `localhost` for Planq Config to make it work much faster but you can install it in the `different machine` and use others RPC for the simplicity sake.
### Update System
```
sudo apt update && sudo apt upgrade -y
```

### Create Hermes Directory
```
mkdir $HOME/.hermes
```

### Download Hermes v.1.2.0
```
wget -nv https://github.com/informalsystems/hermes/releases/download/v1.2.0/hermes-v1.2.0-x86_64-unknown-linux-gnu.tar.gz
mkdir -p $HOME/.hermes/bin
tar -C $HOME/.hermes/bin/ -vxzf hermes-v1.2.0-x86_64-unknown-linux-gnu.tar.gz
echo 'export PATH="$HOME/.hermes/bin:$PATH"' >> $HOME/.bash_profile
source $HOME/.bash_profile
```

### Create Hermes Config

Please Change the value `xxx` or the RPC Settings , I Have provided other RPC resource you just need to fill it yourself 

### [RPC Relayer Resources](https://github.com/elangrr/testnet_guide/blob/main/planq/relayer/relayer_resources.md) 
```
sudo tee $HOME/.hermes/config.toml > /dev/null <<EOF
[mode]

# Specify the client mode.
[mode.clients]
enabled = false
refresh = true
misbehaviour = false

# Specify the connections mode.
[mode.connections]
enabled = false

# Specify the channels mode.
[mode.channels]
enabled = false

# Specify the packets mode.
[mode.packets]
enabled = true
clear_interval = 200
clear_on_start = true
tx_confirmation = true


[rest]
enabled = true
host = '0.0.0.0'
port = 3001

[telemetry]
enabled = true
host = '0.0.0.0'
port = 4001

######## PLANQ #####
[[chains]]
id = 'planq_7070-2'
rpc_addr = 'https://xxx/'
grpc_addr = 'https://xxx/'
websocket_addr = 'ws://xxx/websocket'

rpc_timeout = '20s'
account_prefix = 'plq'
key_name = 'relayer'
address_type = { derivation = 'ethermint', proto_type = { pk_type = '/ethermint.crypto.v1.ethsecp256k1.PubKey' } }
default_gas = 2000000
max_gas = 40000000
gas_multiplier = 1.3
store_prefix = 'ibc'
max_msg_num = 30
max_tx_size = 1800000
clock_drift = '15s'
max_block_time = '10s'

trusting_period = '7days'
memo_prefix = 'Relayed by Indonode Guide'
trust_threshold = { numerator = '1', denominator = '3' }
gas_price = { price = 30000000000, denom = 'aplanq' }


[chains.packet_filter]
policy = 'allow'
list = [
  ['transfer', 'channel-0'], # Gravity
  ['transfer', 'channel-1'], # Osmosis
  ['transfer', 'channel-2'], # Cosmos

]



###### GRAVITY ####
[[chains]]
id = 'gravity-bridge-3'
rpc_addr = 'https://xxx/'
grpc_addr = 'https://xxx/'
websocket_addr = 'wss://xxx/websocket'

rpc_timeout = '20s'
account_prefix = 'gravity'
key_name = 'relayer'
address_type = { derivation = 'cosmos' }
store_prefix = 'ibc'
default_gas = 300000
max_gas = 5000000
gas_price = { price = 0.000, denom = 'ugraviton' }
gas_multiplier = 1.4
max_msg_num = 30
max_tx_size = 1800000
clock_drift = '15s'
max_block_time = '10s'
trusting_period = '7days'
memo_prefix = 'Relayed by Indonode Guide'
trust_threshold = { numerator = '1', denominator = '3' }

[chains.packet_filter]
policy = 'allow'
list = [
  ['transfer', 'channel-102'], # Planq
  ['transfer', 'channel-0'], # Gravity
]


##### OSMOSIS ###
[[chains]]
id = 'osmosis-1'
rpc_addr = 'https://xxx/'
grpc_addr = 'https://xxx/'
websocket_addr = 'wss://xxx/websocket'

rpc_timeout = '20s'
account_prefix = 'osmo'
key_name = 'relayer'
address_type = { derivation = 'cosmos' }
store_prefix = 'ibc'
default_gas = 500000
max_gas = 120000000
gas_price = { price = 0.0026, denom = 'uosmo' }
gas_multiplier = 1.8
max_msg_num = 30
max_tx_size = 1800000
clock_drift = '15s'
max_block_time = '10s'
trusting_period = '7days'
memo_prefix = 'Relayed by Indonode Guide'
trust_threshold = { numerator = '1', denominator = '3' }

[chains.packet_filter]
policy = 'allow'
list = [
   ['transfer', 'channel-492'], # Planq
        ['transfer', 'channel-1'], # Osmosis

]


##### Cosmos ###
[[chains]]
id = 'cosmoshub-4'
rpc_addr = 'https://xxx/'
grpc_addr = 'https://xxx/'
websocket_addr = 'wss://xxx/websocket'

rpc_timeout = '20s'
account_prefix = 'cosmos'
key_name = 'relayer'
address_type = { derivation = 'cosmos' }
store_prefix = 'ibc'
default_gas = 300000
max_gas = 3500000
gas_price = { price = 0.00005, denom = 'uatom' }
gas_multiplier = 1.3
max_msg_num = 30
max_tx_size = 150000
clock_drift = '5s'
max_block_time = '30s'
trusting_period = '14days'
memo_prefix = 'Relayed by Indonode Guide'
trust_threshold = { numerator = '1', denominator = '3' }

[chains.packet_filter]
policy = 'allow'
list = [

   ['transfer', 'channel-446'], # planq
   ['transfer', 'channel-2'], # Cosmos


]

EOF
```

### Verify the Hermes configuration is correct 
```
hermes health-check
```

It will show `logs` like this 
```
2023-01-26T01:59:14.925247Z  INFO ThreadId(01) using default configuration from '/root/.hermes/config.toml'
2023-01-26T01:59:14.925596Z  INFO ThreadId(01) running Hermes v1.2.0+061f14f
2023-01-26T01:59:14.925638Z  INFO ThreadId(01) health_check{chain=planq_7070-2}: performing health check...
2023-01-26T01:59:14.930287Z  WARN ThreadId(10) health_check{chain=planq_7070-2}: Chain 'planq_7070-2' has no minimum gas price value configured for denomination 'aplanq'. This is usually a sign of misconfiguration, please check your config.toml
2023-01-26T01:59:14.933807Z  INFO ThreadId(01) health_check{chain=planq_7070-2}: chain is healthy
2023-01-26T01:59:14.933833Z  INFO ThreadId(01) health_check{chain=gravity-bridge-3}: performing health check...
2023-01-26T01:59:14.999070Z  WARN ThreadId(28) health_check{chain=gravity-bridge-3}: Chain 'gravity-bridge-3' has no minimum gas price value configured for denomination 'ugraviton'. This is usually a sign of misconfiguration, please check your config.toml
2023-01-26T01:59:15.010934Z  INFO ThreadId(01) health_check{chain=gravity-bridge-3}: chain is healthy
2023-01-26T01:59:15.010956Z  INFO ThreadId(01) health_check{chain=osmosis-1}: performing health check...
2023-01-26T01:59:15.071233Z  WARN ThreadId(38) health_check{chain=osmosis-1}: Chain 'osmosis-1' has no minimum gas price value configured for denomination 'uosmo'. This is usually a sign of misconfiguration, please check your config.toml
2023-01-26T01:59:15.087534Z  INFO ThreadId(01) health_check{chain=osmosis-1}: chain is healthy
2023-01-26T01:59:15.087556Z  INFO ThreadId(01) health_check{chain=cosmoshub-4}: performing health check...
2023-01-26T01:59:15.102124Z  WARN ThreadId(48) health_check{chain=cosmoshub-4}: Chain 'cosmoshub-4' has no minimum gas price value configured for denomination 'uatom'. This is usually a sign of misconfiguration, please check your config.toml
2023-01-26T01:59:15.113049Z  INFO ThreadId(01) health_check{chain=cosmoshub-4}: chain is healthy
SUCCESS performed health check for all chains in the config
```

### Recover wallet using mnemonic files
```
echo "$MNEMONIC" > $HOME/.hermes.mnemonic
hermes keys add --chain "$CHAIN_ID" --key-name relayer --hd-path "m/44'/60'/0'/0/0" --mnemonic-file $HOME/.hermes.mnemonic
rm $HOME/.hermes.mnemonic
MNEMONIC='word scare connect prison angry jazz help panther museum hope antenna all voyage fame shiver sing life zone era abstract busy bamboo own dune'
CHAIN_ID=planq_7070-2

echo "$MNEMONIC" > $HOME/.hermes.mnemonic
hermes keys add --chain "$CHAIN_ID" --mnemonic-file $HOME/.hermes.mnemonic
rm $HOME/.hermes.mnemonic
```
### for planq, if the address is different from the one in the keplr wallet, please use this
```
echo "$MNEMONIC" > $HOME/.hermes.mnemonic
hermes keys add --chain "$CHAIN_ID" --key-name relayer --hd-path "m/44'/60'/0'/0/0" --mnemonic-file $HOME/.hermes.mnemonic
rm $HOME/.hermes.mnemonic
```
 
 Change the value of `CHAIN_ID=` and `MNEMONIC` according to the mnemonic and chains you wanna connect so you `Have` to enter this command 4 Times with differrent `CHAIN_ID`

Successful output :
```
2022-09-16T22:45:52.385884Z  INFO ThreadId(01) using default configuration from '/root/.hermes/config.toml'
SUCCESS Restored key 'relayer' (osmo15cdqegpd9t7ujda9yapzgpa3x2zsgrjzvtr7ck) on chain osmosis-1
```

### Create Hermes Service 
```
sudo tee /etc/systemd/system/hermesd.service > /dev/null <<EOF
[Unit]
Description=hermes
After=network-online.target

[Service]
User=$USER
ExecStart=$(which hermes) start
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable hermesd
```

### Start Hermes and Check logs
```
sudo systemctl start hermesd && journalctl -u hermesd -f -o cat
```

Successful output should be like ths 
```
  - Client: 07-tendermint-1
    * Connection: connection-0
      | State: OPEN
      | Counterparty state: OPEN
      + Channel: channel-0
        | Port: transfer
        | State: OPEN
        | Counterparty: channel-102
  - Client: 07-tendermint-3
    * Connection: connection-2
      | State: OPEN
      | Counterparty state: OPEN
      + Channel: channel-1
        | Port: transfer
        | State: OPEN
        | Counterparty: channel-492
  - Client: 07-tendermint-5
    * Connection: connection-3
      | State: OPEN
      | Counterparty state: OPEN
      + Channel: channel-2
        | Port: transfer
        | State: OPEN
        | Counterparty: channel-446
# Chain: gravity-bridge-3
  - Client: 07-tendermint-195
    * Connection: connection-165
      | State: OPEN
      | Counterparty state: OPEN
      + Channel: channel-102
        | Port: transfer
        | State: OPEN
        | Counterparty: channel-0
# Chain: osmosis-1
  - Client: 07-tendermint-2318
    * Connection: connection-1815
      | State: OPEN
      | Counterparty state: OPEN
      + Channel: channel-492
        | Port: transfer
        | State: OPEN
        | Counterparty: channel-1
# Chain: cosmoshub-4
  - Client: 07-tendermint-994
    * Connection: connection-693
      | State: OPEN
      | Counterparty state: OPEN
      + Channel: channel-446
        | Port: transfer
        | State: OPEN
        | Counterparty: channel-2
2023-01-26T01:49:19.025930Z  INFO ThreadId(01) spawn:chain{chain=planq_7070-2}:client{client=07-tendermint-1}:connection{connection=connection-0}: connection is OPEN, state on destination chain is OPEN chain=planq_7070-2 connection=connection-0 counterparty_chain=gravity-bridge-3
2023-01-26T01:49:19.025938Z  INFO ThreadId(01) spawn:chain{chain=planq_7070-2}:client{client=07-tendermint-1}:connection{connection=connection-0}: connection is already open, not spawning Connection worker chain=planq_7070-2 connection=connection-0
2023-01-26T01:49:19.025945Z  INFO ThreadId(01) spawn:chain{chain=planq_7070-2}:client{client=07-tendermint-1}:connection{connection=connection-0}: no connection workers were spawn chain=planq_7070-2 connection=connection-0
2023-01-26T01:49:19.025953Z  INFO ThreadId(01) spawn:chain{chain=planq_7070-2}:client{client=07-tendermint-1}:connection{connection=connection-0}:channel{channel=channel-0}: channel is OPEN, state on destination chain is OPEN chain=planq_7070-2 counterparty_chain=gravity-bridge-3 channel=channel-0
2023-01-26T01:49:19.031962Z  INFO ThreadId(01) spawn:chain{chain=planq_7070-2}:client{client=07-tendermint-1}:connection{connection=connection-0}: no channel workers were spawned chain=planq_7070-2 channel=channel-0
2023-01-26T01:49:19.032002Z  INFO ThreadId(01) spawn:chain{chain=planq_7070-2}:client{client=07-tendermint-3}:connection{connection=connection-2}: connection is OPEN, state on destination chain is OPEN chain=planq_7070-2 connection=connection-2 counterparty_chain=osmosis-1
2023-01-26T01:49:19.032010Z  INFO ThreadId(01) spawn:chain{chain=planq_7070-2}:client{client=07-tendermint-3}:connection{connection=connection-2}: connection is already open, not spawning Connection worker chain=planq_7070-2 connection=connection-2
2023-01-26T01:49:19.032017Z  INFO ThreadId(01) spawn:chain{chain=planq_7070-2}:client{client=07-tendermint-3}:connection{connection=connection-2}: no connection workers were spawn chain=planq_7070-2 connection=connection-2
2023-01-26T01:49:19.032024Z  INFO ThreadId(01) spawn:chain{chain=planq_7070-2}:client{client=07-tendermint-3}:connection{connection=connection-2}:channel{channel=channel-1}: channel is OPEN, state on destination chain is OPEN chain=planq_7070-2 counterparty_chain=osmosis-1 channel=channel-1
2023-01-26T01:49:19.041196Z  INFO ThreadId(01) spawn:chain{chain=planq_7070-2}:client{client=07-tendermint-3}:connection{connection=connection-2}: no channel workers were spawned chain=planq_7070-2 channel=channel-1
2023-01-26T01:49:19.041241Z  INFO ThreadId(01) spawn:chain{chain=planq_7070-2}:client{client=07-tendermint-5}:connection{connection=connection-3}: connection is OPEN, state on destination chain is OPEN chain=planq_7070-2 connection=connection-3 counterparty_chain=cosmoshub-4
2023-01-26T01:49:19.041250Z  INFO ThreadId(01) spawn:chain{chain=planq_7070-2}:client{client=07-tendermint-5}:connection{connection=connection-3}: connection is already open, not spawning Connection worker chain=planq_7070-2 connection=connection-3
2023-01-26T01:49:19.041259Z  INFO ThreadId(01) spawn:chain{chain=planq_7070-2}:client{client=07-tendermint-5}:connection{connection=connection-3}: no connection workers were spawn chain=planq_7070-2 connection=connection-3
2023-01-26T01:49:19.041269Z  INFO ThreadId(01) spawn:chain{chain=planq_7070-2}:client{client=07-tendermint-5}:connection{connection=connection-3}:channel{channel=channel-2}: channel is OPEN, state on destination chain is OPEN chain=planq_7070-2 counterparty_chain=cosmoshub-4 channel=channel-2
2023-01-26T01:49:19.054051Z  INFO ThreadId(01) spawn:chain{chain=planq_7070-2}:client{client=07-tendermint-5}:connection{connection=connection-3}: no channel workers were spawned chain=planq_7070-2 channel=channel-2
2023-01-26T01:49:19.054087Z  INFO ThreadId(01) spawn:chain{chain=planq_7070-2}:client{client=07-tendermint-53}:connection{connection=connection-38}: connection is OPEN, state on destination chain is OPEN chain=planq_7070-2 connection=connection-38 counterparty_chain=stride-1
2023-01-26T01:49:19.054095Z  INFO ThreadId(01) spawn:chain{chain=planq_7070-2}:client{client=07-tendermint-53}:connection{connection=connection-38}: connection is already open, not spawning Connection worker chain=planq_7070-2 connection=connection-38
2023-01-26T01:49:19.054101Z  INFO ThreadId(01) spawn:chain{chain=planq_7070-2}:client{client=07-tendermint-53}:connection{connection=connection-38}: no connection workers were spawn chain=planq_7070-2 connection=connection-38
2023-01-26T01:49:19.054109Z  INFO ThreadId(01) spawn:chain{chain=planq_7070-2}:client{client=07-tendermint-53}:connection{connection=connection-38}:channel{channel=channel-8}: channel is OPEN, state on destination chain is OPEN chain=planq_7070-2 counterparty_chain=stride-1 channel=channel-8
2023-01-26T01:49:19.059449Z  INFO ThreadId(01) spawn:chain{chain=planq_7070-2}:client{client=07-tendermint-53}:connection{connection=connection-38}: no channel workers were spawned chain=planq_7070-2 channel=channel-8
2023-01-26T01:49:19.059538Z  INFO ThreadId(01) spawn:chain{chain=planq_7070-2}: spawning Wallet worker: wallet::planq_7070-2
2023-01-26T01:49:19.059569Z  INFO ThreadId(01) spawn:chain{chain=gravity-bridge-3}:client{client=07-tendermint-195}:connection{connection=connection-165}: connection is OPEN, state on destination chain is OPEN chain=gravity-bridge-3 connection=connection-165 counterparty_chain=planq_7070-2
2023-01-26T01:49:19.059579Z  INFO ThreadId(01) spawn:chain{chain=gravity-bridge-3}:client{client=07-tendermint-195}:connection{connection=connection-165}: connection is already open, not spawning Connection worker chain=gravity-bridge-3 connection=connection-165
2023-01-26T01:49:19.059585Z  INFO ThreadId(01) spawn:chain{chain=gravity-bridge-3}:client{client=07-tendermint-195}:connection{connection=connection-165}: no connection workers were spawn chain=gravity-bridge-3 connection=connection-165
2023-01-26T01:49:19.059592Z  INFO ThreadId(01) spawn:chain{chain=gravity-bridge-3}:client{client=07-tendermint-195}:connection{connection=connection-165}:channel{channel=channel-102}: channel is OPEN, state on destination chain is OPEN chain=gravity-bridge-3 counterparty_chain=planq_7070-2 channel=channel-102
2023-01-26T01:49:19.068444Z  INFO ThreadId(01) spawn:chain{chain=gravity-bridge-3}:client{client=07-tendermint-195}:connection{connection=connection-165}: no channel workers were spawned chain=gravity-bridge-3 channel=channel-102
2023-01-26T01:49:19.068521Z  INFO ThreadId(01) spawn:chain{chain=gravity-bridge-3}: spawning Wallet worker: wallet::gravity-bridge-3
2023-01-26T01:49:19.068548Z  INFO ThreadId(01) spawn:chain{chain=osmosis-1}:client{client=07-tendermint-2318}:connection{connection=connection-1815}: connection is OPEN, state on destination chain is OPEN chain=osmosis-1 connection=connection-1815 counterparty_chain=planq_7070-2
2023-01-26T01:49:19.068558Z  INFO ThreadId(01) spawn:chain{chain=osmosis-1}:client{client=07-tendermint-2318}:connection{connection=connection-1815}: connection is already open, not spawning Connection worker chain=osmosis-1 connection=connection-1815
2023-01-26T01:49:19.068564Z  INFO ThreadId(01) spawn:chain{chain=osmosis-1}:client{client=07-tendermint-2318}:connection{connection=connection-1815}: no connection workers were spawn chain=osmosis-1 connection=connection-1815
2023-01-26T01:49:19.068571Z  INFO ThreadId(01) spawn:chain{chain=osmosis-1}:client{client=07-tendermint-2318}:connection{connection=connection-1815}:channel{channel=channel-492}: channel is OPEN, state on destination chain is OPEN chain=osmosis-1 counterparty_chain=planq_7070-2 channel=channel-492
2023-01-26T01:49:19.083206Z  INFO ThreadId(01) spawn:chain{chain=osmosis-1}:client{client=07-tendermint-2318}:connection{connection=connection-1815}: no channel workers were spawned chain=osmosis-1 channel=channel-492
2023-01-26T01:49:19.083295Z  INFO ThreadId(01) spawn:chain{chain=osmosis-1}: spawning Wallet worker: wallet::osmosis-1
2023-01-26T01:49:19.083322Z  INFO ThreadId(01) spawn:chain{chain=cosmoshub-4}:client{client=07-tendermint-994}:connection{connection=connection-693}: connection is OPEN, state on destination chain is OPEN chain=cosmoshub-4 connection=connection-693 counterparty_chain=planq_7070-2
2023-01-26T01:49:19.083330Z  INFO ThreadId(01) spawn:chain{chain=cosmoshub-4}:client{client=07-tendermint-994}:connection{connection=connection-693}: connection is already open, not spawning Connection worker chain=cosmoshub-4 connection=connection-693
2023-01-26T01:49:19.083338Z  INFO ThreadId(01) spawn:chain{chain=cosmoshub-4}:client{client=07-tendermint-994}:connection{connection=connection-693}: no connection workers were spawn chain=cosmoshub-4 connection=connection-693
2023-01-26T01:49:19.083346Z  INFO ThreadId(01) spawn:chain{chain=cosmoshub-4}:client{client=07-tendermint-994}:connection{connection=connection-693}:channel{channel=channel-446}: channel is OPEN, state on destination chain is OPEN chain=cosmoshub-4 counterparty_chain=planq_7070-2 channel=channel-446
2023-01-26T01:49:19.119714Z  INFO ThreadId(01) spawn:chain{chain=cosmoshub-4}:client{client=07-tendermint-994}:connection{connection=connection-693}: no channel workers were spawned chain=cosmoshub-4 channel=channel-446
2023-01-26T01:49:19.119807Z  INFO ThreadId(01) spawn:chain{chain=cosmoshub-4}: spawning Wallet worker: wallet::cosmoshub-4
2023-01-26T01:49:19.119834Z  INFO ThreadId(01) spawn:chain{chain=stride-1}:client{client=07-tendermint-55}:connection{connection=connection-34}: connection is OPEN, state on destination chain is OPEN chain=stride-1 connection=connection-34 counterparty_chain=planq_7070-2
```

You should see your Operator Address in the Operator list in these channels : 

Check your Operator Address!

If your address wont show , sometimes it takes a little while just be patient!

`Cosmos` : https://www.mintscan.io/cosmos/relayers/channel-446

`Osmosis` : https://www.mintscan.io/osmosis/relayers/channel-492

`Gravity` : https://www.mintscan.io/gravity-bridge/relayers/channel-102


If your address already showed , Congratulatons ! You are already Relayer Operator!

### Commands 
Check Wallet Address
```
hermes keys list --chain <CHAIN_ID>
```
Check Wallet Balances
```
hermes keys balance --chain <CHAIN_ID>
```
Delete Wallet
```
hermes keys delete --chain <CHAIN_ID> --key-name <KEY_NAME>
```
Check Hermes Health 
```
hermes health-check
```

Stop Hermes : 
``` 
sudo systemctl stop hermesd
```

Start Hermes : 
```
sudo systemctl start hermesd
```

Restart Hermes : 
```
sudo systemctl restart hermesd
```

Check logs : 
```
sudo journalctl -fu hermesd -o cat
```

Check Status : 
```
sudo systemctl status hermesd
```

### Remove Hermes ( THIS WILL REMOVE YOUR HERMES AND CONFIG COMPLETELY! )
```
sudo systemctl stop hermesd
sudo systemctl disable hermesd
sudo rm /etc/systemd/system/hermesd* -rf
sudo rm $(which hermes) -rf
sudo rm -rf $HOME/.hermes
sudo rm -rf $HOME/hermes*
```

