pragma solidity ^0.4.24;

import "./EraswapToken.sol";


contract Staking{

    // Counts of different stakers
    uint256 public OneYearStakerCount;
    uint256 public TwoYearStakerCount;

    // Eraswap Token contract address

    address eraswapToken;
   
   
   /**
   * @dev Throws if not a valid address
   */
    modifier isValidAddress(address addr) {
        require(addr != 0,"It should be a valid address");
        _;
    }



   /**
   * @dev Throws if the value is zero
   */
    modifier isNotZero(uint256 value) {
        require(value != 0,"It should be non zero");
        _;
    }


    constructor(address token) public{
        eraswapToken = token;
    }
}