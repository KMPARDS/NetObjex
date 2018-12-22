pragma solidity ^0.4.24;

// File: openzeppelin-solidity/contracts/ownership/Ownable.sol

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @return the address of the owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    /**
     * @return true if `msg.sender` is the owner of the contract.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Allows the current owner to relinquish control of the contract.
     * @notice Renouncing to ownership will leave the contract without an owner.
     * It will not be possible to call the functions with the `onlyOwner`
     * modifier anymore.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// File: openzeppelin-solidity/contracts/access/Roles.sol

/**
 * @title Roles
 * @dev Library for managing addresses assigned to a Role.
 */
library Roles {
    struct Role {
        mapping (address => bool) bearer;
    }

    /**
     * @dev give an account access to this role
     */
    function add(Role storage role, address account) internal {
        require(account != address(0));
        require(!has(role, account));

        role.bearer[account] = true;
    }

    /**
     * @dev remove an account's access to this role
     */
    function remove(Role storage role, address account) internal {
        require(account != address(0));
        require(has(role, account));

        role.bearer[account] = false;
    }

    /**
     * @dev check if an account has this role
     * @return bool
     */
    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0));
        return role.bearer[account];
    }
}

// File: openzeppelin-solidity/contracts/access/roles/SignerRole.sol

contract SignerRole {
    using Roles for Roles.Role;

    event SignerAdded(address indexed account);
    event SignerRemoved(address indexed account);

    Roles.Role private _signers;

    constructor () internal {
        _addSigner(msg.sender);
    }

    modifier onlySigner() {
        require(isSigner(msg.sender));
        _;
    }

    function isSigner(address account) public view returns (bool) {
        return _signers.has(account);
    }

    function addSigner(address account) public onlySigner {
        _addSigner(account);
    }

    function renounceSigner() public {
        _removeSigner(msg.sender);
    }

    function _addSigner(address account) internal {
        _signers.add(account);
        emit SignerAdded(account);
    }

    function _removeSigner(address account) internal {
        _signers.remove(account);
        emit SignerRemoved(account);
    }
}

// File: openzeppelin-solidity/contracts/math/SafeMath.sol

/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {
    int256 constant private INT256_MIN = -2**255;

    /**
    * @dev Multiplies two unsigned integers, reverts on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
    * @dev Multiplies two signed integers, reverts on overflow.
    */
    function mul(int256 a, int256 b) internal pure returns (int256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        require(!(a == -1 && b == INT256_MIN)); // This is the only case of overflow not detected by the check below

        int256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
    * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
    * @dev Integer division of two signed integers truncating the quotient, reverts on division by zero.
    */
    function div(int256 a, int256 b) internal pure returns (int256) {
        require(b != 0); // Solidity only automatically asserts when dividing by 0
        require(!(b == -1 && a == INT256_MIN)); // This is the only case of overflow

        int256 c = a / b;

        return c;
    }

    /**
    * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
    * @dev Subtracts two signed integers, reverts on overflow.
    */
    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));

        return c;
    }

    /**
    * @dev Adds two unsigned integers, reverts on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
    * @dev Adds two signed integers, reverts on overflow.
    */
    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));

        return c;
    }

    /**
    * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
    * reverts when dividing by zero.
    */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

// File: openzeppelin-solidity/contracts/token/ERC20/IERC20.sol

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: contracts/Staking.sol

// contract to manage staking of one year and two year stakers

