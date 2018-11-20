const myCrowdsale = artifacts.require('myCrowdsale');

async function mydeployer(deployer,account) {
  deployer.deploy(myCrowdsale);

}

module.exports = function (deployer, network, accounts) {
  return mydeployer(deployer, accounts);
};
