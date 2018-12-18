pragma solidity ^0.4.24;
// contract to manage staking of one year and two year stakers

import "./EraswapToken.sol";

contract Staking{
    using SafeMath for uint256;

    uint256 stakedAmount; 
    uint256 stakedTime; 
    bool isTwoYear;
    bool isLoan;
    address owner;
    uint256[] cumilativeWithdrawable;

    EraswapToken tokenContract;  // Defining conract address so as to interact with EraswapToken
  /**
   * @dev Throws if not times up to close a contract
   */
    modifier isPeriodEnd() {
        if(isTwoYear)
        {
        require(now >= stakedTime + 730 days,"Contract can only be ended after 2 years");
        }
        else{
            require(now >= stakedTime + 365 days,"Contract can only be ended after 1 years");
        }
        _;
    }

    /**
   * @dev To check if loan is initiated
   */
   modifier isNoLoanTaken() {
       require(isLoan == false,"He should not have taken loan");
        _;
    }

     /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
  function withDrawInterest() onlyOwner() isNoLoanTaken(){

  }

  function takeLoan() onlyOwner() isNoLoanTaken(){
      require(tokenContract.transfer(owner, stakedAmount.div(2)),"The contract should transfer loan amount");
      isLoan =true;
  }

  function windUpContract(){

  }

     /**
   * @dev Intialises the contract
   * @param Amount Amount whichis to be staked
   * @param plan true if two year plan / false for one year plan
   * @param initiater Address of the staker
   */
    constructor(uint256 Amount,bool plan, address initiater, address token) public{
        stakedAmount = Amount;
        stakedTime = now;
        isTwoYear = plan;
        owner = initiater;
        isLoan = false;
        cumilativeWithdrawable[0] = Amount;
        tokenContract = EraswapToken(eraswapToken);

    }
}