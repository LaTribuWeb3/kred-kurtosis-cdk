#!/bin/bash

# Check if an argument is provided
if [ $# -eq 0 ]; then
	echo "Usage: $0 <hostname>"
	exit 1
fi

HOSTNAME=$1

# Create a temporary script file
TEMP_SCRIPT=$(mktemp /tmp/get_rpc_urls.XXXXXX)

# Write the script to the temporary file
cat << 'EOF' > $TEMP_SCRIPT
ip_address=$(ip addr show eth0 | grep 'inet ' | awk '{print $2}' | cut -d'/' -f1)
l1_port=$(docker ps | grep el-1-geth-lighthouse | grep 8545/tcp | awk '{print $1}' | xargs -I {} docker port {} | grep 8545/tcp | cut -d':' -f2)
l2_port=$(docker ps | grep "node-rpc" | grep 8123/tcp | awk '{print $1}' | xargs -I {} docker port {} | grep 8123/tcp | cut -d':' -f2)
echo "export L1_RPC_URL=http://$ip_address:$l1_port"
echo "export L2_RPC_URL=http://$ip_address:$l2_port"
EOF

# Transfer the script to the remote host, silencing the output
scp -q $TEMP_SCRIPT $HOSTNAME:/tmp/get_rpc_url.sh

# Execute the script on the remote host, suppressing stderr and skipping the banner
ssh -o LogLevel=ERROR $HOSTNAME 'bash /tmp/get_rpc_url.sh' 2>/dev/null

# Clean up: remove the temporary script from local and remote host
rm $TEMP_SCRIPT
ssh -o LogLevel=ERROR $HOSTNAME 'rm /tmp/get_rpc_url.sh' 2>/dev/null