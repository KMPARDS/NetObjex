pragma solidity ^0.5.2;

import "./Staking.sol";
import "./LoanAndRefund.sol";
import "./Eraswap.sol";
import "./NRTManager.sol";

contract TimeAllyCore {

    using SafeMath for uint256;

    struct TimeAllyPlan{                         //Structure to store details of different Plans
        uint256 PlanPeriod;
        uint256 LoanInterestRate;
        uint256 LoanPeriod;
        uint256 refundWeeks;
    }
    uint256 public PlanID = 0;
    mapping (uint256 => TimeAllyPlan) public Plans;

    struct Contract {
        uint256 status;
        uint256 planid;
        address owner;
        uint256 timestamp;
    }
    uint256 public ContractID = 0;
    mapping (uint256 => Contract) public Contracts;
    mapping (uint256 => uint256) public LoanRepaymentAmount;
    mapping (address => uint256[]) ContractIds;

    uint256 public LastMonthlyHandler;
    uint256 public step = 0;
    uint256 public remaining = 0;
    uint256 public PlanHandlerCount = 0;
    bool Paused = false;

    uint256[] public TokenTransferList;
    uint256 public TokenUpdateCount;

    address Owner;

    address NRTManagerAddress;
    NRTManager nrtManager;
    Eraswap EraswapToken;
    Staking   staking;
    LoanAndRefund   loanAndRefund;


    event NRTRecieved(uint256 nrt);
    event ContractBurned(uint256 contractid, uint256 amount);
    event Progress(bytes details, uint256 remaining);
    event StepCompleted(uint256 step);

    modifier OnlyOwner() {
        require(msg.sender == Owner, "Owner TimeAlly should be calling");
        _;
    }

    modifier NotPaused() {
        require(Paused == false, "Should not be Paused");
        _;
    }


    constructor(address eraswapTokenAddress) public{
    EraswapToken = Eraswap(eraswapTokenAddress);
    LastMonthlyHandler = now;
    Owner = msg.sender;
    }

  function Setaddress(address stakingaddress, address loanandrefundaddress) public OnlyOwner() returns(bool){
      staking = Staking(stakingaddress);
      loanAndRefund = LoanAndRefund(loanandrefundaddress);
      return true;
  }

  function AddToTransferList(uint256[] memory list) internal returns(bool) {
      for (uint256 i = 0; i < list.length; i++) {
          TokenTransferList.push(list[i]);
      }
      return true;
  }

  function MonthlyMasterHandler(uint256 size) external OnlyOwner() returns(bool){
      require(now.sub(LastMonthlyHandler)> 30 days);
      require(now.sub(nrtManager.LastNRTRelease())< 30 days);
      Paused = true;
      if(step == 0){
          
          uint256 NRT = nrtManager.TimeAllyNRT();
          uint256 luckPoolBal = staking.MonthlyNRTHandler(NRT, PlanID);
          if(luckPoolBal != 0){
            require(EraswapToken.approve(NRTManagerAddress, luckPoolBal));
            require(nrtManager.UpdateLuckpool(luckPoolBal));
          }
          emit NRTRecieved(NRT);
          emit Progress("Step (0/5): TimeAlly NRT Distribution", remaining);
        
      }
      else if(step == 1){
          
          uint256[] memory RefundList;
          (RefundList, remaining) = loanAndRefund.MonthlyRefundHandler(size);
          AddToTransferList(RefundList); 
          emit Progress("Step (1/5): TimeAlly Refund Management. Remaining =", remaining);
            
      }
      else if(step == 2){
      
          uint256[] memory LoanList;
          (LoanList, remaining) = loanAndRefund.MonthlyLoanHandler(size);
          for (uint256 i = 0; i < LoanList.length; i++) {
              uint256 contractID = LoanList[i];
              uint256 amount = staking.ViewStakedAmount(contractID);
              require(EraswapToken.approve(NRTManagerAddress, amount));
              require(nrtManager.UpdateBurnBal(amount));
              Contracts[contractID].status = 4;
              emit ContractBurned(contractID, amount);
          }    
          emit Progress("Step (2/5): TimeAlly Loan Management. Remaining =", remaining);
      }

      else if(step == 3){
      
          require(PlanHandlerCount <= PlanID);
          uint256[] memory InterestList;
          (InterestList, remaining) = staking.MonthlyPlanHandler(PlanHandlerCount, size);
          AddToTransferList(InterestList);
          if(remaining == 0 && PlanHandlerCount == PlanID){
              PlanHandlerCount = 0;
          }            
          else if(remaining == 0) {
              emit Progress("Step (3/4): PlanHandler completed for the Plan =", PlanHandlerCount);
              PlanHandlerCount++;
              remaining++;
          }
          else {
              emit Progress("Step (3/4): PlanHandler processing. Remaining =", remaining);
          }
            
      }
      else if(step == 4){
          
          remaining = MonthlyPaymentHandler(size);
          emit Progress("Step (4/4): TimeAlly Refund Management. Remaining =", remaining);
          
      }

      if(remaining == 0){
          emit StepCompleted(step);
          step++;
          if(step == 5) {
              step = 0; 
              LastMonthlyHandler = LastMonthlyHandler.add(30 days);
              Paused = false;
          }
      }
      return true;
  }



  function MonthlyPaymentHandler(uint256 size) internal returns (uint){
      uint256 contractID;
      uint256 value;
      address to;
      uint256 i;
      if(TokenUpdateCount == 0) {
          i = TokenTransferList.length;
      }
      else {
          i = TokenUpdateCount;
      }
      if(i.sub(size) > 0){
          size = i.sub(size);
          TokenUpdateCount = size;
      }
      else{
          size = 0;
          TokenUpdateCount = 0;
      }
      while (i > size) {
          i = i.sub(1);    
          contractID = uint256(TokenTransferList[i]);
          value = uint256(uint128(TokenTransferList[i]>>128));
          to = Contracts[contractID].owner;
          require(EraswapToken.transfer(to, value));
          TokenTransferList.pop();
      }
      return(size);
    }


}

