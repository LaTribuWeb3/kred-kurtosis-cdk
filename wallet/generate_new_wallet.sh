apt update
apt install -y nodejs npm jq

npm init -y

curl -L https://foundry.paradigm.xyz | bash

source /root/.bashrc
foundryup

node generate_mnemonic.js