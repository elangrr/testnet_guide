Nexus Node Install Guide

***MAKE SURE YOUR MACHINE MEETS THE REQUIREMENTS*

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

