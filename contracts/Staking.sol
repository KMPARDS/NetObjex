pragma solidity ^0.5.2;

import "./SafeMath.sol";

contract Staking{

    using SafeMath for uint256;

    struct Plan{                         //Structure to store details of different Plans
        uint128 NRTBalance;
        uint128 activePlanAmount;
        uint128 lastPlanAmount;
        uint128 updateCount;
        uint32[] activePlanList;
    }
    mapping (uint256 => Plan) public plans;     //orderid ==> order details

    struct Stake {
        uint128 stakedAmount;
        uint32 planTime;
        uint32 monthCount;
        uint32 activePlanListIndex;
        uint32[24] monthlyPrincipal;
    }
    mapping (uint256 => Stake) public stakes;     //orderid ==> order details
    address timeAlly;


    event TotalPlanAmount(uint256 amount);
    event PlanAmountandNRT(uint256 planid, uint256 activeplanamount, uint256 nrtbalance);
    event PrincipalReleased(uint256 contractid, uint32 term ,uint256 amount);
    event InterestReleased(uint256 contractid, uint32 month ,uint256 interest);
    event PlanHandlerStatus(uint256 planid, uint256 current, uint256 total);

    modifier OnlyTimeAlly() {
        require(msg.sender == timeAlly, "Owner TimeAlly should be calling");
        _;
    }

    constructor(address timeally) public {
    timeAlly = timeally;
    }

    function ViewStake(uint256 contractID) public OnlyTimeAlly() view returns(uint256, uint256, uint256){
        return(uint256(stakes[contractID].planTime), uint256(stakes[contractID].stakedAmount), uint256(stakes[contractID].monthCount));
    }

    function ViewStakedAmount(uint256 contractID) public OnlyTimeAlly() view returns(uint256){
        return(uint256(stakes[contractID].stakedAmount));
    }

    function AddStake(uint256 planID, uint256 contractID, uint256 plantime, uint256 stakedamount) public OnlyTimeAlly() returns(bool) {
        Stake memory stake;
        stake.planTime = uint32(plantime);
        stake.stakedAmount = uint128(stakedamount);
        stake.monthCount = 0;
        stake.activePlanListIndex = uint32(plans[planID].activePlanList.push(uint32(contractID)).sub(1));
        stake.monthlyPrincipal[0] = uint32(stakedamount);
        stakes[contractID] = stake;
        plans[planID].activePlanAmount = uint128(uint256(plans[planID].activePlanAmount).add(stakedamount));
        return true;
    }

    function BatchAddStake(uint256 size, uint256 planID, uint256 contractID, uint256 plantime, uint256[] memory stakedamount) public OnlyTimeAlly() returns(bool) {
        for(uint256 i = 0; i < size; i++) {
        require(AddStake(planID, contractID.add(i), plantime, stakedamount[i]));
        }
        return true;
    }

    function Pause(uint256 planID, uint256 contractID) public OnlyTimeAlly() returns(bool) {
        DeleteActivePlanListElement(planID, stakes[contractID].activePlanListIndex);
        plans[planID].activePlanAmount = uint128(uint256(plans[planID].activePlanAmount).sub(uint256(stakes[contractID].stakedAmount)));
        return true;
    }

    function Resume(uint256 planID, uint256 contractID) public OnlyTimeAlly() returns(bool) {
        require(stakes[contractID].activePlanListIndex == 0);
        stakes[contractID].activePlanListIndex = uint32(plans[planID].activePlanList.push(uint32(contractID)).sub(1));
        plans[planID].activePlanAmount = uint128(uint256(plans[planID].activePlanAmount).add(stakes[contractID].stakedAmount));
        return true;
    }



    function MonthlyNRTHandler(uint256 NRT, uint256 planID) public OnlyTimeAlly() returns(uint256){
        uint256 TotalAmount;
        uint256 i;
        for(i=0; i<=planID; i++){
            TotalAmount = TotalAmount.add(uint256(plans[i].activePlanAmount));
        }
        emit TotalPlanAmount(TotalAmount);
        require(TotalAmount > 0);

        for( i=0; i<=planID; i++){
            if(plans[i].activePlanAmount == 0){
                plans[i].NRTBalance = 0;
            }
            else{
                plans[i].NRTBalance = uint128((uint256(plans[i].activePlanAmount).mul(NRT)).div(TotalAmount));
                plans[i].lastPlanAmount = plans[i].activePlanAmount;
            }
            emit PlanAmountandNRT(i, uint256(plans[i].activePlanAmount), uint256(plans[i].NRTBalance));
        }   

        uint256 luckPoolBal = (uint256(plans[0].NRTBalance).mul(2)).div(15);
        if(luckPoolBal != 0){
            plans[0].NRTBalance = uint128(uint256(plans[0].NRTBalance).sub(luckPoolBal));
        }
        emit PlanAmountandNRT(0, uint256(plans[0].activePlanAmount), uint256(plans[0].NRTBalance));
        return luckPoolBal;
    }


    function MonthlyPlanHandler(uint256 planID, uint256 size) public OnlyTimeAlly() returns(uint[] memory, uint){
        require(plans[planID].activePlanList.length > plans[planID].updateCount);
        Plan memory plan = plans[planID];
        Stake memory stake;
        uint256 contractid;
        uint256 Index;
        uint256 Interest;
        uint256 PrincipalToRelease;
        uint256[] memory UserPayment;
        uint256 i = uint256(plan.updateCount);
        if(i.add(size) >= plan.activePlanList.length){
          size = plan.activePlanList.length;
          plan.updateCount =  0;
        }
        else{
          size = i.add(size);
          plan.updateCount =  uint128(size);
        }
        while ( i < size) {
            contractid = uint256(plan.activePlanList[i]);
            stake = stakes[contractid];
            Index = uint256(stake.monthCount % stake.planTime);
            Interest = uint256(stake.stakedAmount * plan.NRTBalance).div(uint256(plan.lastPlanAmount * 2));
            emit InterestReleased(contractid, stake.monthCount, Interest);
            PrincipalToRelease = 0;
            if(stake.monthCount > (uint256(stake.planTime).sub(1))){
                PrincipalToRelease = uint256(stake.monthlyPrincipal[Index]);
                emit PrincipalReleased(contractid, stake.monthCount, PrincipalToRelease);
            }
            plan.activePlanAmount = uint128((uint256(plan.activePlanAmount).add(Interest)).sub(PrincipalToRelease));
            stake.stakedAmount = uint128((uint256(stake.stakedAmount).add(Interest)).sub(PrincipalToRelease));
            stake.monthlyPrincipal[Index] = uint32(Interest);
            stake.monthCount++;
            Index = contractid;
            Index |= (Interest + PrincipalToRelease)<<128;
            UserPayment[UserPayment.length] = Index;
            stakes[contractid] = stake;
            i++;
          }
        emit PlanHandlerStatus(planID, size, plan.activePlanList.length);
        plans[planID] = plan;
        return(UserPayment, (plan.activePlanList.length).sub(size));
    }



    function DeleteActivePlanListElement(uint256 id, uint32 index) internal returns(bool){
        require(plans[id].activePlanAmount != 0);
        require(index < plans[id].activePlanList.length);
        uint256 last = plans[id].activePlanList.length.sub(1);
        uint32 lastelem = plans[id].activePlanList[last];
        stakes[lastelem].activePlanListIndex = index;
        plans[id].activePlanList[index] = plans[id].activePlanList[last];
        plans[id].activePlanList.pop;
        return true;
    }


}

