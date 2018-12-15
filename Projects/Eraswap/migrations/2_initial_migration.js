const EraswapToken = artifacts.require('./EraswapToken.sol');
const NRT_Manager = artifacts.require('./NRTManager.sol');
const name = 'EraswapToken';
const symbol = 'EST';
const decimals = web3.toBigNumber(8);
const totalsupply = web3.toBigNumber(91000000000000000);

module.exports = function (deployer) {
  deployer.deploy(EraswapToken, name, symbol, decimals,totalsupply).then((A)=>{
    deployer.deploy(NRT_Manager , A.address);
  });
  
};
