pragma solidity ^0.4.24;

// contract to manage staking of one year and two year stakers
import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "./IERC20.sol";

// Database Design based on CRUD by Rob Hitchens . Refer : https://medium.com/@robhitchens/solidity-crud-part-1-824ffa69509a

contract Staking {
    using SafeMath for uint256;

    // Event to watch staking creations
    event stakeCreation(
    uint256 orderid,
    address indexed ownerAddress,
    uint256 value
    );


    // Event to watch loans repayed taken
    event loanTaken(
    uint256 orderid
    );

    // Event to watch wind up of contracts
    event windupContract(
    uint256 orderid
    );

    IERC20  public tokenContract;  // Defining conract address so as to interact with EraswapToken
    address public eraswapToken;  // address of EraswapToken

    uint256 public luckPoolBal;    // Luckpool Balance

     // Counts of different stakers
    uint256 public  OneYearStakerCount;
    uint256 public TwoYearStakerCount;
    uint256 public TotalStakerCount;

    // Total staked amounts
    uint256 public OneYearStakedAmount;
    uint256 public TwoYearStakedAmount;

    // Burn away token count
    uint256 public burnTokenBal;
    uint256[] public delList;

   
    uint256 OrderId=100000;  // orderID to uniquely identify the staking order


    struct Staker {
        uint256 windUpTime;     // to check time of windup started
        bool isTwoYear;         // to check whether its one or two year
        bool loan;              // to check whether loan is taken
        uint256 loanCount;      // to check limit of loans that can be taken
        uint256 loanStartTime;  // to keep a check in loan period
        uint256 orderID;        // unique orderid to uniquely identify the order
        uint256 stakedAmount;   // amount Staked
        uint256 stakedTime;     // Time at which the user staked
        uint256 index;          // index

    }

    mapping (uint256 => address) public  StakingOwnership; // orderid ==> address of user
    mapping (uint256 => Staker) public StakingDetails;     //orderid ==> order details
    mapping (uint256 => uint256[]) public cumilativeStakedDetails; // orderid ==> to store the cumilative amount of NRT stored per month
    mapping (uint256 => uint256) public totalNrtMonthCount; // orderid ==> to keep tab on how many times NRT was received

    uint256[] public OrderList;  // to store all active orders in which the state need to be changed monthly
  


   /**
   * @dev Throws if not times up to close a contract
   * @param orderID to identify the unique staking contract
   */
    modifier isWithinPeriod(uint256 orderID) {
        if (StakingDetails[orderID].isTwoYear) {
        require(now <= StakingDetails[orderID].stakedTime + 730 days,"Contract can only be ended after 2 years");
        }else {
        require(now <= StakingDetails[orderID].stakedTime + 365 days,"Contract can only be ended after 1 years");
        }
        _;
    }

   /**
   * @dev To check if loan is initiated
   * @param orderID to identify the unique staking contract
   */
   modifier isNoLoanTaken(uint256 orderID) {
        require(StakingDetails[orderID].loan != true,"Loan is present");
        _;
    }

   /**
   * @dev To check whether its valid staker 
   * @param orderID to identify the unique staking contract
   */
   modifier onlyStakeOwner(uint256 orderID) {
        require(StakingOwnership[orderID] == msg.sender,"Staking owner should be valid");
        _;
    }

   /**
   * @dev To create staking contract
   * @param amount Total Est which is to be Staked
   * @return orderId of created 
   */

    function createStakingContract(uint256 amount,bool isTwoYear) external returns (uint256) { 
            OrderId = OrderId.add(1);
            StakingOwnership[OrderId] = msg.sender;
            uint index = OrderList.push(OrderId) - 1;
            cumilativeStakedDetails[OrderId].push(amount);
            if (isTwoYear) {
            TwoYearStakerCount = TwoYearStakerCount.add(1);
            TwoYearStakedAmount = TwoYearStakedAmount.add(amount);
            StakingDetails[OrderId] = Staker(0,true,false,0,0,OrderId,amount, now,index);
            }else {
            OneYearStakerCount = OneYearStakerCount.add(1);
            OneYearStakedAmount = OneYearStakedAmount.add(amount);
            StakingDetails[OrderId] = Staker(0,false,false,0,0,OrderId,amount, now,index);
            }
            require(tokenContract.transfer(address(this), amount), "The token transfer should be done");
            emit stakeCreation(OrderId,StakingOwnership[OrderId], amount);
            return OrderId;
        }

    /**
   * @dev Function to check whether a partcicular order exists
   * @param orderId to identify unique staking contract
   * @return true if success
   */

  function isOrderExist(uint256 orderId) public view returns(bool) {
      return OrderList[StakingDetails[orderId].index] == orderId;
 }
 
    /**
   * @dev To check if loan is initiated
   * @param orderId to identify unique staking contract
   * @return orderId of created 
   */
  function takeLoan(uint256 orderId) onlyStakeOwner(orderId) isNoLoanTaken(orderId) isWithinPeriod(orderId) external returns (bool) {
    require(isOrderExist(orderId),"The orderId should exist");
    require((StakingDetails[orderId].stakedTime).sub(now) >= 60 days,"Contract End is near");
    if (StakingDetails[orderId].isTwoYear) {
          require(StakingDetails[orderId].loanCount <= 1,"only one loan per year is allowed");        
          TwoYearStakerCount = TwoYearStakerCount.sub(1);
          TwoYearStakedAmount = TwoYearStakedAmount.sub(StakingDetails[orderId].stakedAmount);
    }else {
          require(StakingDetails[orderId].loanCount == 0,"only one loan per year is allowed");        
          OneYearStakerCount = OneYearStakerCount.sub(1);
          OneYearStakedAmount = OneYearStakedAmount.sub(StakingDetails[orderId].stakedAmount);
    }
          StakingDetails[orderId].loan = true;
          StakingDetails[orderId].loanStartTime = now;
          StakingDetails[orderId].loanCount = (StakingDetails[orderId].loanCount).add(1);
          // todo: check this transfer, it may not be doing as expected
          require(tokenContract.transfer(msg.sender,(StakingDetails[orderId].stakedAmount).div(2)),"The contract should transfer loan amount");
          emit loanTaken(orderId);
          return true;
      }
      
  /**
   * @dev To repay the leased loan
   * @param orderId to identify unique staking contract
   * @return total repayment
   */

  function calculateTotalPayment(uint256 orderId)  public view returns (uint256) {
          require(isOrderExist(orderId),"The orderId should exist");
          return ((StakingDetails[orderId].stakedAmount).div(200)).mul(101);
      
  }
   /**
   * @dev To check if eligible for repayment
   * @param orderId to identify unique staking contract
   * @return total repayment
   */
  function isEligibleForRepayment(uint256 orderId)  public view returns (bool) {
          require(isOrderExist(orderId),"The orderId should exist");
          require(StakingDetails[orderId].loan == true,"User should have taken loan");
          require((StakingDetails[orderId].loanStartTime).sub(now) < 60 days,"Loan repayment should be done on time");
          return true;
  }
   /**
   * @dev To repay the leased loan
   * @param orderId to identify unique staking contract
   * @return true if success
   */
  function rePayLoan(uint256 orderId) onlyStakeOwner(orderId) isWithinPeriod(orderId) external returns (bool) {
      require(isEligibleForRepayment(orderId),"The user should be eligible for repayment");
      StakingDetails[orderId].loan = false;
      StakingDetails[orderId].loanStartTime = 0;
      luckPoolBal = luckPoolBal.add((StakingDetails[orderId].stakedAmount).div(200));
      if (StakingDetails[orderId].isTwoYear) {  
          TwoYearStakerCount = TwoYearStakerCount.add(1);
          TwoYearStakedAmount = TwoYearStakedAmount.add(StakingDetails[orderId].stakedAmount);
      }else {  
          OneYearStakerCount = OneYearStakerCount.add(1);
          OneYearStakedAmount = OneYearStakedAmount.add(StakingDetails[orderId].stakedAmount);
      }
          // todo: check this transfer, it may not be doing as expected
          require(tokenContract.transfer(address(this),calculateTotalPayment(orderId)),"The contract should receive loan amount with interest");
          return true;
  }



 /**
   * @dev Function to delete a particular order
   * @param orderId to identify unique staking contract
   * @return true if success
   */

  function deleteRecord(uint256 orderId) internal returns (bool) {
      require(isOrderExist(orderId),"The orderId should exist");
      uint256 rowToDelete = StakingDetails[orderId].index;
      uint256 orderToMove = OrderList[OrderList.length-1];
      OrderList[rowToDelete] = orderToMove;
      StakingDetails[orderToMove].index = rowToDelete;
      OrderList.length--; 
      return true;
  }

   /**
   * @dev should send tokens to the user
   * @param orderId to identify unique staking contract
   * @param amount amount to be send
   * @return true if success
   */

  function sendTokens(uint256 orderId, uint256 amount) internal returns (bool) {
      // todo: check this transfer, it may not be doing as expected
      require(tokenContract.transfer(StakingOwnership[orderId], amount),"The contract should send from its balance to the user");
      return true;
  }
  
/**
   * @dev Function to windup an active contact
   * @param orderId to identify unique staking contract
   * @return true if success
   */

  function windUpContract(uint256 orderId) onlyStakeOwner(orderId)  external returns (bool) {
      require(isOrderExist(orderId),"The orderId should exist");
      require(StakingDetails[orderId].loan == false,"There should be no loan currently");
      require(StakingDetails[orderId].windUpTime == 0,"Windup Shouldn't be initiated currently");
      StakingDetails[orderId].windUpTime = now + 104 weeks; // time at which all the transfer must be finished
      StakingDetails[orderId].stakedTime = now; // to keep track of NRT being distributed out
      if (StakingDetails[orderId].isTwoYear) {      
          TwoYearStakerCount = TwoYearStakerCount.sub(1);
          TwoYearStakedAmount = TwoYearStakedAmount.sub(StakingDetails[orderId].stakedAmount);
    }else {     
          OneYearStakerCount = OneYearStakerCount.sub(1);
          OneYearStakedAmount = OneYearStakedAmount.sub(StakingDetails[orderId].stakedAmount);
    }
      emit windupContract( orderId);
      return true;
  }
}