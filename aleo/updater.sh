#!/bin/bash

cd $HOME/snarkOS
while :
do
  echo "Checking for updates..."
  # git reset --hard
  rm Cargo.lock
  STATUS=$(git pull)

  echo $STATUS
  
  if [ "$STATUS" != "Already up to date." ]; then
	source $HOME/.cargo/env
	cargo clean
	cargo install --path .
	if [[ `service aleo-client status | grep active` =~ "running" ]]; then
	  echo "Aleo Node is active"
	  systemctl stop aleo-client
	  ALEO_IS_MINER=false
	fi
	if [[ `service aleo-prover status | grep active` =~ "running" ]]; then
	  echo "Aleo Miner is active"
	  systemctl stop aleo-prover
	  ALEO_IS_MINER=true
	fi
	if [[ `echo $ALEO_IS_MINER` =~ "false" ]]; then
	  echo "Aleo Node restarted"
	  systemctl restart aleo-client
	fi
	if [[ `echo $ALEO_IS_MINER` =~ "true" ]]; then
	  echo "Aleo Miner restarted"
	  systemctl restart aleo-prover
	fi
  fi
  # $COMMAND & sleep 1800; kill $!
  sleep 1800
done
