</p>
<p style="font-size:14px" align="right">
<a href="https://discord.gg/WDgKb8GbCC" target="_blank">Join ICW Chain Discord<img src="https://user-images.githubusercontent.com/50621007/176236430-53b0f4de-41ff-41f7-92a1-4233890a90c8.png" width="30"/></a>
</p>

<p style="font-size:14px" align="right">
<a href="https://github.com/elangrr/testnet_guide" target="_blank">More Guide Tutorials<img src="https://avatars.githubusercontent.com/u/34649601?v=4" width="30"/></a>
</p>

<p style="font-size:14px" align="right">
<a href="https://indonode.dev/" target="_blank">Visit my website <img src="https://avatars.githubusercontent.com/u/34649601?v=4" width="30"/></a>
</p>

</p>
<p style="font-size:14px" align="right">
<a href="https://discord.gg/gru6MuGPgP" target="_blank">Join NodeX Capital Network Discord<img src="https://user-images.githubusercontent.com/50621007/176236430-53b0f4de-41ff-41f7-92a1-4233890a90c8.png" width="30"/></a>
</p>

<p align="center">
 <img height="150" height="auto" src="https://miro.medium.com/fit/c/176/176/0*Fje3iR1h1XcvlRx8">
</p>

# Official Links
### [ICW Chain Official Website](https://www.icwchain.com/)


## Minimum Requirements 
- 4-core CPU 
- 8G memory
- 50G available disk space
- 2M bandwidth.
## Recommended system requirements
- 8-core CPU 
- 16G memory 
- 200G available hard disk space
-10 M bandwidth.

## Pre-Installation
Install and run screen
```
sudo apt install screen && \
screen -S icw
```

## Node Install Tutorial
### Auto install script 
```
wget -O icw_test.sh https://raw.githubusercontent.com/elangrr/testnet_guide/main/icw/icw_test.sh && chmod +x icw_test.sh && ./icw_test.sh
```
1. For Quick Install
2. For Entering Command Module (PRESS `CTRL+A+D` TO EXIT COMMAND MODULE)
3. Delete Wallet and Node
4. Exit program

If you want to enter command module simply type
```
screen -r icw
```
Check Node Sync (MUST BE IN COMMAND MODULE!)
```
network info
```

 <img height="300" height="auto" src="https://user-images.githubusercontent.com/34649601/194700959-347549b0-f9c3-4877-a6ae-a5c90d3d21e1.png">
</p>

Synchronization is complete when localBestHeight equals netBestHeight

`Note: The speed of synchronizing the height of the block is related to the network speed
of the machine.`

### Import Your on-chain account 
Once your node is Synced, import your on-chain private key

In CMD-Module type 
```
import <private-key>
```
Example : `import 6d6e510702da8aed3d2a5dc5a3140736b4b392ad44415xxxxxxxxxxxxxxx`

Please enter the password (password is between 8 and 20 inclusive of numbers and
letters)
### Import your package account
Import your package account private key (NOT ON-CHAIN ACCOUNT !!)
```
import <private-key>
```
Example : `import 5f190d5cd251093539fa3229db4663b04c1a7b236d9874c59xxxxxxxxxxxx`

Please enter the password (password is between 8 and 20 inclusive of numbers and
letters)


