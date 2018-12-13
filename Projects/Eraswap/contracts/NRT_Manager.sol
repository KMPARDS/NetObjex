pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";

/**
* @title  NRT Distribution Contract
* @dev This contract will be responsible for distributing the newly released tokens to the different pools.
*/

// The contract addresses of different pools
contract NRT_Manager{
    using SafeMath for uint256;

    // Different address to distribute to different pools
    address private Luck_pool;
    address private New_Talents_and_Partnerships;
    address private Platform_maintenance;
    address private Marketing_and_RNR;
    address private Kmpards;
    address private Contingency_Funds;
    address private TimeAlly;
    address private ReaserchAndDevelopment_balance;

    // Balances present in different pools

    uint256 private Luck_pool_balance;
    uint256 private New_Talents_and_Partnerships_balance;
    uint256 private Platform_maintenance_balance;
    uint256 private Marketing_and_RNR_balance;
    uint256 private Kmpards_balance;
    uint256 private Contingency_Funds_balance;
    uint256 private TimeAlly_balance;
    uint256 private ReaserchAndDevelopment_balance;

    // Amount received to the NRT pool

    uint NRT_balance;

    // function which is called internally to distribute tokens
    function distribute_NRT() internal returns(bool){
        require(NRT_balance != 0,"There are no NRT to distribute");
        // Distibuting the newly released tokens to eachof the pools
        New_Talents_and_Partnerships_balance.add(NRT_balance.mul(0.05));
        Platform_maintenance_balance.add(NRT_balance.mul(0.10));
        Marketing_and_RNR_balance.add(NRT_balance.mul(0.10));
        Kmpards_balance.add(NRT_balance.mul(0.10));
        Contingency_Funds_balance.add(NRT_balance.mul(0.10));
        ReaserchAndDevelopment_balance.add(NRT_balance.mul(0.05));
        TimeAlly_balance.add(NRT_balance.mul(0.5));
    }


}
