pragma solidity ^ 0.5.2;

import "./TimeAllyCore.sol";


contract TimeAlly is TimeAllyCore {

    using SafeMath for uint256;

    event ContractCreated(uint256 contractid, address owner, uint256 planid);
    event PlanCreated(uint256 planid);
    event WindupInitiated(uint256 contractid, address owner, uint256 amount, uint256 planid);
    event LoanTaken(uint256 contractid, address owner, uint256 loanamnt, uint256 planid);
    event LoanRepayed(uint256 contractid, address owner, uint256 loanamnt, uint256 interest, uint256 planid);
    event OwnershipTransfered(uint256 contractid, address owner, address newowner);

    modifier onlyContractOwner(uint256 contractid) {
        require(msg.sender == contracts[contractid].owner, "Owner should be calling");
        _;
    }

    /**
    * @dev Modifier
    */
    //todo: this also should check whther the contract have any active loans or not
    modifier canBeWindedUp(uint256 contractID) {
        require(((now.sub(contracts[contractID].timestamp)) >= plans[contracts[contractID].planid].planPeriod),
            "Contract can only be ended after 2 years");
        require(contracts[contractID].status == 1);
        _;
    }

    /**
    * @dev Modifier
    */
    modifier loanCanBeTaken(uint256 contractID) {
        require(contracts[contractID].status == 1, "Loan should not be present");
        _;
    }

    /**
    * @dev Modifier
    */
    modifier loanCanBeRepayed(uint256 contractID) {
        require(contracts[contractID].status == 2, "Loan should not be present");
        _;
    }

    /**
     * @dev Constructor
     */
    constructor (address eraswapTokenAddress, address _nrtManagerAddress)
        public
        TimeAllyCore(eraswapTokenAddress, _nrtManagerAddress) {
        }

  /**
  * @dev Function
  */
    function createPlan(
        uint256 planperiod,
        uint256 loanInterestRate,
        uint256 loanPeriod,
        uint256 refundWeeks
        )
        external
        notPaused()
        onlyOwner()
        returns(bool) {
            TimeAllyPlan memory tempPlan;
            tempPlan.planPeriod = planperiod;
            tempPlan.loanInterestRate = loanInterestRate;
            tempPlan.loanPeriod = loanPeriod;
            tempPlan.refundWeeks = refundWeeks;
            plans[planID] = tempPlan;
            emit PlanCreated(planID);
            planID = planID.add(1);
            return true;
        }

  /**
  * @dev Function
  */
    function windUpContract(uint256 contractID)
            external
            onlyContractOwner(contractID)
            canBeWindedUp(contractID)
            returns(bool) {
                require(staking.pause(contracts[contractID].planid, contractID));
                contracts[contractID].status = 3;
                uint256 refundAmount = (staking.viewStakedAmount(contractID))
                                            .div(plans[contracts[contractID].planid].refundWeeks);
                require(loanAndRefund.addRefund(contractID,
                                                uint32(plans[contracts[contractID].planid].refundWeeks),
                                                0,
                                                uint64(refundAmount)));
                emit WindupInitiated(contractID,
                                        contracts[contractID].owner,
                                        staking.viewStakedAmount(contractID),
                                        contracts[contractID].planid);
                return true;
            }

  /**
  * @dev Function
  */
    function takeLoan(
            uint256 contractID,
            uint256 loanamount
            )
            external
            onlyContractOwner(contractID)
            loanCanBeTaken(contractID)
            returns(bool) {
                require(loanamount < ((staking.viewStakedAmount(contractID)).div(2)));
                uint256 planid = contracts[contractID].planid;
                uint256 repayamount = loanamount.add((loanamount.mul(plans[planid].loanInterestRate)).div(100));
                require(staking.pause(planid, contractID));
                require(loanAndRefund.addLoan(contractID, uint32(plans[planid].loanPeriod), uint128(loanamount)));
                loanRepaymentAmount[contractID] = repayamount;
                contracts[contractID].status = 2;
                require(eraswapToken.transfer(contracts[contractID].owner, loanamount));
                emit LoanTaken(contractID, contracts[contractID].owner, loanamount, planid);
                return true;
            }

  /**
  * @dev Function
  */
    function rePayLoan(uint256 contractID)
        external
        onlyContractOwner(contractID)
        loanCanBeRepayed(contractID)
        returns(bool) {
            require(eraswapToken.allowance(msg.sender, address(this)) >= loanRepaymentAmount[contractID]);
            require(eraswapToken.transferFrom(msg.sender, address(this), loanRepaymentAmount[contractID]));
            require(loanAndRefund.removeLoan(contractID));
            uint256 planid = contracts[contractID].planid;
            (, , uint256 amount) = loanAndRefund.viewLoan(contractID);
            uint256 luckPoolBal = loanRepaymentAmount[contractID].sub(amount);
            require(eraswapToken.approve(nrtManagerAddress, luckPoolBal));
            require(nrtManager.UpdateLuckpool(luckPoolBal));
            require(staking.resume(planid, contractID));
            contracts[contractID].status = 1;
            emit LoanRepayed(contractID, contracts[contractID].owner, amount, luckPoolBal, planid);
            return true;
        }

  /**
   * @dev To Transfer Staking Ownership
   * @return bool true if ownership successfully transffered
   */
    function transferOwnership(
        uint256 contractid,
        address newowner)
        external
        onlyContractOwner(contractid)
        loanCanBeTaken(contractid)
        returns(bool) {
            emit OwnershipTransfered(contractid, contracts[contractid].owner, newowner);
            contracts[contractid].owner = newowner;
            return true;
        }

        /**
        * @dev Function
        */
    function viewContract(uint256 contractID)
        public view
        onlyContractOwner(contractID)
        returns(
            uint256,
            uint256,
            uint256,
            address
            )
    {
        return (
                contracts[contractID].status,
                contracts[contractID].timestamp,
                contracts[contractID].planid,
                contracts[contractID].owner
            );
    }

    /**
     * @dev Function to create a contract
     * @return orderId of created
     */
    function createContract(
        address owner,
        uint256 planid,
        uint256 stakedamount)
        external
        notPaused()
        returns(bool) {
            require(eraswapToken.allowance(msg.sender, address(this)) >= stakedamount);
            require(eraswapToken.transferFrom(msg.sender, address(this), stakedamount));
            require(staking.addStake(planid, contractID, plans[planid].planPeriod, stakedamount));
            require(newContract(owner, planid));
            return true;
        }

    function viewUserStakes(uint256 contractID)
        external
        view
        onlyContractOwner(contractID)
        returns(
            uint256,
            uint256,
            uint256) {
            (uint256 a, uint256 b, uint256 c) = staking.viewStake(contractID);
            return (a, b, c);
        }

    function viewUserLoan(uint256 contractID)
        external
        view
        onlyContractOwner(contractID)
        returns(
            uint256,
            uint256,
            uint256)
    {
        (uint256 a, uint256 b, uint256 c) = loanAndRefund.viewLoan(contractID);
        return (a, b, c);
    }

    function viewUserRefund(uint256 contractID)
        external
        view
        onlyContractOwner(contractID)
        returns(
            uint256,
            uint256,
            uint256)
    {
        (uint256 a, uint256 b, uint256 c) = loanAndRefund.viewRefund(contractID);
        return (a, b, c);
    }

  /**
  * @dev Function
  */
    function allContracts()
        external
        view
        returns(uint256[] memory) {
            return (contractIds[msg.sender]);
        }

  /**
  * @dev Function
  */
    function planDetails(uint256 planID)
        external
        view
        returns(
            uint256,
            uint256,
            uint256,
            uint256) {
            return(
            plans[planID].loanInterestRate,
            plans[planID].refundWeeks,
            plans[planID].loanPeriod,
            plans[planID].planPeriod
            );
        }

  /**
   * @dev To create staking contract by batch
   * @return orderIds of created contracts
   */
    function createContractsByBatch(
        uint256 batchlength,
        uint256 planid,
        address[] memory contractOwner,
        uint256[] memory amount,
        uint256 total)
        public
        notPaused()
        onlyOwner()
        returns(bool) {
            require(eraswapToken.allowance(msg.sender, address(this)) >= total);
            require(eraswapToken.transferFrom(msg.sender, address(this), total));
            require(staking.batchAddStake(batchlength, planid, contractID, plans[planid].planPeriod, amount));
            for (uint i = 0; i < batchlength; i++) {
                require(newContract(contractOwner[i], planid));
            }
            return true;
        }

    function newContract(
            address contractOwner,
            uint256 planID)
            internal
            returns(bool) {
                Contract memory tempContract;
                tempContract.status = 1;
                tempContract.planid = planID;
                tempContract.owner = contractOwner;
                tempContract.timestamp = now;
                contracts[contractID] = tempContract;
                contractIds[contractOwner].push(contractID);
                emit ContractCreated(contractID, contractOwner, planID);
                contractID = contractID.add(1);
            }


}

