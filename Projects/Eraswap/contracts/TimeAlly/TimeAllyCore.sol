pragma solidity ^0.4.24;

import "./SafeMath.sol";
import "./Staking.sol";
import "./LoanAndRefund.sol";
import "../EraswapToken/EraswapToken.sol";

contract TimeAllyCore {

using SafeMath for uint256;

  struct TimeAllyPlan{                         //Structure to store details of different Plans
  uint256 PlanPeriod;
  uint256 LoanInterestRate;
  uint256 LoanPeriod;
  uint256 RefundWeeks;
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
  uint256 public PlanHandlerCount = 0;
  uint256 public MonthlyHandlerCount = 0;
  bool Paused = false;

uint256[] public TokenTransferList;
address Owner;
address public EraswapTokenAddress;
EraswapToken EraswapTokens;
address public StakingAddress;
Staking   staking;
address public LoanandRefundAddress;
LoanAndRefund   loanAndRefund;


event NRTRecieved(uint256 nrt);
event MonthlyPaymentsHandler(address user, uint256 amount);
event ContractBurned(uint256 contractid, uint256 amount);
event PlanHandlercompleted(uint256 id);
event MonthlyPlanHandlerscompleted();
event MonthlyPaymentHandlercompleted();
event TokenSent(address[100], uint256[100]);

modifier OnlyOwner() {
  require(msg.sender == Owner, "Owner TimeAlly should be calling");
  _;
}

modifier NotPaused() {
  require(Paused == false, "SHould not be Paused");
  _;
}


constructor() public{
  LastMonthlyHandler = now;
  Owner = msg.sender;
}

function Setaddress(address stakingaddress, address loanandrefundaddress) public OnlyOwner() returns(bool){
    StakingAddress = stakingaddress;
    staking = Staking(StakingAddress);
    LoanandRefundAddress = loanandrefundaddress;
    loanAndRefund = LoanAndRefund(LoanandRefundAddress);
    return true;
}


function MonthlyMasterHandler() external OnlyOwner() returns(bool){
  require(now.sub(LastMonthlyHandler)> 1 minutes);
  require(now.sub(EraswapTokens.LastNRTRelease())< 2592000);
  require(MonthlyHandlerCount<3);
  Paused = true;
  if(MonthlyHandlerCount == 0){
  uint256 NRT = EraswapTokens.TimeAllyNRT();
  uint256 luckPoolBal = staking.MonthlyNRTHandler(NRT, PlanID);
  if(luckPoolBal != 0){
    require(EraswapTokens.increaseApproval(EraswapTokenAddress, luckPoolBal));
    require(EraswapTokens.UpdateLuckpool(luckPoolBal));
  }
  emit NRTRecieved(NRT);
  MonthlyHandlerCount = 1;
}

  else if(MonthlyHandlerCount == 1){
  uint256[] memory RefundList;
  RefundList = loanAndRefund.MonthlyRefundHandler();
  AddToTransferList(RefundList);
  MonthlyHandlerCount = 2;
}

  else if(MonthlyHandlerCount == 2){
  uint256[] memory LoanList;
  LoanList = loanAndRefund.MonthlyLoanHandler();
  for (uint256 i = 0; i < LoanList.length; i++) {
    uint256 contractID = LoanList[i];
    uint256 amount = staking.ViewStakedAmount(contractID);
    require(EraswapTokens.increaseApproval(EraswapTokenAddress, amount));
    require(EraswapTokens.UpdateBurnBal(amount));
    Contracts[contractID].status = 4;
    emit ContractBurned(contractID, amount);
  }
  MonthlyHandlerCount = 3;
}
}

function MonthlyPlansHandler(uint256 Size) external OnlyOwner() returns(bool){
  require(MonthlyHandlerCount == 3);
  require(PlanHandlerCount <= PlanID);
  uint256[] memory InterestList;
  bool status;
  (InterestList, status) = staking.MonthlyPlanHandler(PlanHandlerCount, Size);
  AddToTransferList(InterestList);
  if(status == true){
  emit PlanHandlercompleted(PlanHandlerCount);
  PlanHandlerCount++;
  }
  if(PlanHandlerCount > PlanID){
  emit MonthlyPlanHandlerscompleted();
  MonthlyHandlerCount = 4;
  PlanHandlerCount = 0;
  }
  return status;
}


function MonthlyPaymentHandler() external OnlyOwner() returns(bool){
require(MonthlyHandlerCount == 4);
uint256[100] paymentlist;
address[100] addresslist;
uint256 contractID;
uint256 amount;
address add;
uint256 start = 0;
uint256 stop = 100;
while(start < TokenTransferList.length){
if((start+100) > TokenTransferList.length)
{
   stop = TokenTransferList.length - start;
   for(i = stop; i<100; i++){
     addresslist[i] = address(0);
     paymentlist[i] = 0;
   }
}
  for (uint256 i = 0; i < stop; i++) {
      contractID = uint256(TokenTransferList[start+i]);
      amount = uint256(uint128(TokenTransferList[start+i]>>128));
      add = Contracts[contractID].owner;
      addresslist[i] = add;
      paymentlist[i] = amount;
  }
  require(EraswapTokens.UpdateBalance(addresslist, paymentlist));
  emit TokenSent(addresslist, paymentlist);
  start = start + 100;
}
emit MonthlyPaymentHandlercompleted();
delete TokenTransferList;
MonthlyHandlerCount = 0;
LastMonthlyHandler = now;
Paused = false;
}


function AddToTransferList(uint256[] list) internal returns(bool) {
  for (uint256 i = 0; i < list.length; i++) {
    TokenTransferList.push(list[i]);
  }
  return true;
}


}
