pragma solidity ^0.4.24;

// contract to manage staking of one year and two year stakers
import "./IERC20.sol";
import "./NRTManager.sol";

// Database Design based on CRUD by Rob Hitchens . Refer : https://medium.com/@robhitchens/solidity-crud-part-1-824ffa69509a

contract Staking {
    using SafeMath for uint256;
    
    address public NRTManagerAddr;
    NRTManager NRTContract;

    // Event to watch staking creations
    event stakeCreation(
    uint64 orderid,
    address indexed ownerAddress,
    uint256 value
    );


    // Event to watch loans repayed taken
    event loanTaken(
    uint64 orderid
    );

    // Event to watch wind up of contracts
    event windupContract(
    uint64 orderid
    );

    IERC20   tokenContract;  // Defining conract address so as to interact with EraswapToken
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
    uint64[] public delList;

    // Total staking balances after NRT release
    uint256 public OneYearStakersBal;
    uint256 public TwoYearStakersBal;

   
    uint64 OrderId=100000;  // orderID to uniquely identify the staking order


    struct Staker {
        bool isTwoYear;         // to check whether its one or two year
        bool loan;              // to check whether loan is taken
        uint8 loanCount;      // to check limit of loans that can be taken
        uint64 index;          // index
        uint64 orderID;        // unique orderid to uniquely identify the order
        uint256 stakedAmount;   // amount Staked
        uint256 stakedTime;     // Time at which the user staked
        uint256 windUpTime;     // to check time of windup started
        uint256 loanStartTime;  // to keep a check in loan period

    }

    mapping (uint64 => address) public  StakingOwnership; // orderid ==> address of user
    mapping (uint64 => Staker) public StakingDetails;     //orderid ==> order details
    mapping (uint64 => uint256[]) public cumilativeStakedDetails; // orderid ==> to store the cumilative amount of NRT stored per month
    mapping (uint64 => uint256) public totalNrtMonthCount; // orderid ==> to keep tab on how many times NRT was received

    uint64[] public OrderList;  // to store all active orders in which the state need to be changed monthly
  


   /**
   * @dev Throws if not times up to close a contract
   * @param orderID to identify the unique staking contract
   */
    modifier isWithinPeriod(uint64 orderID) {
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
   modifier isNoLoanTaken(uint64 orderID) {
        require(StakingDetails[orderID].loan != true,"Loan is present");
        _;
    }

   /**
   * @dev To check whether its valid staker 
   * @param orderID to identify the unique staking contract
   */
   modifier onlyStakeOwner(uint64 orderID) {
        require(StakingOwnership[orderID] == msg.sender,"Staking owner should be valid");
        _;
    }

       
 
  /**
   * @dev Should delete unwanted orders
   * @return true if success
   */
// todo recheck the limit for this
function deleteList() internal returns (bool){
      for (uint j = delList.length - 1;j > 0;j--)
      {
          deleteRecord(delList[j]);
          delList.length--;
      }
      return true;
}


   /**
   * @dev To create staking contract
   * @param amount Total Est which is to be Staked
   * @return orderId of created 
   */

    function createStakingContract(uint256 amount,bool isTwoYear) external returns (uint64) { 
            OrderId = OrderId + 1;
            StakingOwnership[OrderId] = msg.sender;
            uint64 index = uint64(OrderList.push(OrderId) - 1);
            cumilativeStakedDetails[OrderId].push(amount);
            if (isTwoYear) {
            TwoYearStakerCount = TwoYearStakerCount.add(1);
            TwoYearStakedAmount = TwoYearStakedAmount.add(amount);
            StakingDetails[OrderId] = Staker(true,false,0,index,OrderId,amount, now,0,0);
            }else {
            OneYearStakerCount = OneYearStakerCount.add(1);
            OneYearStakedAmount = OneYearStakedAmount.add(amount);
            StakingDetails[OrderId] = Staker(false,false,0,index,OrderId,amount, now,0,0);
            }
            require(tokenContract.transferFrom(msg.sender,address(this), amount), "The token transfer should be done");
            emit stakeCreation(OrderId,StakingOwnership[OrderId], amount);
            return OrderId;
        }

    /**
   * @dev Function to check whether a partcicular order exists
   * @param orderId to identify unique staking contract
   * @return true if success
   */

  function isOrderExist(uint64 orderId) public view returns(bool) {
      return OrderList[StakingDetails[orderId].index] == orderId;
 }
 
    /**
   * @dev To check if loan is initiated
   * @param orderId to identify unique staking contract
   * @return orderId of created 
   */
  function takeLoan(uint64 orderId) onlyStakeOwner(orderId) isNoLoanTaken(orderId) isWithinPeriod(orderId) external returns (bool) {
    require(isOrderExist(orderId),"The orderId should exist");
    if (StakingDetails[orderId].isTwoYear) {
          require(((StakingDetails[orderId].stakedTime).add(730 days)).sub(now) >= 60 days,"Contract End is near");
          require(StakingDetails[orderId].loanCount <= 1,"only one loan per year is allowed");        
          TwoYearStakerCount = TwoYearStakerCount.sub(1);
          TwoYearStakedAmount = TwoYearStakedAmount.sub(StakingDetails[orderId].stakedAmount);
    }else {
          require(((StakingDetails[orderId].stakedTime).add(365 days)).sub(now) >= 60 days,"Contract End is near");
          require(StakingDetails[orderId].loanCount == 0,"only one loan per year is allowed");        
          OneYearStakerCount = OneYearStakerCount.sub(1);
          OneYearStakedAmount = OneYearStakedAmount.sub(StakingDetails[orderId].stakedAmount);
    }
          StakingDetails[orderId].loan = true;
          StakingDetails[orderId].loanStartTime = now;
          StakingDetails[orderId].loanCount = StakingDetails[orderId].loanCount + 1;
          // todo: check this transfer, it may not be doing as expected
          require(tokenContract.transferFrom(address(this),msg.sender,(StakingDetails[orderId].stakedAmount).div(2)),"The contract should transfer loan amount");
          emit loanTaken(orderId);
          return true;
      }
      
  /**
   * @dev To repay the leased loan
   * @param orderId to identify unique staking contract
   * @return total repayment
   */

  function calculateRepaymentTotalPayment(uint64 orderId)  public view returns (uint256) {
          uint temp;
          require(isOrderExist(orderId),"The orderId should exist");
          require((StakingDetails[orderId].loan && (StakingDetails[orderId].loanStartTime < now.add(60 days))),"should have loan");
          temp = ((StakingDetails[orderId].stakedAmount).div(200)).mul(101);
          return temp;
      
  }
   /**
   * @dev To check if eligible for repayment
   * @param orderId to identify unique staking contract
   * @return total repayment
   */
  function isEligibleForRepayment(uint64 orderId)  public view returns (bool) {
          require(isOrderExist(orderId) == true,"The orderId should exist");
          require(StakingDetails[orderId].loan == true,"User should have taken loan");
          require((StakingDetails[orderId].loanStartTime).sub(now) < 60 days,"Loan repayment should be done on time");
          return true;
  }
   /**
   * @dev To repay the leased loan
   * @param orderId to identify unique staking contract
   * @return true if success
   */
  function rePayLoan(uint64 orderId) onlyStakeOwner(orderId) isWithinPeriod(orderId) external returns (bool) {
      require(isEligibleForRepayment(orderId) == true,"The user should be eligible for repayment");
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
          require(tokenContract.transferFrom(msg.sender,address(this),calculateRepaymentTotalPayment(orderId)),"The contract should receive loan amount with interest");
          return true;
  }



 /**
   * @dev Function to delete a particular order
   * @param orderId to identify unique staking contract
   * @return true if success
   */

  function deleteRecord(uint64 orderId) internal returns (bool) {
      require(isOrderExist(orderId) == true,"The orderId should exist");
      uint64 rowToDelete = StakingDetails[orderId].index;
      uint64 orderToMove = OrderList[OrderList.length-1];
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

  function sendTokens(uint64 orderId, uint256 amount) internal returns (bool) {
      // todo: check this transfer, it may not be doing as expected
      require(tokenContract.transferFrom(address(this),StakingOwnership[orderId], amount),"The contract should send from its balance to the user");
      return true;
  }
  
/**
   * @dev Function to windup an active contact
   * @param orderId to identify unique staking contract
   * @return true if success
   */

  function windUpContract(uint64 orderId) onlyStakeOwner(orderId)  external returns (bool) {
      require(isOrderExist(orderId) == true,"The orderId should exist");
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

function preStakingDistribution() internal returns(bool){
    require(deleteList(),"should update lists");
    uint256 temp = NRTContract.stakersBal();
    if(temp == 0)
    {
        return true;
    }
    require(NRTContract.resetStaking(),"It should be successfully reset");
     if(OneYearStakerCount>0)
        {
        OneYearStakersBal = (temp.mul(OneYearStakerCount)).div(TotalStakerCount);
        TwoYearStakersBal = (temp.mul(TwoYearStakerCount)).div(TotalStakerCount);
        luckPoolBal = (OneYearStakersBal.mul(2)).div(15);
        OneYearStakersBal = OneYearStakersBal.sub(luckPoolBal);
        }
        else{
            TwoYearStakersBal = temp;
        }
        return true;
}

    /**
   * @dev Should update all the stakers state
   * @return true if success
   */
//todo should send burn tokens to nrt and update burn balance
  function updateStakers() external returns(bool) {
      uint temp;
      uint temp1;
      uint256 burnTokenBal;
      require(preStakingDistribution() == true,"pre staking disribution should be done");
      for (uint i = 0;i < OrderList.length; i++) {
          if (StakingDetails[OrderList[i]].windUpTime > 0) {
                // should distribute 104th of staked amount
                if(StakingDetails[OrderList[i]].windUpTime < now){
                temp = ((StakingDetails[OrderList[i]].windUpTime.sub(StakingDetails[OrderList[i]].stakedTime)).div(104 weeks))
                        .mul(StakingDetails[OrderList[i]].stakedAmount);
                delList.push(OrderList[i]);
                }
                else{
                temp = ((now.sub(StakingDetails[OrderList[i]].stakedTime)).div(104 weeks)).mul(StakingDetails[OrderList[i]].stakedAmount);
                StakingDetails[OrderList[i]].stakedTime = now;
                }
                sendTokens(OrderList[i],temp);
          }else if (StakingDetails[OrderList[i]].loan && (StakingDetails[OrderList[i]].loanStartTime > 60 days) ) {
              burnTokenBal = burnTokenBal.add((StakingDetails[OrderList[i]].stakedAmount).div(2));
              delList.push(OrderList[i]);
          }else if(StakingDetails[OrderList[i]].loan){
              continue;
          }
          else if (StakingDetails[OrderList[i]].isTwoYear) {
                // transfers half of the NRT received back to user and half is staked back to pool
                totalNrtMonthCount[OrderList[i]] = totalNrtMonthCount[OrderList[i]].add(1);
                temp = (((StakingDetails[OrderList[i]].stakedAmount).div(TwoYearStakedAmount)).mul(TwoYearStakersBal)).div(2);
                if(cumilativeStakedDetails[OrderList[i]].length < 24){
                cumilativeStakedDetails[OrderList[i]].push(temp);
                sendTokens(OrderList[i],temp);
                }
                else{
                    temp1 = temp;
                    temp = temp.add(cumilativeStakedDetails[OrderList[i]][totalNrtMonthCount[OrderList[i]] % 24]); 
                    cumilativeStakedDetails[OrderList[i]][totalNrtMonthCount[OrderList[i]] % 24] = temp1; 
                    sendTokens(OrderList[i],temp);
                }
          }else {
              // should distribute the proporsionate amount of staked value for one year
              totalNrtMonthCount[OrderList[i]] = totalNrtMonthCount[OrderList[i]].add(1);
              temp = (((StakingDetails[OrderList[i]].stakedAmount).div(OneYearStakedAmount)).mul(OneYearStakersBal)).div(2);
              if(cumilativeStakedDetails[OrderList[i]].length < 12){
              cumilativeStakedDetails[OrderList[i]].push(temp);
              sendTokens(OrderList[i],temp);
              }
              else{
                    temp1 = temp;
                    temp = temp.add(cumilativeStakedDetails[OrderList[i]][totalNrtMonthCount[OrderList[i]] % 12]); 
                    cumilativeStakedDetails[OrderList[i]][totalNrtMonthCount[OrderList[i]] % 12] = temp1; 
                    sendTokens(OrderList[i],temp);
                }
          }
      }
      require(NRTContract.updateBurnBal(burnTokenBal),"updating burnable token");
      burnTokenBal = 0;
      return true;
  }

     /**
    * @dev Constructor
    * @param token Address of eraswaptoken
    * @param NRT Address of NRTcontract
    */

    constructor (address token,address NRT) public{
        require(token != address(0),"address should be valid");
        eraswapToken = token;
        tokenContract = IERC20(eraswapToken);
        NRTManagerAddr = NRT;
        NRTContract = NRTManager(NRTManagerAddr);
    }

}