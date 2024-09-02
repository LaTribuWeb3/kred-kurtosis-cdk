const ethers = require('ethers');
const yaml = require('js-yaml');
const fs = require('fs');

require('dotenv').config();

if (!process.env.INIT_PRIVATE_KEY) {
  console.error('INIT_PRIVATE_KEY is not set in the .env file');
  process.exit(1);
}

async function sendEthToAddresses() {
  // Load the params.yml file
  const paramsFile = fs.readFileSync('params.yml', 'utf8');
  const params = yaml.load(paramsFile);

  // Connect to the network (assuming it's the network specified in params.yml)
  const provider = new ethers.JsonRpcProvider(params.args.l1_rpc_url.funding_rpc_url);

  // Create a wallet using the provided private key
  const wallet = new ethers.Wallet(process.env.INIT_PRIVATE_KEY, provider);

  // Find all zkevm_l2_*_address entries
  const addresses = Object.entries(params.args)
    .filter(([key, value]) => key.startsWith('zkevm_l2_') && key.endsWith('_address'))
    .map(([_, value]) => value);

  // Send 0.5 ETH to each address
  for (const address of addresses) {
    try {
      const tx = await wallet.sendTransaction({
        to: address,
        value: ethers.parseEther('0.5')
      });
      
      console.log(`Sent 0.5 ETH to ${address}`);
      console.log(`Transaction hash: ${tx.hash}`);
      
      await tx.wait();
      console.log('Transaction confirmed');
    } catch (error) {
      console.error(`Error sending ETH to ${address}: ${error.message}`);
    }
  }
}

sendEthToAddresses().catch(console.error);