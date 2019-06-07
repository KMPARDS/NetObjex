pragma solidity ^0.5.2;

import "./SafeMath.sol";


contract Staking {

    using SafeMath for uint256;

    struct Plan {                         //Structure to store details of different Plans
        uint128 nrtBalance;
        uint128 activePlanAmount;
        uint128 lastPlanAmount;
        uint128 updateCount;
        uint32[] activePlanList;
    }

    struct Stake {
        uint128 stakedAmount;
        uint32 planTime;
        uint32 monthCount;
        uint32 activePlanListIndex;
        uint32[24] monthlyPrincipal;
    }

    mapping(uint256 => Plan) public plans;     //orderid ==> order details
    mapping (uint256 => Stake) public stakes;     //orderid ==> order details
    address public timeAlly;


    event TotalPlanAmount(uint256 amount);
    event PlanAmountandNRT(uint256 indexed planid, uint256 activeplanamount, uint256 nrtbalance);
    event PrincipalReleased(uint256 indexed contractid, uint32 term, uint256 amount);
    event InterestReleased(uint256 indexed contractid, uint32 month, uint256 interest);
    event PlanHandlerStatus(uint256 indexed planid, uint256 current, uint256 total);

    modifier onlyTimeAlly() {
        require(msg.sender == timeAlly, "Owner TimeAlly should be calling");
        _;
    }

    constructor(address timeally) public {
        timeAlly = timeally;
    }

    function viewStake(uint256 contractID)
        public
        onlyTimeAlly()
        view
        returns(
            uint256,
            uint256,
            uint256
            )
    {
        return(
            uint256(stakes[contractID].planTime),
            uint256(stakes[contractID].stakedAmount),
            uint256(stakes[contractID].monthCount)
            );
    }

    function viewStakedAmount(uint256 contractID)
        public
        onlyTimeAlly()
        view
        returns(uint256)
    {
        return(uint256(stakes[contractID].stakedAmount));
    }

    function addStake(
        uint256 planID,
        uint256 contractID,
        uint256 plantime,
        uint256 stakedamount
        )
        public
        onlyTimeAlly()
        returns(bool) {
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

    function batchAddStake(
            uint256 size,
            uint256 planID,
            uint256 contractID,
            uint256 plantime,
            uint256[] memory stakedamount
            )
            public
            onlyTimeAlly()
            returns(bool)
        {
        for (uint256 i = 0; i < size; i++) {
            require(addStake(planID, contractID.add(i), plantime, stakedamount[i]));
        }
        return true;
    }

    function pause(
            uint256 planID,
            uint256 contractID
            )
            public
            onlyTimeAlly()
            returns(bool)
    {
        deleteActivePlanListElement(planID,
                                    stakes[contractID].activePlanListIndex);
        plans[planID].activePlanAmount = uint128(uint256(plans[planID].activePlanAmount)
                                                        .sub(uint256(stakes[contractID].stakedAmount)));
        return true;
    }

    function resume(
            uint256 planID,
            uint256 contractID
            )
            public
            onlyTimeAlly()
            returns(bool)
    {
        require(stakes[contractID].activePlanListIndex == 0);
        stakes[contractID].activePlanListIndex = uint32(plans[planID].activePlanList
                                                        .push(uint32(contractID)).sub(1));
        plans[planID].activePlanAmount = uint128(uint256(plans[planID].activePlanAmount)
                                                        .add(stakes[contractID].stakedAmount));
        return true;
    }

    function monthlyNRTHandler(
            uint256 nrt,
            uint256 planID)
            public
            onlyTimeAlly()
            returns(uint256)
    {
        uint256 totalAmount;
        uint256 i;
        for (i = 0; i <= planID; i++) {
            totalAmount = totalAmount.add(uint256(plans[i].activePlanAmount));
        }
        emit TotalPlanAmount(totalAmount);
        require(totalAmount > 0);

        for (i = 0; i <= planID; i++) {
            if (plans[i].activePlanAmount == 0) {
                plans[i].nrtBalance = 0;
            }else {
                plans[i].nrtBalance = uint128((uint256(plans[i].activePlanAmount).mul(nrt)).div(totalAmount));
                plans[i].lastPlanAmount = plans[i].activePlanAmount;
            }
            emit PlanAmountandNRT(i, uint256(plans[i].activePlanAmount), uint256(plans[i].nrtBalance));
        }

        uint256 luckPoolBal = (uint256(plans[0].nrtBalance).mul(2)).div(15);
        if (luckPoolBal != 0) {
            plans[0].nrtBalance = uint128(uint256(plans[0].nrtBalance).sub(luckPoolBal));
        }
        emit PlanAmountandNRT(0, uint256(plans[0].activePlanAmount), uint256(plans[0].nrtBalance));
        return luckPoolBal;
    }

    function monthlyPlanHandler(
            uint256 planID,
            uint256 size)
            public
            onlyTimeAlly()
            returns(
            uint[] memory,
            uint)
    {
        require(plans[planID].activePlanList.length > plans[planID].updateCount);
        Plan memory plan = plans[planID];
        Stake memory stake;
        uint256 contractid;
        uint256 index;
        uint256 interest;
        uint256 principalToRelease;
        uint256[] memory userPayment;
        uint256 i = uint256(plan.updateCount);
        if (i.add(size) >= plan.activePlanList.length) {
            size = plan.activePlanList.length;
            plan.updateCount = 0;
        }else {
            size = i.add(size);
            plan.updateCount = uint128(size);
        }
        while (i < size) {
            contractid = uint256(plan.activePlanList[i]);
            stake = stakes[contractid];
            index = uint256(stake.monthCount % stake.planTime);
            interest = uint256(stake.stakedAmount * plan.nrtBalance).div(uint256(plan.lastPlanAmount * 2));
            emit InterestReleased(contractid, stake.monthCount, interest);
            principalToRelease = 0;
            if (stake.monthCount > (uint256(stake.planTime).sub(1))) {
                principalToRelease = uint256(stake.monthlyPrincipal[index]);
                emit PrincipalReleased(contractid, stake.monthCount, principalToRelease);
            }
            plan.activePlanAmount = uint128((uint256(plan.activePlanAmount).add(interest)).sub(principalToRelease));
            stake.stakedAmount = uint128((uint256(stake.stakedAmount).add(interest)).sub(principalToRelease));
            stake.monthlyPrincipal[index] = uint32(interest);
            stake.monthCount++;
            index = contractid;
            index |= (interest + principalToRelease)<<128;
            userPayment[userPayment.length] = index;
            stakes[contractid] = stake;
            i++;
        }
        emit PlanHandlerStatus(planID, size, plan.activePlanList.length);
        plans[planID] = plan;
        return(userPayment, (plan.activePlanList.length).sub(size));
    }

    function deleteActivePlanListElement(
            uint256 id,
            uint32 index
            )
            internal
            returns(bool)
        {
        require(plans[id].activePlanAmount != 0);
        require(index < plans[id].activePlanList.length);
        uint256 last = plans[id].activePlanList.length.sub(1);
        uint32 lastelem = plans[id].activePlanList[last];
        stakes[lastelem].activePlanListIndex = index;
        plans[id].activePlanList[index] = plans[id].activePlanList[last];
        plans[id].activePlanList.length--;
        return true;
    }
}
