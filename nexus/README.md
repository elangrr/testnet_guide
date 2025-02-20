Nexus Node Install Guide

## MAKE SURE YOUR MACHINE MEETS THE REQUIREMENTS ##
## RECOMMENDED SPECS ##
### 4 CORES, 16GB RAM, 100GB SSD ###


Install Depencies 
```
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl git build-essential pkg-config libssl-dev unzip
```

Install Cargo and Rust
```
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```
Choose 1 and wait.

Run this command after
```
source $HOME/.cargo/env
```
Install Protobuff
```
wget https://github.com/protocolbuffers/protobuf/releases/download/v26.1/protoc-26.1-linux-x86_64.zip
unzip protoc-26.1-linux-x86_64.zip -d $HOME/.local
export PATH="$HOME/.local/bin:$PATH"
```
Check Protobuf
```
protoc --version
```
Make Permanent
```
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```
Install Required Depencies for Rust
```
cargo install protobuf-codegen
rustup target add riscv32i-unknown-none-elf
rustup component add rust-src
```

Enter Screen mode
```
screen -S nexus-node
```

Install Nexus CLI & Start
```
curl https://cli.nexus.xyz/ | sh 
```
Choose Option 2 - Follow the instruction

`CTRL+A+D` to detach from screen

To re-enter the logs
```
screen -r nexus-node
```


## Memory Problem and how to fix it (OPTIONAL DON'T DO THIS IF YOU DIDNT FACE ANY PROBLEM!)

* If you have problem like this or similiar *
 ```
[108662.441887] Out of memory: Killed process 16662 (nexus-network) total-vm:18982324kB, anon-rss:6876640kB, file-rss:0kB, shmem-rss:0kB, UID:1000 pgtables:32604kB oom_score_adj:0
```
You probably ran out of memory / RAM

Create SWAP File
```
sudo fallocate -l 8G /swapfile
```

```
sudo chmod 600 /swapfile
```
```
sudo mkswap /swapfile
```
```
sudo swapon /swapfile
```
```
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
```

Verify its active
```
free -h
```
Usually its like this
```
               total        used        free      shared  buff/cache   available
Mem:            8Gi        5Gi        1Gi       500Mi        2Gi        3Gi
Swap:           4Gi        0Gi        4Gi
```
Reboot (Optional but highly recommended)
```
sudo reboot
```
 
