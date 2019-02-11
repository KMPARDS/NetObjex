pragma solidity ^0.4.24;

import "./SafeMath.sol";


contract Staking{

  using SafeMath for uint256;

  struct Plan{                         //Structure to store details of different Plans
  uint128 NRTBalance;
  uint128 ActivePlanAmount;
  uint128 LastPlanAmount;
  uint128 UpdateCount;
  uint32[] ActivePlanList;
  }
  mapping (uint256 => Plan) public Plans;     //orderid ==> order details
  mapping (uint256 => bool) public Status;

  struct Stake {
  uint128 stakedAmount;
  uint32 PlanTime;
  uint32 monthcount;
  uint32 ActivePlanListIndex;
  uint32[24] MonthlyPrincipal;
  }
  mapping (uint256 => Stake) public Stakes;     //orderid ==> order details
  address TimeAlly;


   event TotalPlanAmount(uint256 amount);
   event PlanAmountandNRT(uint256 planid, uint256 activeplanamount, uint256 nrtbalance);
   event PrincipalReleased(uint256 contractid, uint32 term ,uint256 amount);
   event InterestReleased(uint256 contractid, uint32 month ,uint256 interest);
   event PlanHandlerStatus(uint256 planid, uint256 current, uint256 total);

   modifier OnlyTimeAlly() {
     require(msg.sender == TimeAlly, "Owner TimeAlly should be calling");
     _;
   }

   constructor(address timeally) public {
     TimeAlly = timeally;
   }

  function ViewStake(uint256 contractID) public OnlyTimeAlly() view returns(uint256, uint256, uint256){
   return(uint256(Stakes[contractID].PlanTime), uint256(Stakes[contractID].stakedAmount), uint256(Stakes[contractID].monthcount));
  }

  function ViewStakedAmount(uint256 contractID) public OnlyTimeAlly() view returns(uint256){
   return(uint256(Stakes[contractID].stakedAmount));
  }

  function AddStake(uint256 planID, uint256 contractID, uint256 plantime, uint256 stakedamount) public OnlyTimeAlly() returns(bool) {
  Stake memory stake;
  stake.PlanTime = uint32(plantime);
  stake.stakedAmount = uint128(stakedamount);
  stake.monthcount = 0;
  stake.ActivePlanListIndex = uint32(Plans[planID].ActivePlanList.push(uint32(contractID)).sub(1));
  stake.MonthlyPrincipal[0] = uint32(stakedamount);
  Stakes[contractID] = stake;
  Plans[planID].ActivePlanAmount = uint128(uint256(Plans[planID].ActivePlanAmount).add(stakedamount));
  return true;
  }

  function BatchAddStake(uint256 size, uint256 planID, uint256 contractID, uint256 plantime, uint256[] stakedamount) public OnlyTimeAlly() returns(bool) {
    for(uint256 i = 0; i < size; i++) {
    require(AddStake(planID, (contractID+i), plantime, stakedamount[i]));
    }
    return true;
  }

  function Pause(uint256 planID, uint256 contractID) public OnlyTimeAlly() returns(bool) {
  DeleteActivePlanListElement(planID, Stakes[contractID].ActivePlanListIndex);
  Plans[planID].ActivePlanAmount = uint128(uint256(Plans[planID].ActivePlanAmount).sub(uint256(Stakes[contractID].stakedAmount)));
  return true;
  }

  function Resume(uint256 planID, uint256 contractID) public OnlyTimeAlly() returns(bool) {
  require(Stakes[contractID].ActivePlanListIndex == 0);
  Stakes[contractID].ActivePlanListIndex = uint32(Plans[planID].ActivePlanList.push(uint32(contractID)).sub(1));
  Plans[planID].ActivePlanAmount = uint128(uint256(Plans[planID].ActivePlanAmount).add(Stakes[contractID].stakedAmount));
  return true;
  }



  function MonthlyNRTHandler(uint256 NRT, uint256 planID) public OnlyTimeAlly() returns(uint256){
  uint256 TotalAmount;
  for(uint i=0; i<=planID; i++){
    TotalAmount = TotalAmount.add(uint256(Plans[i].ActivePlanAmount));
  }
  emit TotalPlanAmount(TotalAmount);
  require(TotalAmount > 0);

  for( i=0; i<=planID; i++){
      if(Plans[i].ActivePlanAmount == 0){
        Plans[i].NRTBalance = 0;
      }
      else{
        Plans[i].NRTBalance = uint128((uint256(Plans[i].ActivePlanAmount).mul(NRT)).div(TotalAmount));
        Plans[i].LastPlanAmount = Plans[i].ActivePlanAmount;
      }
      emit PlanAmountandNRT(i, uint256(Plans[i].ActivePlanAmount), uint256(Plans[i].NRTBalance));
  }

  uint256 luckPoolBal = (uint256(Plans[0].NRTBalance).mul(2)).div(15);
  if(luckPoolBal != 0){
    Plans[0].NRTBalance = uint128(uint256(Plans[0].NRTBalance).sub(luckPoolBal));
  }
  emit PlanAmountandNRT(0, uint256(Plans[0].ActivePlanAmount), uint256(Plans[0].NRTBalance));
  return luckPoolBal;
  }


  function MonthlyPlanHandler(uint256 planID, uint256 size) public OnlyTimeAlly() returns(uint[], bool){
    require(Status[planID] == false);
    Plan memory plan = Plans[planID];
    Stake memory stake;
    uint256 contractid;
    uint256 Index;
    uint256 Interest;
    uint256 PrincipalToRelease;
    uint256[] UserPayment;
    uint256 limit;
    if(plan.UpdateCount + size >= plan.ActivePlanList.length){
    limit = plan.ActivePlanList.length;
    Status[planID] = true;
    }
    else{
    limit = plan.UpdateCount+size;
    }
    for (uint256 i = plan.UpdateCount; i < limit; i++) {
         contractid = uint256(plan.ActivePlanList[i]);
         stake = Stakes[contractid];
         Index = uint256(stake.monthcount % stake.PlanTime);
         Interest = uint256(stake.stakedAmount * plan.NRTBalance).div(uint256(plan.LastPlanAmount * 2));
         emit InterestReleased(contractid, stake.monthcount, Interest);
         PrincipalToRelease = 0;
         if(stake.monthcount >((stake.PlanTime)-1)){
           PrincipalToRelease = uint256(stake.MonthlyPrincipal[Index]);
           emit PrincipalReleased(contractid, stake.monthcount, PrincipalToRelease);
         }
         plan.ActivePlanAmount = uint128((uint256(plan.ActivePlanAmount).add(Interest)).sub(PrincipalToRelease));
         stake.stakedAmount = uint128((uint256(stake.stakedAmount).add(Interest)).sub(PrincipalToRelease));
         stake.MonthlyPrincipal[Index] = uint32(Interest);
         stake.monthcount++;
         Index = contractid;
         Index |= (Interest + PrincipalToRelease)<<128;
         UserPayment.push(Index);
         Stakes[contractid] = stake;
       }
  plan.UpdateCount =  uint128(limit);
  emit PlanHandlerStatus(planID, plan.UpdateCount, plan.ActivePlanList.length);
  Plans[planID] = plan;
  return(UserPayment, Status[planID]);
  }



  function DeleteActivePlanListElement(uint256 id, uint32 index) internal returns(bool){
    require(Plans[id].ActivePlanAmount != 0);
    require(index < Plans[id].ActivePlanList.length);
    uint256 last = Plans[id].ActivePlanList.length - 1;
    uint32 lastelem = Plans[id].ActivePlanList[last];
    Stakes[lastelem].ActivePlanListIndex = index;
    Plans[id].ActivePlanList[index] = Plans[id].ActivePlanList[last];
    delete Plans[id].ActivePlanList[last];
    Plans[id].ActivePlanList.length--;
    return true;
  }


}
