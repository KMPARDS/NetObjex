pragma solidity ^0.4.24;

import "./IERC20.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "openzeppelin-solidity/contracts/access/roles/SignerRole.sol";


/**
* @title  NRT Distribution Contract
* @dev This contract will be responsible for distributing the newly released tokens to the different pools.
*/




// The contract addresses of different pools
contract NRTManager is Ownable, SignerRole{
    using SafeMath for uint256;

    IERC20 tokenContract;  // Defining conract address so as to interact with EraswapToken

    // Variables to keep track of tokens released
    uint256 releaseNrtTime; // variable to check release date
    uint256 MonthlyReleaseNrt;
    uint256 AnnualReleaseNrt;
    uint256 monthCount;

    // Event to watch token redemption
    event sendToken(
    string pool,
    address indexed sendAddress,
    uint256 value
    );

    // Event to watch token redemption
    event receiveToken(
    string pool,
    address indexed sendAddress,
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


    // different pool address
    address public newTalentsAndPartnerships;
    address public platformMaintenance;
    address public marketingAndRNR;
    address public kmPards;
    address public contingencyFunds;
    address public researchAndDevelopment;
    address public buzzCafe;
    address public timeSwappers; // which include powerToken , curators ,timeTraders , daySwappers


    // balances present in different pools


    uint256 public timeSwappersBal;
    uint256 public buzzCafeBal;
    uint256 public stakersBal; 
    uint256 public luckPoolBal;    // Luckpool Balance

    // Total staking balances after NRT release
    uint256 public OneYearStakersBal;
    uint256 public TwoYearStakersBal;
    
    uint256 public burnTokenBal;// tokens to be burned

    address public eraswapToken;  // address of EraswapToken
    address public stakingContract; //address of Staking Contract

    uint256 public TotalCirculation = 910000000000000000000000000; // 910 million which was intially distributed in ICO

   /**
   * @dev Throws if not a valid address
   * @param addr address
   */
    modifier isValidAddress(address addr) {
        require(addr != address(0),"It should be a valid address");
        _;
    }

   /**
   * @dev Throws if the value is zero
   * @param value alue to be checked
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
        emit ChangingPoolAddress("NewTalentsAndPartnerships",newTalentsAndPartnerships);
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
    * @dev Function to initialise MarketingAndRNR pool address
    * @param pool_addr Address to be set 
    */

    function setMarketingAndRNR(address pool_addr) public onlyOwner() isValidAddress(pool_addr){
        marketingAndRNR = pool_addr;
        emit ChangingPoolAddress("MarketingAndRNR",marketingAndRNR);
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
    * @dev Function to initialise ContingencyFunds pool address
    * @param pool_addr Address to be set 
    */

    function setContingencyFunds(address pool_addr) public onlyOwner() isValidAddress(pool_addr){
        contingencyFunds = pool_addr;
        emit ChangingPoolAddress("ContingencyFunds",contingencyFunds);
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
    * @dev Function to initialise BuzzCafe pool address
    * @param pool_addr Address to be set 
    */

    function setBuzzCafe(address pool_addr) public onlyOwner() isValidAddress(pool_addr){
        buzzCafe = pool_addr;
        emit ChangingPoolAddress("BuzzCafe",buzzCafe);
    }

    /**
    * @dev Function to initialise PowerToken pool address
    * @param pool_addr Address to be set 
    */

    function setTimeSwapper(address pool_addr) public onlyOwner() isValidAddress(pool_addr){
        timeSwappers = pool_addr;
        emit ChangingPoolAddress("TimeSwapper",timeSwappers);
    }


    /**
    * @dev Function to update staking contract address
    * @param token Address to be set 
    */
    function setStakingContract(address token) external onlyOwner() isValidAddress(token){
        stakingContract = token;
        emit ChangingPoolAddress("stakingContract",stakingContract);
    }

    /**
   * @dev should send tokens to the user
   * @param text text to be emited
   * @param amount amount to be send
   * @param addr address of pool to be send
   * @return true if success
   */

  function sendTokens(string text,  address addr ,uint256 amount) internal returns (bool) {
        emit sendToken(text,addr,amount);
        require(tokenContract.transfer(addr, amount),"The transfer must not fail");
        return true;
  }

     /**
   * @dev should send tokens to the user
   * @param text text to be emited
   * @param amount amount to be send
   * @param addr address of pool to be send
   * @return true if success
   */

  function receiveTokens(string text,  address fromAddr ,uint256 amount) internal returns (bool) {
        emit sendToken(text,addr,amount);
        require(tokenContract.transferFrom(fromAddr,address(this), amount), "The token transfer should be done");
        return true;
  }

     /**
   * @dev to reset Staking amount
   * @return true if success
   */
    function resetStaking() external returns(bool) {
        require(msg.sender == stakingContract , "shouldd reset staking " );
        stakersBal = 0;
        return true;
    }

       /**
   * @dev to reset timeSwappers amount
   * @return true if success
   */
    function resetTimeSwappers() external returns(bool) {
        require(msg.sender == timeSwappers , "should reset TimeSwappers " );
        timeSwappersBal = 0;
        return true;
    }

    /**
    * @dev Function to update luckpoo; balance
    * @param amount amount to be updated
    */
    function updateLuckpool(uint256 amount) external onlySigner() returns(bool){
        require(receiveTokens("updating Luckpool",msg.sender, amount), "The token transfer should be done");
        luckPoolBal = luckPoolBal.add(amount);
        return true;
    }

    /**
    * @dev Function to trigger to update  for burning of tokens
    * @param amount amount to be updated
    */
    function updateBurnBal(uint256 amount) external onlySigner() returns(bool){
        require(receiveTokens("updating burn Balance",msg.sender, amount), "The token transfer should be done");
        burnTokenBal = burnTokenBal.add(amount);
        return true;
    }


      /**
   * @dev Should burn tokens according to the total circulation
   * @return true if success
   */

function burnTokens() internal returns (bool){

      if(burnTokenBal == 0){
          return true;
      }
      else{
      uint temp = (TotalCirculation.mul(2)).div(100);   // max amount permitted to burn in a month
      if(temp >= burnTokenBal ){
          tokenContract.burn(burnTokenBal);
          burnTokenBal = 0;
      }
      else{
          burnTokenBal = burnTokenBal.sub(temp);
          tokenContract.burn(temp);
      }
      return true;
      }
}

        /**
   * @dev To invoke monthly release
   * @return true if success
   */

    function receiveMonthlyNRT() external onlySigner() returns (bool) {
        require(now >= releaseNrtTime,"NRT can be distributed only after 30 days");
        uint NRTBal = NRTBal.add(MonthlyReleaseNrt);
        TotalCirculation = TotalCirculation.add(NRTBal);
        require((tokenContract.balanceOf(address(this))>NRTBal) && (NRTBal > 0),"NRT_Manger should have token balance");
        require(distribute_NRT(NRTBal));
        if(monthCount == 11){
            monthCount = 0;
            AnnualReleaseNrt = (AnnualReleaseNrt.mul(9)).div(10);
            MonthlyReleaseNrt = AnnualReleaseNrt.div(12);
        }
        else{
            monthCount = monthCount.add(1);
        }     
        return true;   
    }

    /**
   * @dev To invoke monthly release
   * @param NRTBal Nrt balance to distribute
   * @return true if success
   */
    function distribute_NRT(uint256 NRTBal) internal isNotZero(NRTBal) returns (bool){
        require(tokenContract.balanceOf(address(this))>=NRTBal,"NRT_Manger doesn't have token balance");
        NRTBal = NRTBal.add(luckPoolBal);
        
        uint256  newTalentsAndPartnershipsBal;
        uint256  platformMaintenanceBal;
        uint256  marketingAndRNRBal;
        uint256  kmPardsBal;
        uint256  contingencyFundsBal;
        uint256  researchAndDevelopmentBal;
       
        // Distibuting the newly released tokens to each of the pools
        
        newTalentsAndPartnershipsBal = newTalentsAndPartnershipsBal.add((NRTBal.mul(5)).div(100));
        platformMaintenanceBal = platformMaintenanceBal.add((NRTBal.mul(10)).div(100));
        marketingAndRNRBal = marketingAndRNRBal.add((NRTBal.mul(10)).div(100));
        kmPardsBal = kmPardsBal.add((NRTBal.mul(10)).div(100));
        contingencyFundsBal = contingencyFundsBal.add((NRTBal.mul(10)).div(100));
        researchAndDevelopmentBal = researchAndDevelopmentBal.add((NRTBal.mul(5)).div(100));
        buzzCafeBal = buzzCafeBal.add((NRTBal.mul(25)).div(1000)); 
        stakersBal = stakersBal.add((NRTBal.mul(15)).div(100));
        timeSwappersBal = timeSwappersBal.add((NRTBal.mul(325)).div(1000));

        

        // Reseting NRT

        emit NRTDistributed(NRTBal);
        NRTBal = 0;
        luckPoolBal = 0;
        releaseNrtTime = releaseNrtTime.add(30 days + 6 hours); // resetting release date again


        // sending tokens to respective wallets
        require(sendTokens("NewTalentsAndPartnerships",newTalentsAndPartnerships,newTalentsAndPartnershipsBal),"Tokens should be succesfully send");
        require(sendTokens("PlatformMaintenance",platformMaintenance,platformMaintenanceBal),"Tokens should be succesfully send");
        require(sendTokens("MarketingAndRNR",marketingAndRNR,marketingAndRNRBal),"Tokens should be succesfully send");
        require(sendTokens("kmPards",kmPards,kmPardsBal),"Tokens should be succesfully send");
        require(sendTokens("contingencyFunds",contingencyFunds,contingencyFundsBal),"Tokens should be succesfully send");
        require(sendTokens("ResearchAndDevelopment",researchAndDevelopment,researchAndDevelopmentBal),"Tokens should be succesfully send");
        require(sendTokens("BuzzCafe",buzzCafe,buzzCafeBal),"Tokens should be succesfully send");
        require(sendTokens("staking contract",stakingContract,stakersBal),"Tokens should be succesfully send");
        require(sendTokens("send timeSwappers",timeSwappers,timeSwappersBal),"Tokens should be succesfully send");
        require(burnTokens(),"Should burns 2% of token in circulation");
        return true;

    }


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
    * TimeSwapper(pool[7]);
    */

    constructor (address token, address[] memory pool) public{
        require(token != address(0),"address should be valid");
        eraswapToken = token;
        tokenContract = IERC20(eraswapToken);
         // Setting up different pools
        setNewTalentsAndPartnerships(pool[0]);
        setPlatformMaintenance(pool[1]);
        setMarketingAndRNR(pool[2]);
        setKmPards(pool[3]);
        setContingencyFunds(pool[4]);
        setResearchAndDevelopment(pool[5]);
        setBuzzCafe(pool[6]);
        setTimeSwapper(pool[7]);
        releaseNrtTime = now.add(30 days + 6 hours);
        AnnualReleaseNrt = 81900000000000000;
        MonthlyReleaseNrt = AnnualReleaseNrt.div(uint256(12));
        monthCount = 0;
    }

}