const { ethers } = require('ethers');

const newWallet = ethers.Wallet.createRandom();

console.log('newWallet.address:', newWallet.address);
console.log('newWallet.mnemonic.phrase:', newWallet.mnemonic.phrase);
console.log('newWallet.privateKey:', newWallet.privateKey);
