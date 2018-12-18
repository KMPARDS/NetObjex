const shouldFail = require('../helpers/shouldFail');
const { ether } = require('../helpers/ether');
const { shouldBehaveLikeERC20Mintable } = require('./behaviors/ERC20Mintable.behavior');
const { shouldBehaveLikeERC20Capped } = require('./behaviors/ERC20Capped.behavior');

const EraswapToken = artifacts.require('EraswapToken');

contract('EraswapToken', function ([_, minter, ...otherAccounts]) {
  const _name = 'My Capped ERC20';
  const _symbol = 'MDT';
  const _decimals = 18;
  const cap = ether(1000);

  it('requires a non-zero cap', async function () {
    await shouldFail.reverting(
      EraswapToken.new(_name, _symbol, _decimals, 0, { from: minter })
    );
  });

  context('once deployed', async function () {
    beforeEach(async function () {
      this.token = await EraswapToken.new(_name, _symbol, _decimals, cap, { from: minter });
    });

    shouldBehaveLikeERC20Capped(minter, otherAccounts, cap);
    shouldBehaveLikeERC20Mintable(minter, otherAccounts);
  });
});
