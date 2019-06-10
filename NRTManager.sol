pragma solidity ^0.5.2;

import "./Eraswap.sol";


contract NRTManager {

    using SafeMath for uint256;

    uint256 public lastNRTRelease;              // variable to store last release date
    uint256 public monthlyNRTAmount;            // variable to store Monthly NRT amount to be released
    uint256 public annualNRTAmount;             // variable to store Annual NRT amount to be released
    uint256 public monthCount;                  // variable to store the count of months from the intial date
    uint256 public luckPoolBal;                 // Luckpool Balance
    uint256 public burnTokenBal;                // tokens to be burned
    Eraswap token;
    address Owner;

    // different pool address
    address public newTalentsAndPartnerships;
    address public platformMaintenance;
    address public marketingAndRNR;
    address public kmPards;
    address public contingencyFunds;
    address public researchAndDevelopment;
    address public buzzCafe;
    address public timeSwappers;                 // which include powerToken , curators ,timeTraders , daySwappers
    address public TimeAlly;                     //address of TimeAlly Contract



    uint256 public newTalentsAndPartnershipsBal; // variable to store last NRT released to the address;
    uint256 public platformMaintenanceBal;       // variable to store last NRT released to the address;
    uint256 public marketingAndRNRBal;           // variable to store last NRT released to the address;
    uint256 public kmPardsBal;                   // variable to store last NRT released to the address;
    uint256 public contingencyFundsBal;          // variable to store last NRT released to the address;
    uint256 public researchAndDevelopmentBal;    // variable to store last NRT released to the address;
    uint256 public buzzCafeNRT;                  // variable to store last NRT released to the address;
    uint256 public TimeAllyNRT;                   // variable to store last NRT released to the address;
    uint256 public timeSwappersNRT;              // variable to store last NRT released to the address;


      // Event to watch NRT distribution
      // @param NRTReleased The amount of NRT released in the month
      event NRTDistributed(uint256 NRTReleased);

      /**
      * Event to watch Transfer of NRT to different Pool
      * @param pool - The pool name
      * @param sendAddress - The address of pool
      * @param value - The value of NRT released
      **/
      event NRTTransfer(string pool, address sendAddress, uint256 value);


      // Event to watch Tokens Burned
      // @param amount The amount burned
      event TokensBurned(uint256 amount);

    /**
      * Event to watch the addition of pool address
      * @param pool - The pool name
      * @param sendAddress - The address of pool
      **/
      event PoolAddressAdded(string pool, address sendAddress);

      // Event to watch LuckPool Updation
      // @param luckPoolBal The current luckPoolBal
      event LuckPoolUpdated(uint256 luckPoolBal);

      // Event to watch BurnTokenBal Updation
      // @param burnTokenBal The current burnTokenBal
      event BurnTokenBalUpdated(uint256 burnTokenBal);




      /**
      * @dev Throws if caller is not TimeAlly
      */
      modifier OnlyAllowed() {
        require(msg.sender == TimeAlly || msg.sender == timeSwappers,"Only TimeAlly and Timeswapper is authorised");
        _;
      }

          /**
      * @dev Throws if caller is not TimeAlly
      */
      modifier OnlyOwner() {
        require(msg.sender == Owner,"Only Owner is authorised");
        _;
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
          uint MaxAmount = ((token.totalSupply()).mul(2)).div(100);   // max amount permitted to burn in a month
          if(MaxAmount >= burnTokenBal ){
            token.burn(burnTokenBal);
            burnTokenBal = 0;
          }
          else{
            burnTokenBal = burnTokenBal.sub(MaxAmount);
            token.burn(MaxAmount);
          }
          return true;
        }
      }


      /**
      * @dev To update pool addresses
      * @param  pool - A List of pool addresses
      * Updates if pool address is not already set and if given address is not zero
      * @return true if success
      */

      function UpdateAddresses (address[9] calldata pool) external OnlyOwner  returns(bool){

        if((pool[0] != address(0)) && (newTalentsAndPartnerships == address(0))){
          newTalentsAndPartnerships = pool[0];
          emit PoolAddressAdded( "NewTalentsAndPartnerships", newTalentsAndPartnerships);
        }
        if((pool[1] != address(0)) && (platformMaintenance == address(0))){
          platformMaintenance = pool[1];
          emit PoolAddressAdded( "PlatformMaintenance", platformMaintenance);
        }
        if((pool[2] != address(0)) && (marketingAndRNR == address(0))){
          marketingAndRNR = pool[2];
          emit PoolAddressAdded( "MarketingAndRNR", marketingAndRNR);
        }
        if((pool[3] != address(0)) && (kmPards == address(0))){
          kmPards = pool[3];
          emit PoolAddressAdded( "KmPards", kmPards);
        }
        if((pool[4] != address(0)) && (contingencyFunds == address(0))){
          contingencyFunds = pool[4];
          emit PoolAddressAdded( "ContingencyFunds", contingencyFunds);
        }
        if((pool[5] != address(0)) && (researchAndDevelopment == address(0))){
          researchAndDevelopment = pool[5];
          emit PoolAddressAdded( "ResearchAndDevelopment", researchAndDevelopment);
        }
        if((pool[6] != address(0)) && (buzzCafe == address(0))){
          buzzCafe = pool[6];
          emit PoolAddressAdded( "BuzzCafe", buzzCafe);
        }
        if((pool[7] != address(0)) && (timeSwappers == address(0))){
          timeSwappers = pool[7];
          emit PoolAddressAdded( "TimeSwapper", timeSwappers);
        }
        if((pool[8] != address(0)) && (TimeAlly == address(0))){
          TimeAlly = pool[8];
          emit PoolAddressAdded( "TimeAlly", TimeAlly);
        }

        return true;
      }


      /**
      * @dev Function to update luckpool balance
      * @param amount Amount to be updated
      */
      function UpdateLuckpool(uint256 amount) external OnlyAllowed returns(bool){
        require(token.transferFrom(msg.sender,address(this), amount),"Amount should be successfully transfered");
        luckPoolBal = luckPoolBal.add(amount);
        emit LuckPoolUpdated(luckPoolBal);
        return true;
      }

      /**
      * @dev Function to trigger to update  for burning of tokens
      * @param amount Amount to be updated
      */
      function UpdateBurnBal(uint256 amount) external OnlyAllowed returns(bool){
        require(token.transferFrom(msg.sender,address(this), amount),"Amount should be successfully transfered");
        burnTokenBal = burnTokenBal.add(amount);
        emit BurnTokenBalUpdated(burnTokenBal);
        return true;
      }

      /**
      * @dev To invoke monthly release
      * @return true if success
      */

      function MonthlyNRTRelease() external returns (bool) {
        require(now.sub(lastNRTRelease)> 2592000,"NRT release happens once every month");
        uint256 NRTBal = monthlyNRTAmount.add(luckPoolBal);        // Total NRT available.

        // Calculating NRT to be released to each of the pools
        newTalentsAndPartnershipsBal = (NRTBal.mul(5)).div(100);
        platformMaintenanceBal = (NRTBal.mul(10)).div(100);
        marketingAndRNRBal = (NRTBal.mul(10)).div(100);
        kmPardsBal = (NRTBal.mul(10)).div(100);
        contingencyFundsBal = (NRTBal.mul(10)).div(100);
        researchAndDevelopmentBal = (NRTBal.mul(5)).div(100);

        buzzCafeNRT = (NRTBal.mul(25)).div(1000);
        TimeAllyNRT = (NRTBal.mul(15)).div(100);
        timeSwappersNRT = (NRTBal.mul(325)).div(1000);

        // sending tokens to respective wallets and emitting events
        token.mint(newTalentsAndPartnerships,newTalentsAndPartnershipsBal);
        emit NRTTransfer("newTalentsAndPartnerships", newTalentsAndPartnerships, newTalentsAndPartnershipsBal);

        token.mint(platformMaintenance,platformMaintenanceBal);
        emit NRTTransfer("platformMaintenance", platformMaintenance, platformMaintenanceBal);

        token.mint(marketingAndRNR,marketingAndRNRBal);
        emit NRTTransfer("marketingAndRNR", marketingAndRNR, marketingAndRNRBal);

        token.mint(kmPards,kmPardsBal);
        emit NRTTransfer("kmPards", kmPards, kmPardsBal);

        token.mint(contingencyFunds,contingencyFundsBal);
        emit NRTTransfer("contingencyFunds", contingencyFunds, contingencyFundsBal);

        token.mint(researchAndDevelopment,researchAndDevelopmentBal);
        emit NRTTransfer("researchAndDevelopment", researchAndDevelopment, researchAndDevelopmentBal);

        token.mint(buzzCafe,buzzCafeNRT);
        emit NRTTransfer("buzzCafe", buzzCafe, buzzCafeNRT);

        token.mint(TimeAlly,TimeAllyNRT);
        emit NRTTransfer("stakingContract", TimeAlly, TimeAllyNRT);

        token.mint(timeSwappers,timeSwappersNRT);
        emit NRTTransfer("timeSwappers", timeSwappers, timeSwappersNRT);

        // Reseting NRT
        emit NRTDistributed(NRTBal);
        luckPoolBal = 0;
        lastNRTRelease = lastNRTRelease.add(30 days); // resetting release date again
        burnTokens();                                 // burning burnTokenBal
        emit TokensBurned(burnTokenBal);


        if(monthCount == 11){
          monthCount = 0;
          annualNRTAmount = (annualNRTAmount.mul(90)).div(100);
          monthlyNRTAmount = annualNRTAmount.div(12);
        }
        else{
          monthCount = monthCount.add(1);
        }
        return true;
      }


    /**
    * @dev Constructor
    */

    constructor(address eraswaptoken) public{
      token = Eraswap(eraswaptoken);
      lastNRTRelease = now;
      annualNRTAmount = 819000000000000000000000000;
      monthlyNRTAmount = annualNRTAmount.div(uint256(12));
      monthCount = 0;
      Owner = msg.sender;
    }

}