contract Staking{
    using SafeMath for uint256;


    IERC20 public tokenContract;  // Defining conract address so as to interact with EraswapToken
   
    // Luckpool Balance

    uint256 public luckPoolBal;
     // Counts of different stakers
    uint256 public OneYearStakerCount;
    uint256 public TwoYearStakerCount;
    uint256 public TotalStakerCount;

    // Total staking balances
    uint256 public OneYearStakersBal;
    uint256 public TwoYearStakersBal;

    // orderID to uniquely identify the staking order
    uint256 OneYearOrderId=100000;
    uint256 TwoYearOrderId=100000;

    // OneYearStakers Details
    struct Staker {
        bool isTwoYear;         // to check whether its one or two year
        bool loan;              // to check whether loan is taken
        uint256 loanCount;      // to check limit of loans that can be taken
        uint256 loanStartTime;  // to keep a check in loan period
        uint256 orderID;        // unique orderid to uniquely identify the order
        uint256 stakedAmount;   // Amount Staked
        uint256 stakedTime;     // Time at which the user staked

    }

    

    mapping (uint256 => address) public  OneYearOwnership; // orderid ==> address of user
    mapping (uint256 => address) public TwoYearOwnership; // orderid ==> address of user
    
    mapping (uint256 => Staker) public OneYearStakingDetails;   //orderid ==> order details
    mapping (uint256 => Staker) public TwoYearStakingDetails;   //orderid ==> order details


  /**
   * @dev Throws if not times up to close a contract
   * @param orderID to identify the unique staking contract
   * @param isTwoYear to identify whther its one / two year contract
   */
    modifier isWithinPeriod(uint256 orderID,bool isTwoYear) {
        if(isTwoYear)
        {
        require(now <= TwoYearStakingDetails[orderID].stakedTime + 730 days,"Contract can only be ended after 2 years");
        }
        else{
            require(now <= OneYearStakingDetails[orderID].stakedTime + 365 days,"Contract can only be ended after 1 years");
        }
        _;
    }

    /**
   * @dev To check if loan is initiated
   * @param orderID to identify the unique staking contract
   * @param isTwoYear to identify whther its one / two year contract
   */
   modifier isNoLoanTaken(uint256 orderID,bool isTwoYear) {
        if(isTwoYear)
        {
        require(TwoYearStakingDetails[orderID].loan != true,"Loan is present");
        }
        else{
            require(OneYearStakingDetails[orderID].loan != true,"Loan is present");
        }
        _;
    }

        /**
   * @dev To check whether its valid staker 
   * @param orderID to identify the unique staking contract
   * @param isTwoYear to identify whther its one / two year contract
   */
   modifier onlyStakeOwner(uint256 orderID,bool isTwoYear) {
        if(isTwoYear)
        {
        require(TwoYearOwnership[orderID] == msg.sender,"Staking owner should be valid");
        }
        else{
        require(OneYearOwnership[orderID] == msg.sender,"Staking owner should be valid");
        }
        _;
    }

   /**
   * @dev To create staking contract
   * @param Amount Total Est which is to be Staked
   * @param isTwoYear to identify whther its one / two year contract
   * @return orderId of created 
   */

    function createStakingContract(uint256 Amount,bool isTwoYear) external returns (uint256){ 
        if(isTwoYear){
            TwoYearOrderId = TwoYearOrderId.add(1);
            TwoYearStakerCount = TwoYearStakerCount.add(1);
            TwoYearStakersBal = TwoYearStakersBal.add(Amount);
            TwoYearOwnership[TwoYearOrderId] = msg.sender;
            TwoYearStakingDetails[TwoYearOrderId] = Staker(true,false,0,0,TwoYearOrderId,Amount, 730 days);
            require(tokenContract.transfer(address(this), Amount), "The token transfer should be done");
            return TwoYearOrderId;
        }
        else{
            OneYearOrderId = OneYearOrderId.add(1);
            OneYearStakerCount = OneYearStakerCount.add(1);
            OneYearStakersBal = OneYearStakersBal.add(Amount);
            OneYearOwnership[OneYearOrderId] = msg.sender;
            OneYearStakingDetails[OneYearOrderId] = Staker(false,false,0,0,OneYearOrderId,Amount, 365 days);
            require(tokenContract.transfer(address(this), Amount), "The token transfer should be done");
            return OneYearOrderId;
        }
    }
 
    /**
   * @dev To check if loan is initiated
   * @param orderId Total Est which is to be Staked
   * @param isTwoYear to identify whther its one / two year contract
   * @return orderId of created 
   */
  function takeLoan(uint256 orderId, bool isTwoYear) onlyStakeOwner(orderId,isTwoYear) isNoLoanTaken(orderId, isTwoYear) isWithinPeriod(orderId,isTwoYear) external returns (bool){
    if(isTwoYear){
          require(TwoYearStakingDetails[orderId].loanCount <= 1 ,"only one loan per year is allowed");
          require((TwoYearStakingDetails[orderId].stakedTime).sub(now)>= 60 days,"Contract End is near");
          TwoYearStakerCount = TwoYearStakerCount.sub(1);
          TwoYearStakersBal = TwoYearStakersBal.sub(TwoYearStakingDetails[orderId].stakedAmount);
          TwoYearStakingDetails[orderId].loan =true;
          TwoYearStakingDetails[orderId].loanStartTime = now;
          TwoYearStakingDetails[orderId].loanCount = (TwoYearStakingDetails[orderId].loanCount).add(1);
          require(tokenContract.transfer(msg.sender,(TwoYearStakingDetails[orderId].stakedAmount).div(2)),"The contract should transfer loan amount");
          return true;
      }
      else{
          require(OneYearStakingDetails[orderId].loanCount == 0,"only one loan per year is allowed");
          require((OneYearStakingDetails[orderId].stakedTime).sub(now)>= 60 days,"Contract End is near");
          OneYearStakerCount = OneYearStakerCount.sub(1);
          OneYearStakersBal = OneYearStakersBal.sub(OneYearStakingDetails[orderId].stakedAmount);
          OneYearStakingDetails[orderId].loan =true;
          OneYearStakingDetails[orderId].loanStartTime = now;
          OneYearStakingDetails[orderId].loanCount = (OneYearStakingDetails[orderId].loanCount).add(1);
          require(tokenContract.transfer(msg.sender,(OneYearStakingDetails[orderId].stakedAmount).div(2)),"The contract should transfer loan amount");
          return true;
      }
  }

  function rePayLoan(uint256 orderId, bool isTwoYear) onlyStakeOwner(orderId,isTwoYear) isWithinPeriod(orderId,isTwoYear) external returns (bool){
      if(isTwoYear){
          uint256 TempLoan1 = (TwoYearStakingDetails[orderId].stakedAmount).div(2);
          require(TwoYearStakingDetails[orderId].loan == true,"User should have taken loan");
          require((TwoYearStakingDetails[orderId].loanStartTime).sub(now) < 60 days,"Loan repayment should be done on time");
          TwoYearStakingDetails[orderId].loan = false;
          TwoYearStakingDetails[orderId].loanStartTime = 0;
          luckPoolBal = luckPoolBal.add(TempLoan1.div(100));
          TwoYearStakerCount = TwoYearStakerCount.add(1);
          TwoYearStakersBal = TwoYearStakersBal.add(TwoYearStakingDetails[orderId].stakedAmount);
          require(tokenContract.transfer(address(this),(TempLoan1.mul(101)).div(100)),"The contract should receive loan amount with interest");
          return true;
      }
      else{
          uint256 TempLoan2 = (OneYearStakingDetails[orderId].stakedAmount).div(2);
          require(OneYearStakingDetails[orderId].loan == true,"User should have taken loan");
          require((OneYearStakingDetails[orderId].loanStartTime).sub(now) < 60 days,"Loan repayment should be done on time");
          OneYearStakingDetails[orderId].loan = false;
          OneYearStakingDetails[orderId].loanStartTime = 0;
          luckPoolBal = luckPoolBal.add(TempLoan2.div(100));
          OneYearStakerCount = OneYearStakerCount.add(1);
          OneYearStakersBal = OneYearStakersBal.add(OneYearStakingDetails[orderId].stakedAmount);
          require(tokenContract.transfer(address(this),(TempLoan2.mul(101)).div(100)),"The contract should receive loan amount with interest");
          return true;
      }
  }
  //should burn defaulters token and update balances in stakers
//   function updateStakers(){

//   }
   // function releaseMonthlyReturn


//   function windUpContract() external{

//   }
}

