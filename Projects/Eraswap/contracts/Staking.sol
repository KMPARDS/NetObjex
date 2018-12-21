pragma solidity ^0.4.24;
// contract to manage staking of one year and two year stakers
import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "./EraswapToken.sol";

contract Staking{
    using SafeMath for uint256;


    EraswapToken tokenContract;  // Defining conract address so as to interact with EraswapToken

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
        uint256 loanCount;        // to check limit of loans that can be taken
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
    modifier isPeriodEnd(uint256 orderID,bool isTwoYear) {
        if(isTwoYear)
        {
        require(now >= TwoYearStakingDetails[orderID].stakedTime + 730 days,"Contract can only be ended after 2 years");
        }
        else{
            require(now >= OneYearStakingDetails[orderID].stakedTime + 365 days,"Contract can only be ended after 1 years");
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
            TwoYearStakingDetails[TwoYearOrderId] = Staker(true,false,0,TwoYearOrderId,Amount, 730 days);
            require(tokenContract.transfer(address(this), Amount), "The token transfer should be done");
            return TwoYearOrderId;
        }
        else{
            OneYearOrderId = OneYearOrderId.add(1);
            OneYearStakerCount = OneYearStakerCount.add(1);
            OneYearStakersBal = OneYearStakersBal.add(Amount);
            OneYearOwnership[OneYearOrderId] = msg.sender;
            OneYearStakingDetails[OneYearOrderId] = Staker(false,false,0,OneYearOrderId,Amount, 365 days);
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
  function takeLoan(uint256 orderId, bool isTwoYear) onlyStakeOwner(orderId,isTwoYear) isNoLoanTaken(orderId, isTwoYear) isPeriodEnd(orderId,isTwoYear) external returns (bool){
      if(isTwoYear){
          require(TwoYearStakingDetails[orderId].loanCount <= 1 ,"only one loan per year is allowed");
          TwoYearStakerCount = TwoYearStakerCount.sub(1);
          TwoYearStakersBal = TwoYearStakersBal.sub((TwoYearStakingDetails[orderId].stakedAmount).div(2));
          TwoYearStakingDetails[orderId].loan =true;
          TwoYearStakingDetails[orderId].loanCount = (TwoYearStakingDetails[orderId].loanCount).add(1);
          require(tokenContract.transfer(msg.sender,(TwoYearStakingDetails[orderId].stakedAmount).div(2)),"The contract should transfer loan amount");
          return true;
      }
      else{
          require(OneYearStakingDetails[orderId].loanCount == 0,"only one loan per year is allowed");
          OneYearStakerCount = OneYearStakerCount.sub(1);
          OneYearStakersBal = OneYearStakersBal.sub((OneYearStakingDetails[orderId].stakedAmount).div(2));
          OneYearStakingDetails[orderId].loan =true;
          OneYearStakingDetails[orderId].loanCount = (OneYearStakingDetails[orderId].loanCount).add(1);
          require(tokenContract.transfer(msg.sender,(OneYearStakingDetails[orderId].stakedAmount).div(2)),"The contract should transfer loan amount");
          return true;
      }
  }
  //function payLoanInterest
  // function updateStakers should burn defaulters token and update balances in stakers
   // function releaseMonthlyReturn


//   function windUpContract() external{

//   }
}