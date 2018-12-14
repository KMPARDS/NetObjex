const EraswapToken = artifacts.require('./EraswapToken.sol');
const NRT_Manager = artifacts.require('./NRT_Manager.sol');
const name = 'EraswapToken';
const symbol = 'EST';
const decimals = web3.toBigNumber(8);

module.exports = function (deployer) {
  deployer.deploy(EraswapToken, name, symbol, decimals);
  deployer.deploy(NRT_Manager);
};
