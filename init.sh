#!/bin/bash
# INITIALIZE VM

apt-get update -y
apt-get install -y docker.io
service docker start

echo "deb [trusted=yes] https://apt.fury.io/kurtosis-tech/ /" | sudo tee /etc/apt/sources.list.d/kurtosis.list

apt update
apt install -y kurtosis-cli=0.89.18

./scripts/tool_check.sh || exit 1

kurtosis clean --all
# kurtosis run --enclave cdk-v1 --args-file params.yml --image-download always .