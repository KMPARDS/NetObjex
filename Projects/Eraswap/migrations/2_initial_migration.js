const EraswapToken = artifacts.require('./EraswapToken.sol');


module.exports = function(deployer) {
  deployer.deploy(EraswapToken);
};