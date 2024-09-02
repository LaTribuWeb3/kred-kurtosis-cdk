const ethers = require('ethers');
const yaml = require('js-yaml');
const fs = require('fs');

async function gatherAllEth() {
  // Load the params.yml file
  const paramsFile = fs.readFileSync('params.yml', 'utf8');
  const params = yaml.load(paramsFile);

  // Connect to Sepolia
  const provider = new ethers.providers.JsonRpcProvider('https://ethereum-sepolia-rpc.publicnode.com');

  // Destination wallet
  const destinationWallet = '0x7f25c2d888A1b62dBA7dE511449734F3a9379388';

  // Find all zkevm_l2_*_private_key entries
  const privateKeys = Object.entries(params.args)
    .filter(([key]) => key.startsWith('zkevm_l2_') && key.endsWith('_private_key'))
    .map(([_, value]) => value);

  for (const privateKey of privateKeys) {
    const wallet = new ethers.Wallet(privateKey, provider);
    
    try {
      const balance = await provider.getBalance(wallet.address);
      
      if (balance.gt(0)) {
        const gasPrice = await provider.getGasPrice();
        const gasLimit = 21000; // Standard gas limit for ETH transfer
        const gasCost = gasPrice.mul(gasLimit);
        
        if (balance.gt(gasCost)) {
          const amountToSend = balance.sub(gasCost);
          
          const tx = await wallet.sendTransaction({
            to: destinationWallet,
            value: amountToSend,
            gasLimit: gasLimit,
            gasPrice: gasPrice
          });
          
          console.log(`Sent ${ethers.utils.formatEther(amountToSend)} ETH from ${wallet.address} to ${destinationWallet}`);
          console.log(`Transaction hash: ${tx.hash}`);
          
          await tx.wait();
          console.log('Transaction confirmed');
        } else {
          console.log(`Insufficient balance to cover gas costs for ${wallet.address}`);
        }
      } else {
        console.log(`No balance to transfer from ${wallet.address}`);
      }
    } catch (error) {
      console.error(`Error processing wallet ${wallet.address}: ${error.message}`);
    }
  }
}

gatherAllEth().catch(console.error);