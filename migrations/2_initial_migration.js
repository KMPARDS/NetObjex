const myToken = artifacts.require('./myToken.sol');


module.exports = function (deployer) {
  deployer.deploy(myToken);
};
