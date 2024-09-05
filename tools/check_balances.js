const fs = require('fs');
const yaml = require('js-yaml');
const { ethers } = require('ethers');
const path = require('path');

// Function to read the YAML file
function readYaml(filePath) {
    const fileContents = fs.readFileSync(filePath, 'utf8');
    return yaml.load(fileContents);
}

// Function to get balance
async function getBalance(address, provider) {
    const balance = await provider.getBalance(address);
    return ethers.formatEther(balance);
}

// Main script
async function main() {
    // Read the YAML file from one level up
    const params = readYaml(path.join(__dirname, '..', 'params.yml'));
    
    // Extract the RPC URL (assuming we use the funding_rpc_url)
    const rpcUrl = params.args.l1_rpc_url.funding_rpc_url;
    
    // Connect to the Ethereum network
    const provider = new ethers.JsonRpcProvider(rpcUrl);
    
    // Regular expression to match zkevm_l2_*_address fields
    const addressPattern = /^zkevm_l2_.*_address$/;
    
    // Find all matching address fields and check their balances
    for (const [key, value] of Object.entries(params.args)) {
        if (addressPattern.test(key)) {
            const address = value;
            const balance = await getBalance(address, provider);
            console.log(`${key}: ${address}`);
            console.log(`Balance: ${balance} ETH`);
            console.log("-".repeat(40));
        }
    }
}

main().catch(console.error);
