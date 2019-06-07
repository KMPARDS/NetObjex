pragma solidity ^0.5.2;

import "./Staking.sol";
import "./LoanAndRefund.sol";
import "./Eraswap.sol";
import "./NRTManager.sol";


contract TimeAllyCore {

    using SafeMath for uint256;

    struct TimeAllyPlan {                         //Structure to store details of different Plans
        uint256 planPeriod;
        uint256 loanInterestRate;
        uint256 loanPeriod;
        uint256 refundWeeks;
    }

    struct Contract {
        uint256 status;
        uint256 planid;
        address owner;
        uint256 timestamp;
    }

    uint256 public planID = 0;
    mapping(uint256 => TimeAllyPlan) public plans;
    uint256 public contractID = 0;
    mapping (uint256 => Contract) public contracts;
    mapping (uint256 => uint256) public loanRepaymentAmount;
    mapping(address => uint256[]) public contractIds;

    uint256 public lastMonthlyHandler;
    uint256 public step = 0;
    uint256 public remaining = 0;
    uint256 public planHandlerCount = 0;
    bool public paused = false;

    uint256[] public tokenTransferList;
    uint256 public tokenUpdateCount;

    address public owner;

    address public nrtManagerAddress;
    NRTManager public nrtManager;
    Eraswap public eraswapToken;
    Staking public staking;
    LoanAndRefund public loanAndRefund;


    event NRTRecieved(uint256 nrt);
    event ContractBurned(uint256 contractid, uint256 amount);
    event Progress(bytes details, uint256 remaining);
    event StepCompleted(uint256 step);

    modifier onlyOwner() {
        require(msg.sender == owner, "owner TimeAlly should be calling");
        _;
    }

    modifier notPaused() {
        require(paused == false, "Should not be paused");
        _;
    }

    constructor(address eraswapTokenAddress)
    public {
        eraswapToken = Eraswap(eraswapTokenAddress);
        lastMonthlyHandler = now;
        owner = msg.sender;
    }
    
    function setaddress(
        address stakingaddress,
        address loanandrefundaddress
    )
    external
    onlyOwner()
    returns(bool)
    {
        staking = Staking(stakingaddress);
        loanAndRefund = LoanAndRefund(loanandrefundaddress);
        return true;
    }

    function monthlyMasterHandler(uint256 size)
    external
    onlyOwner()
    returns(bool)
    {
        require(now.sub(lastMonthlyHandler) > 30 days);
        require(now.sub(nrtManager.LastNRTRelease()) < 30 days);
        paused = true;
        if (step == 0) {
            uint256 nrt = nrtManager.TimeAllyNRT();
            uint256 luckPoolBal = staking.MonthlyNRTHandler(nrt, planID);
            if (luckPoolBal != 0) {
                require(eraswapToken.approve(nrtManagerAddress, luckPoolBal));
                require(nrtManager.UpdateLuckpool(luckPoolBal));
            }
            emit NRTRecieved(nrt);
            emit Progress("Step (0/5): TimeAlly nrt Distribution", remaining);
        }else if (step == 1) {
            uint256[] memory refundList;
            (refundList, remaining) = loanAndRefund.MonthlyRefundHandler(size);
            addToTransferList(refundList);
            emit Progress("Step (1/5): TimeAlly Refund Management. Remaining =", remaining);
        }else if (step == 2) {
            uint256[] memory loanList;
            (loanList, remaining) = loanAndRefund.MonthlyLoanHandler(size);
            for (uint256 i = 0; i < loanList.length; i++) {
                uint256 contractID = loanList[i];
                uint256 amount = staking.ViewStakedAmount(contractID);
                require(eraswapToken.approve(nrtManagerAddress, amount));
                require(nrtManager.UpdateBurnBal(amount));
                contracts[contractID].status = 4;
                emit ContractBurned(contractID, amount);
            }
            emit Progress("Step (2/5): TimeAlly Loan Management. Remaining =", remaining);
        } else if (step == 3) {
            require(planHandlerCount <= planID);
            uint256[] memory interestList;
            (interestList, remaining) = staking.MonthlyPlanHandler(planHandlerCount, size);
            addToTransferList(interestList);
            if (remaining == 0 && planHandlerCount == planID) {
                planHandlerCount = 0;
            }else if (remaining == 0) {
                emit Progress("Step (3/4): PlanHandler completed for the Plan =", planHandlerCount);
                planHandlerCount++;
                remaining++;
            }else {
                emit Progress("Step (3/4): PlanHandler processing. Remaining =", remaining);
            }
        }else if (step == 4) {
            remaining = monthlyPaymentHandler(size);
            emit Progress("Step (4/4): TimeAlly Refund Management. Remaining =", remaining);
        }
        if (remaining == 0) {
            emit StepCompleted(step);
            step++;
            if (step == 5) {
                step = 0;
                lastMonthlyHandler = lastMonthlyHandler.add(30 days);
                paused = false;
            }
        }
        return true;
    }

    function monthlyPaymentHandler(uint256 size)
    internal
    returns
    (uint)
    {
        uint256 contractID;
        uint256 value;
        address to;
        uint256 i;
        if (tokenUpdateCount == 0) {
            i = tokenTransferList.length;
        }else {
            i = tokenUpdateCount;
        }
        if (i.sub(size) > 0) {
            size = i.sub(size);
            tokenUpdateCount = size;
        }  else {
            size = 0;
            tokenUpdateCount = 0;
        }
        while (i > size) {
            i = i.sub(1);
            contractID = uint256(tokenTransferList[i]);
            value = uint256(uint128(tokenTransferList[i]>>128));
            to = contracts[contractID].owner;
            require(eraswapToken.transfer(to, value));
            tokenTransferList.pop();
        }
        return(size);
    }

    function addToTransferList(
        uint256[] memory list)
        internal
        returns(bool)
        {
        for (uint256 i = 0; i < list.length; i++) {
            tokenTransferList.push(list[i]);
        }
        return true;
    }



}
