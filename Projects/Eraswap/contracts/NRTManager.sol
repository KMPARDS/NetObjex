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

    address public eraswapToken;  // address of EraswapToken

    EraswapToken tokenContract;  // Defining conract address so as to interact with EraswapToken

    uint256 Timecheck; // variable to store date
    uint256 releaseNrtTime; // variable to check release date

    // Variables to keep track of tokens released
    uint256 MonthlyReleaseNrt;
    uint256 AnnualReleaseNrt;
    uint256 monthCount;

        // constructor

    constructor (address token) public{
        eraswapToken = token;
        tokenContract = EraswapToken(eraswapToken);
        Timecheck = now;
        releaseNrtTime = now + 30 days;
        AnnualReleaseNrt = 81900000000000000;
        MonthlyReleaseNrt = AnnualReleaseNrt.div(uint256(12));
        monthCount = 0;
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


    // Amount received to the NRT pool , keeps track of the amount which is to be distributed to the NRT pool

    uint NRTBal;


    /**
    * @dev Function to initialise  luckpool address
    * @param pool_addr Address to be set 
    */

    function setLuckPool(address pool_addr) external onlyOwner(){
        require(pool_addr != 0,"Token address must be defined");
        require(pool_addr == 0x0,"The token address must not have been initialized");
        luckPool = pool_addr;
    }

    /**
    * @dev Function to initialise NewTalentsAndPartnerships pool address
    * @param pool_addr Address to be set 
    */

    function setNewTalentsAndPartnerships(address pool_addr) external onlyOwner(){
        require(pool_addr != 0,"Token address must be defined");
        require(pool_addr == 0x0,"The token address must not have been initialized");
        newTalentsAndPartnerships = pool_addr;
    }

    /**
    * @dev Function to initialise PlatformMaintenance pool address
    * @param pool_addr Address to be set 
    */

    function setPlatformMaintenance(address pool_addr) external onlyOwner(){
        require(pool_addr != 0,"Token address must be defined");
        require(pool_addr == 0x0,"The token address must not have been initialized");
        platformMaintenance = pool_addr;
    }

    /**
    * @dev Function to initialise MarketingAndRNR pool address
    * @param pool_addr Address to be set 
    */

    function setMarketingAndRNR(address pool_addr) external onlyOwner(){
        require(pool_addr != 0,"Token address must be defined");
        require(pool_addr == 0x0,"The token address must not have been initialized");
        marketingAndRNR = pool_addr;
    }

    /**
    * @dev Function to initialise MarketingAndRNR pool address
    * @param pool_addr Address to be set 
    */

    function setKmPards(address pool_addr) external onlyOwner(){
        require(pool_addr != 0,"Token address must be defined");
        require(pool_addr == 0x0,"The token address must not have been initialized");
        kmPards = pool_addr;
    }

    /**
    * @dev Function to initialise ContingencyFunds pool address
    * @param pool_addr Address to be set 
    */

    function setContingencyFunds(address pool_addr) external onlyOwner(){
        require(pool_addr != 0,"Token address must be defined");
        require(pool_addr == 0x0,"The token address must not have been initialized");
        contingencyFunds = pool_addr;
    }

    /**
    * @dev Function to initialise ResearchAndDevelopment pool address
    * @param pool_addr Address to be set 
    */

    function setResearchAndDevelopment(address pool_addr) external onlyOwner(){
        require(pool_addr != 0,"Token address must be defined");
        require(pool_addr == 0x0,"The token address must not have been initialized");
        researchAndDevelopment = pool_addr;
    }

    /**
    * @dev Function to initialise BuzzCafe pool address
    * @param pool_addr Address to be set 
    */

    function setBuzzCafe(address pool_addr) external onlyOwner(){
        require(pool_addr != 0,"Token address must be defined");
        require(pool_addr == 0x0,"The token address must not have been initialized");
        buzzCafe = pool_addr;
    }

    /**
    * @dev Function to initialise PowerToken pool address
    * @param pool_addr Address to be set 
    */

    function setPowerToken(address pool_addr) external onlyOwner(){
        require(pool_addr != 0,"Token address must be defined");
        require(pool_addr == 0x0,"The token address must not have been initialized");
        powerToken = pool_addr;
    }

    /**
    * @dev Function to trigger the release of montly NRT to diffreent actors in the system
    * 
    */

    function receiveMonthlyNRT() external onlyOwner(){
        require(NRTBal>=0, "NRTBal should be valid");
        require(tokenContract.balanceOf(this)>0,"NRT_Manger should have token balance");
        require(now >= releaseNrtTime,"NRT can be distributed only after 30 days");
        NRTBal = NRTBal.add(MonthlyReleaseNrt);
        distribute_NRT();
        if(monthCount == 12){
            monthCount = 0;
            AnnualReleaseNrt = (AnnualReleaseNrt.mul(9)).div(10);
            MonthlyReleaseNrt = AnnualReleaseNrt.div(12);
        }
        else{
            monthCount = monthCount.add(1);
        }        
    }


    // function which is called internally to distribute tokens
    function distribute_NRT() private onlyOwner(){
        require(NRTBal != 0,"There are no NRT to distribute");
        
        // Distibuting the newly released tokens to eachof the pools
        
        newTalentsAndPartnershipsBal = (newTalentsAndPartnershipsBal.add(NRTBal.mul(5))).div(100);
        platformMaintenanceBal = (platformMaintenanceBal.add(NRTBal.mul(10))).div(100);
        marketingAndRNRBal = (marketingAndRNRBal.add(NRTBal.mul(10))).div(100);
        kmPardsBal = (kmPardsBal.add(NRTBal.mul(10))).div(100);
        contingencyFundsBal = (contingencyFundsBal.add(NRTBal.mul(10))).div(100);
        researchAndDevelopmentBal = (researchAndDevelopmentBal.add(NRTBal.mul(5))).div(100);
        curatorsBal = (curatorsBal.add(NRTBal.mul(5))).div(100);
        timeTradersBal = (timeTradersBal.add(NRTBal.mul(5))).div(100);
        daySwappersBal = (daySwappersBal.add(NRTBal.mul(125))).div(1000);
        buzzCafeBal = (buzzCafeBal.add(NRTBal.mul(25))).div(1000); 
        powerTokenBal = (powerTokenBal.add(NRTBal.mul(10))).div(100);
        stakersBal = (stakersBal.add(NRTBal.mul(15))).div(100);
        
        // Reseting NRT
        NRTBal = 0;

    }
}
