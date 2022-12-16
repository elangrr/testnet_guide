#!/bin/bash

update_node() {
  sudo systemctl stop defundd
  cd $HOME && rm -rf defund
  git clone https://github.com/defund-labs/defund
  cd defund
  git checkout $VERSION
  make install
  sudo systemctl restart defundd && journalctl -fu defundd -o cat
}

BLOCK=5554316
VERSION=v0.2.0

echo "Your node will be updated to version $VERSION on block number $BLOCK"

while true; do
  height=$(defundd status --node tcp://localhost:26657 | jq -r .SyncInfo.latest_block_height || echo 0)

  if ((height >= BLOCK)); then
    update_node && sleep 60
    height=$(defundd status --node tcp://localhost:26657 | jq -r .SyncInfo.latest_block_height || echo 0)
    if ((height > BLOCK)); then
      echo "Your node was successfully updated to version $VERSION"
    fi
    defundd version --long | head
    break
  else
    echo "$height ($(( BLOCK - height  )) blocks left)"
  fi

  sleep 5
done
