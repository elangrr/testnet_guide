# Advanced Redbelly Mainnet Node Monitoring Bot (Python)

## 🎯 What it monitors:

✅ Block height & sync status

✅ Governor status (Governor/Candidate)

✅ Signing balance & certificate validity

✅ Block processing rate & sync times

✅ Instant alerts for issues + recovery notifications

## Setup

### Download Script 
```bash
wget https://raw.githubusercontent.com/elangrr/testnet_guide/refs/heads/main/redbelly-mainnet/monitoring/monitor.py
```

Add these flags to your redbelly systemd service file
```bash
--statusserver.addr=127.0.0.1 --statusserver.port=6539 --prometheus.addr=127.0.0.1
```

### Guide : 

Install Python and its requirements
```
sudo apt update
sudo apt install python3 python3-pip python3-venv
```

Stop redbelly service
```bash
sudo systemctl stop redbelly.service
```
Edit the service file

```
sudo nano /etc/systemd/system/redbelly.service
```

find the `ExecStart` and make sure it is setup this way
```bash
ExecStart=(your other flags) --statusserver.addr=127.0.0.1 --statusserver.port=6539 --prometheus.addr=127.0.0.1 --mainnet
```

Reload and restart Redbelly
```bash
sudo systemctl daemon-reload
sudo systemctl restart redbelly.service
sudo systemctl status redbelly.service
```

you can do as you like to the script but I like to use `screen` following with python virtual environment

Go into `screen`
```bash
screen -S redbelly_monitor
```

Setup the python Environment
```bash
python3 -m venv redbelly_monitor_env
source redbelly_monitor_env/bin/activate
```

Install Requirements
```
pip install requests python-dateutil
```

Inside the Virtual Environment add your telegram bot variable
```
export REDBELLY_TELEGRAM_TOKEN="YOUR_TELEGRAM_BOT_TOKEN"
export REDBELLY_TELEGRAM_CHAT_ID="YOUR_TELEGRAM_BOT_CHAT_ID" 
export REDBELLY_MIN_BALANCE=10
export REDBELLY_TELEGRAM_INTERVAL=3600
```

Change the variable to yours , `REDBELLY_MIN_BALANCE` means it will alert you when the sign wallet balance is less than 10 RBNT

* By default it will send notification every hour , but you can edit the `REDBELLY_TELEGRAM_INTERVAL` in seconds 3600 = 1 Hour

## Run the Script

inside virtual environment 
```bash
python monitor.py
```

Detach screen using `CTRL+A+D` 

If you want to stop the screen simply 

```bash
screen -r redbelly_monitor
```
and `CTRL+C`
