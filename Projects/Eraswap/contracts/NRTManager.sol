pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "openzeppelin-solidity/contracts/access/roles/SignerRole.sol";
import "./Staking.sol";


/**
* @title  NRT Distribution Contract
* @dev This contract will be responsible for distributing the newly released tokens to the different pools.
*/




// The contract addresses of different pools
contract NRTManager is Ownable, SignerRole{
    using SafeMath for uint256;

    address public eraswapToken;  // address of EraswapToken

    EraswapToken tokenContract;  // Defining conract address so as to interact with EraswapToken

    uint256 releaseNrtTime; // variable to check release date

    // Variables to keep track of tokens released
    uint256 MonthlyReleaseNrt;
    uint256 AnnualReleaseNrt;
    uint256 monthCount;

    // Event to watch token redemption
    event sendToken(
    string pool,
    address indexed sendedAddress,
    uint256 value
    );

    // Event To watch pool address change
    event ChangingPoolAddress(
    string pool,
    address indexed newAddress
    );

    // Event to watch NRT distribution
    event NRTDistributed(
        uint256 NRTReleased
    );


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


     // ================Staking -- TimeAlly=================

     // Counts of different stakers
    uint256 public OneYearStakerCount;
    uint256 public TwoYearStakerCount;
    uint256 public TotalStakerCount;

    uint256 public OneYearStakersBal;
    uint256 public TwoYearStakersBal;

    struct OneYearStaker {
        uint256 stakedAmount;
        uint256 stakedtime;
    }

    struct TwoYearStaker {
        uint256 stakedAmount;
        uint256 stakedtime;
    }

    mapping (address => OneYearStaker) OneYearContract;
    mapping (address => TwoYearStaker) TwoYearContract;
    address[] OneYearContractList;
    address[] TwoYearContractList;


   /**
   * @dev Throws if not a valid address
   */
    modifier isValidAddress(address addr) {
        require(addr != address(0),"It should be a valid address");
        _;
    }

   /**
   * @dev Throws if the value is zero
   */
    modifier isNotZero(uint256 value) {
        require(value != 0,"It should be non zero");
        _;
    }


    /**
    * @dev Function to initialise NewTalentsAndPartnerships pool address
    * @param pool_addr Address to be set 
    */

    function setNewTalentsAndPartnerships(address pool_addr) public onlyOwner() isValidAddress(pool_addr){
        newTalentsAndPartnerships = pool_addr;
        emit ChangingPoolAddress ("NewTalentsAndPartnerships",newTalentsAndPartnerships);
    }

     /**
    * @dev Function to send NewTalentsAndPartnerships balance
    */
    function sendNewTalentsAndPartnerships() internal isValidAddress(newTalentsAndPartnerships) isNotZero(newTalentsAndPartnershipsBal) 
    returns(bool) {
        uint256 temp = newTalentsAndPartnershipsBal;
        emit sendToken("NewTalentsAndPartnerships",newTalentsAndPartnerships,newTalentsAndPartnershipsBal);
        newTalentsAndPartnershipsBal = 0;
        require(tokenContract.transfer(newTalentsAndPartnerships, temp),"The transfer must not fail");
        return true;
    }

    /**
    * @dev Function to initialise PlatformMaintenance pool address
    * @param pool_addr Address to be set 
    */

    function setPlatformMaintenance(address pool_addr) public onlyOwner() isValidAddress(pool_addr){
        platformMaintenance = pool_addr;
        emit ChangingPoolAddress("PlatformMaintenance",platformMaintenance);
    }
    

     /**
    * @dev Function to send platformMaintenance balance
    */
    function sendPlatformMaintenance() internal isValidAddress(platformMaintenance) isNotZero(platformMaintenanceBal)
    returns(bool){
        uint256 temp = platformMaintenanceBal;
        emit sendToken("PlatformMaintenance",platformMaintenance,platformMaintenanceBal);
        platformMaintenanceBal = 0;
        require(tokenContract.transfer(platformMaintenance, temp),"The transfer must not fail");
        return true;    
    }

    /**
    * @dev Function to initialise MarketingAndRNR pool address
    * @param pool_addr Address to be set 
    */

    function setMarketingAndRNR(address pool_addr) public onlyOwner() isValidAddress(pool_addr){
        marketingAndRNR = pool_addr;
        emit ChangingPoolAddress("MarketingAndRNR",marketingAndRNR);
    }

    /**
    * @dev Function to send marketingAndRNR balance
    */
    function sendMarketingAndRNR() internal isValidAddress(marketingAndRNR) isNotZero(marketingAndRNRBal)
    returns(bool){
        uint256 temp = marketingAndRNRBal;
        emit sendToken("MarketingAndRNR",marketingAndRNR,marketingAndRNRBal);
        marketingAndRNRBal = 0;
        require(tokenContract.transfer(marketingAndRNR, temp),"The transfer must not fail");
        return true;
    }

    /**
    * @dev Function to initialise setKmPards pool address
    * @param pool_addr Address to be set 
    */

    function setKmPards(address pool_addr) public onlyOwner() isValidAddress(pool_addr){
        kmPards = pool_addr;
        emit ChangingPoolAddress("kmPards",kmPards);
    }

    /**
    * @dev Function to send KmPards balance
    */
    function sendKmPards() internal isValidAddress(kmPards) isNotZero(kmPardsBal)
    returns(bool){
        uint256 temp = kmPardsBal;
        emit sendToken("MarketingAndRNR",kmPards,kmPardsBal);
        kmPardsBal = 0;
        require(tokenContract.transfer(kmPards, temp),"The transfer must not fail");
        return true;
    }

    /**
    * @dev Function to initialise ContingencyFunds pool address
    * @param pool_addr Address to be set 
    */

    function setContingencyFunds(address pool_addr) public onlyOwner() isValidAddress(pool_addr){
        contingencyFunds = pool_addr;
        emit ChangingPoolAddress("ContingencyFunds",contingencyFunds);
    }

    /**
    * @dev Function to send contingencyFunds balance
    */
    function sendContingencyFunds() internal  isValidAddress(contingencyFunds) isNotZero(contingencyFundsBal)
    returns(bool){
        uint256 temp = contingencyFundsBal;
        emit sendToken("contingencyFunds",contingencyFunds,contingencyFundsBal);
        contingencyFundsBal = 0;
        require(tokenContract.transfer(contingencyFunds, temp),"The transfer must not fail");
        return true;
    }
    /**
    * @dev Function to initialise ResearchAndDevelopment pool address
    * @param pool_addr Address to be set 
    */

    function setResearchAndDevelopment(address pool_addr) public onlyOwner() isValidAddress(pool_addr){
        researchAndDevelopment = pool_addr;
        emit ChangingPoolAddress("ResearchAndDevelopment",researchAndDevelopment);
    }

    /**
    * @dev Function to send researchAndDevelopment balance
    */
    function sendResearchAndDevelopment() internal isValidAddress(researchAndDevelopment) isNotZero(researchAndDevelopmentBal)
    returns(bool){
        uint256 temp = researchAndDevelopmentBal;
        emit sendToken("ResearchAndDevelopment",researchAndDevelopment,researchAndDevelopmentBal);
        researchAndDevelopmentBal = 0;
        require(tokenContract.transfer(researchAndDevelopment, temp),"The transfer must not fail");
        return true;
    }

    /**
    * @dev Function to initialise BuzzCafe pool address
    * @param pool_addr Address to be set 
    */

    function setBuzzCafe(address pool_addr) public onlyOwner() isValidAddress(pool_addr){
        buzzCafe = pool_addr;
        emit ChangingPoolAddress("BuzzCafe",buzzCafe);
    }

    /**
    * @dev Function to send buzzCafe balance
    */
    function sendBuzzCafe() internal isValidAddress(buzzCafe) isNotZero(buzzCafeBal)
    returns(bool){
        uint256 temp = buzzCafeBal;
        emit sendToken("BuzzCafe",buzzCafe,buzzCafeBal);
        buzzCafeBal = 0;
        require(tokenContract.transfer(buzzCafe, temp),"The transfer must not fail");
        return true;
    }

    /**
    * @dev Function to initialise PowerToken pool address
    * @param pool_addr Address to be set 
    */

    function setPowerToken(address pool_addr) public onlyOwner() isValidAddress(pool_addr){
        powerToken = pool_addr;
        emit ChangingPoolAddress("PowerToken",powerToken);
    }

    /**
    * @dev Function to send powerToken balance
    */
    function sendPowerToken() internal  isValidAddress(powerToken) isNotZero(powerTokenBal)
    returns(bool){
        uint256 temp = powerTokenBal;
        emit sendToken("PowerToken",powerToken,powerTokenBal);
        powerTokenBal = 0;
        require(tokenContract.transfer(powerToken, temp),"The transfer must not fail");
        return true;
    }

    /**
    * @dev Function to trigger the release of montly NRT to different actors in the system
    * 
    */
    function updateLuckpool(uint256 newValue) external onlySigner(){
        luckPoolBal = luckPoolBal.add(newValue);
    }

    function receiveMonthlyNRT() external onlySigner() {
        require(tokenContract.balanceOf(address(this))>0,"NRT_Manger should have token balance");
        require(now >= releaseNrtTime,"NRT can be distributed only after 30 days");
        NRTBal = NRTBal.add(MonthlyReleaseNrt);
        distribute_NRT();
        if(monthCount == 11){
            monthCount = 0;
            AnnualReleaseNrt = (AnnualReleaseNrt.mul(9)).div(10);
            MonthlyReleaseNrt = AnnualReleaseNrt.div(12);
        }
        else{
            monthCount = monthCount.add(1);
        }        
    }


    // function which is called internally to distribute tokens
    function distribute_NRT() internal isNotZero(NRTBal){
        require(tokenContract.balanceOf(address(this))>=NRTBal,"NRT_Manger doesn't have token balance");
        NRTBal = NRTBal.add(luckPoolBal);
        
        // Distibuting the newly released tokens to each of the pools
        
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

        // Updating one and 2 year balances

        if(OneYearStakerCount>0)
        {
        TotalStakerCount = OneYearStakerCount.add(TwoYearStakerCount);
        OneYearStakersBal = (stakersBal.mul(OneYearStakerCount)).div(TotalStakerCount);
        TwoYearStakersBal = (stakersBal.mul(TwoYearStakerCount)).div(TotalStakerCount);
        luckPoolBal = (OneYearStakersBal.mul(2)).div(15);
        OneYearStakersBal = OneYearStakersBal.sub(luckPoolBal);
        }
        else{
            TwoYearStakersBal = stakersBal;
        }

        

        // Reseting NRT

        emit NRTDistributed(NRTBal);
        NRTBal = 0;
        luckPoolBal = 0;
        releaseNrtTime = releaseNrtTime.add(30 days + 6 hours); // resetting release date again


        // sending tokens to respective wallets
        require(sendNewTalentsAndPartnerships(),"Tokens should be succesfully send");
        require(sendPlatformMaintenance(),"Tokens should be succesfully send");
        require(sendMarketingAndRNR(),"Tokens should be succesfully send");
        require(sendKmPards(),"Tokens should be succesfully send");
        require(sendContingencyFunds(),"Tokens should be succesfully send");
        require(sendResearchAndDevelopment(),"Tokens should be succesfully send");
        require(sendBuzzCafe(),"Tokens should be succesfully send");
        require(sendPowerToken(),"Tokens should be succesfully send");

    }


    // Staking Contract Functions

    function createStakingContract(uint256 Amount,bool isTwoYear) external returns (address){
        Staking newStakingContract = new Staking(Amount,isTwoYear, msg.sender, eraswapToken);
        if(isTwoYear){
                    TwoYearStaker memory temp1 = TwoYearStaker(Amount,now);
                    TwoYearContractList.push(address(newStakingContract));
                    TwoYearContract[address(newStakingContract)] = temp1; 
        }
        else{
                    OneYearStaker memory temp2 = OneYearStaker(Amount,now);
                    OneYearContractList.push(address(newStakingContract));
                    OneYearContract[address(newStakingContract)] = temp2;
        }
        require(tokenContract.transfer(address(newStakingContract),Amount),"Token Contract should be created");
        return address(newStakingContract);
    }
    // function releaseOneYearStakingNRTBalance()internal returns (bool){

        
    // }

    // function releaseTwoYearStakingNRTBalance()internal returns (bool){

        
    // }
    /**
    * @dev Constructor
    * @param token Address of eraswaptoken
    * @param pool Array of different pools
    * NewTalentsAndPartnerships(pool[0]);
    * PlatformMaintenance(pool[1]);
    * MarketingAndRNR(pool[2]);
    * KmPards(pool[3]);
    * ContingencyFunds(pool[4]);
    * ResearchAndDevelopment(pool[5]);
    * BuzzCafe(pool[6]);
    * PowerToken(pool[7]);
    */

    constructor (address token, address[] memory pool) public{
        require(token != address(0),"Token address must be defined");
        // Setting up different pools
        setNewTalentsAndPartnerships(pool[0]);
        setPlatformMaintenance(pool[1]);
        setMarketingAndRNR(pool[2]);
        setKmPards(pool[3]);
        setContingencyFunds(pool[4]);
        setResearchAndDevelopment(pool[5]);
        setBuzzCafe(pool[6]);
        setPowerToken(pool[7]);
        eraswapToken = token;
        tokenContract = EraswapToken(eraswapToken);
        releaseNrtTime = now.add(30 days + 6 hours);
        AnnualReleaseNrt = 81900000000000000;
        MonthlyReleaseNrt = AnnualReleaseNrt.div(uint256(12));
        monthCount = 0;
    }

}