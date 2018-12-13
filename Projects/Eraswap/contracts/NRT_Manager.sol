pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

/**
* @title  NRT Distribution Contract
* @dev This contract will be responsible for distributing the newly released tokens to the different pools.
*/

// The contract addresses of different pools
contract NRT_Manager is Ownable{
    using SafeMath for uint256;

    // Different address to distribute to different pools
    address public Luck_pool;
    address public New_Talents_and_Partnerships;
    address public Platform_maintenance;
    address public Marketing_and_RNR;
    address public Kmpards;
    address public Contingency_Funds;
    address public TimeAlly;
    address public ReaserchAndDevelopment_bal;

    // balances present in different pools

    uint256 public Luck_pool_bal;
    uint256 public New_Talents_and_Partnerships_bal;
    uint256 public Platform_maintenance_bal;
    uint256 public Marketing_and_RNR_bal;
    uint256 public Kmpards_bal;
    uint256 public Contingency_Funds_bal;
    uint256 public TimeAlly_bal;
    uint256 public ReaserchAndDevelopment_bal;

    // Amount received to the NRT pool

    uint NRT_bal;

    // Functions to set the different pool addresses

    function set_Luck_pool(pool_addr) external onlyOwner(){
        Luck_pool = pool_addr;
    }

    function set_New_Talents_and_Partnerships(pool_addr) external onlyOwner(){
        New_Talents_and_Partnerships = pool_addr;
    }

    function set_Platform_maintenance(pool_addr) external onlyOwner(){
        Platform_maintenance = pool_addr;
    }

    function set_Marketing_and_RNR(pool_addr) external onlyOwner(){
        Marketing_and_RNR = pool_addr;
    }

    function set_Kmpards(pool_addr) external onlyOwner(){
        Kmpards = pool_addr;
    }

    function set_Contingency_Funds(pool_addr) external onlyOwner(){
        Contingency_Funds = pool_addr;
    }

    function set_TimeAlly(pool_addr) external onlyOwner(){
        TimeAlly = pool_addr;
    }

    function set_ReaserchAndDevelopment(pool_addr) external onlyOwner(){
        ReaserchAndDevelopment = pool_addr;
    }


    // function which is called internally to distribute tokens
    function distribute_NRT() internal returns(bool){
        require(NRT_bal != 0,"There are no NRT to distribute");
        // Distibuting the newly released tokens to eachof the pools
        New_Talents_and_Partnerships_bal.add(NRT_bal.mul(0.05));
        Platform_maintenance_bal.add(NRT_bal.mul(0.10));
        Marketing_and_RNR_bal.add(NRT_bal.mul(0.10));
        Kmpards_bal.add(NRT_bal.mul(0.10));
        Contingency_Funds_bal.add(NRT_bal.mul(0.10));
        ReaserchAndDevelopment_bal.add(NRT_bal.mul(0.05));
        TimeAlly_bal.add(NRT_bal.mul(0.5));
    }




}
