const EraswapToken = artifacts.require('./EraswapToken.sol');
const NRT_Manager = artifacts.require('./NRTManager.sol');
const name = 'EraswapToken';
const symbol = 'EST';
const decimals = web3.toBigNumber(8);
const totalsupply = web3.toBigNumber(910000000000000000);
const poolAddr = ['0x5526B758117863bcf1cF558cE864CB99bdAC781c','0xfFbB9F2b2fBE60374f41D65783687B5E347C5b34','0xfF0991dD365A0959330659430D7fF653558e5B6F',
'0x43D12FC54830b2704039bFE43f50A42dbcF8b8E8','0x7041F7c401A9bAB295C6633697f2Af3DDEA5dA6b','0x420e2Fb0f8Bc333a7D1C6a3E705984367386Fe0d',
'0x8f28E76120e96CE72767b4eEBe7D9C445D37631A','0xDC8553bb6dea3a2856de1D1008BB367e3ECC8538'];

module.exports = function (deployer) {
  deployer.deploy(EraswapToken, name, symbol, decimals,totalsupply).then((A)=>{
    deployer.deploy(NRT_Manager , A.address,poolAddr);
  });

};
