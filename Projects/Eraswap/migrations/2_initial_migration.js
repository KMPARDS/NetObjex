const EraswapToken = artifacts.require('./EraswapToken.sol');

const name = 'EraswapToken';
const symbol = 'EST';
const decimals = web3.toBigNumber(5);

module.exports = function (deployer) {
  deployer.deploy(EraswapToken, name, symbol, decimals);
};
