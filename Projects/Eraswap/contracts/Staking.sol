pragma solidity ^0.4.24;
// contract to manage staking of one year and two year stakers
import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";

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