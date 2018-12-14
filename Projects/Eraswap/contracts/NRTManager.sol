pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "./EraswapToken.sol";


/**
* @title  NRT Distribution Contract
* @dev This contract will be responsible for distributing the newly released tokens to the different pools.
*/



// The contract addresses of different pools
contract NRTManager is Ownable{
    using SafeMath for uint256;

    // address of EraswapToken

    address public eraswapToken;

        // constructor

    constructor (address token) public{
        eraswapToken = token;
    }

    // Different address to distribute to different pools
    address public luckPool;
    address public newTalentsAndPartnerships;
    address public platformMaintenance;
    address public marketingAndRNR;
    address public kmPards;
    address public contingencyFunds;
    address public researchAndDevelopment;
    address public buzzCafe;
    address public powerToken;

    // balances present in different pools
    uint256 public luckPoolBal;
    uint256 public newTalentsAndPartnershipsBal;
    uint256 public platformMaintenanceBal;
    uint256 public marketingAndRNRBal;
    uint256 public kmPardsBal;
    uint256 public contingencyFundsBal;
    uint256 public researchAndDevelopmentBal;
    uint256 public powerTokenBal;

    // balances timeAlly workpool distribute
    uint256 public curatorsBal;
    uint256 public timeTradersBal;
    uint256 public daySwappersBal;
    uint256 public buzzCafeBal;
    uint256 public stakersBal;


    // Amount received to the NRT pool

    uint NRTBal;



    // Functions to set the different pool addresses

    function setLuckPool(address pool_addr) external onlyOwner(){
        require(pool_addr != 0,"Token address must be defined");
        require(pool_addr == 0x0,"The token address must not have been initialized");
        luckPool = pool_addr;
    }

    function setNewTalentsAndPartnerships(address pool_addr) external onlyOwner(){
        require(pool_addr != 0,"Token address must be defined");
        require(pool_addr == 0x0,"The token address must not have been initialized");
        newTalentsAndPartnerships = pool_addr;
    }

    function setPlatformMaintenance(address pool_addr) external onlyOwner(){
        require(pool_addr != 0,"Token address must be defined");
        require(pool_addr == 0x0,"The token address must not have been initialized");
        platformMaintenance = pool_addr;
    }

    function setMarketingAndRNR(address pool_addr) external onlyOwner(){
        require(pool_addr != 0,"Token address must be defined");
        require(pool_addr == 0x0,"The token address must not have been initialized");
        marketingAndRNR = pool_addr;
    }

    function setKmPards(address pool_addr) external onlyOwner(){
        require(pool_addr != 0,"Token address must be defined");
        require(pool_addr == 0x0,"The token address must not have been initialized");
        kmPards = pool_addr;
    }

    function setContingencyFunds(address pool_addr) external onlyOwner(){
        require(pool_addr != 0,"Token address must be defined");
        require(pool_addr == 0x0,"The token address must not have been initialized");
        contingencyFunds = pool_addr;
    }

    function setResearchAndDevelopment(address pool_addr) external onlyOwner(){
        require(pool_addr != 0,"Token address must be defined");
        require(pool_addr == 0x0,"The token address must not have been initialized");
        researchAndDevelopment = pool_addr;
    }
    function setBuzzCafe(address pool_addr) external onlyOwner(){
        require(pool_addr != 0,"Token address must be defined");
        require(pool_addr == 0x0,"The token address must not have been initialized");
        buzzCafe = pool_addr;
    }
    function setPowerToken(address pool_addr) external onlyOwner(){
        require(pool_addr != 0,"Token address must be defined");
        require(pool_addr == 0x0,"The token address must not have been initialized");
        powerToken = pool_addr;
    }


    // function which is called internally to distribute tokens
    function distribute_NRT() private onlyOwner() returns(bool){
        require(NRTBal != 0,"There are no NRT to distribute");
        // Distibuting the newly released tokens to eachof the pools
        newTalentsAndPartnershipsBal = newTalentsAndPartnershipsBal.add(NRTBal.mul(uint256(0.05)));
        platformMaintenanceBal = platformMaintenanceBal.add(NRTBal.mul(uint256(0.10)));
        marketingAndRNRBal = marketingAndRNRBal.add(NRTBal.mul(uint256(0.10)));
        kmPardsBal = kmPardsBal.add(NRTBal.mul(uint256(0.10)));
        contingencyFundsBal = contingencyFundsBal.add(NRTBal.mul(uint256(0.10)));
        researchAndDevelopmentBal = researchAndDevelopmentBal.add(NRTBal.mul(uint256(0.05)));
        curatorsBal = curatorsBal.add(NRTBal.mul(uint256(0.05)));
        timeTradersBal = timeTradersBal.add(NRTBal.mul(uint256(0.05)));
        daySwappersBal = daySwappersBal.add(NRTBal.mul(uint256(0.125)));
        buzzCafeBal = buzzCafeBal.add(NRTBal.mul(uint256(0.025)));
        powerTokenBal = powerTokenBal.add(NRTBal.mul(uint256(0.10)));
        stakersBal = stakersBal.add(NRTBal.mul(uint256(0.15)));

    }




}