// File: contracts/NRTManager.sol

/**
* @title  NRT Distribution Contract
* @dev This contract will be responsible for distributing the newly released tokens to the different pools.
*/




// The contract addresses of different pools
contract NRTManager is Ownable, SignerRole, Staking{
    using SafeMath for uint256;

    address public eraswapToken;  // address of EraswapToken

    IERC20 public tokenContract;  // Defining conract address so as to interact with EraswapToken

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
        
        newTalentsAndPartnershipsBal = newTalentsAndPartnershipsBal.add((NRTBal.mul(5)).div(100));
        platformMaintenanceBal = platformMaintenanceBal.add((NRTBal.mul(10)).div(100));
        marketingAndRNRBal = marketingAndRNRBal.add((NRTBal.mul(10)).div(100));
        kmPardsBal = kmPardsBal.add((NRTBal.mul(10)).div(100));
        contingencyFundsBal = contingencyFundsBal.add((NRTBal.mul(10)).div(100));
        researchAndDevelopmentBal = researchAndDevelopmentBal.add((NRTBal.mul(5)).div(100));
        curatorsBal = curatorsBal.add((NRTBal.mul(5)).div(100));
        timeTradersBal = timeTradersBal.add((NRTBal.mul(5)).div(100));
        daySwappersBal = daySwappersBal.add((NRTBal.mul(125)).div(1000));
        buzzCafeBal = buzzCafeBal.add((NRTBal.mul(25)).div(1000)); 
        powerTokenBal = powerTokenBal.add((NRTBal.mul(10)).div(100));
        stakersBal = stakersBal.add((NRTBal.mul(15)).div(100));

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
        tokenContract = IERC20(eraswapToken);
        releaseNrtTime = now.add(30 days + 6 hours);
        AnnualReleaseNrt = 81900000000000000;
        MonthlyReleaseNrt = AnnualReleaseNrt.div(uint256(12));
        monthCount = 0;
    }

}
