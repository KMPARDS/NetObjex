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
    modifier canBeWindedUp(uint256 contractid) {
        require(((now.sub(contracts[contractid].timestamp)) >= plans[contracts[contractid].planid].planPeriod),
            "Contract can only be ended after 2 years");
        require(contracts[contractid].status == 1);
        _;
    }

    /**
    * @dev Modifier
    */
    modifier loanCanBeTaken(uint256 contractid) {
        require(contracts[contractid].status == 1, "Loan should not be present");
        _;
    }

    /**
    * @dev Modifier
    */
    modifier loanCanBeRepayed(uint256 contractid) {
        require(contracts[contractid].status == 2, "Loan should not be present");
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
    function windUpContract(uint256 contractid)
            external
            onlyContractOwner(contractid)
            canBeWindedUp(contractid)
            returns(bool) {
                require(staking.pause(contracts[contractid].planid, contractid));
                contracts[contractid].status = 3;
                uint256 refundAmount = (staking.viewStakedAmount(contractid))
                                            .div(plans[contracts[contractid].planid].refundWeeks);
                require(loanAndRefund.addRefund(contractid,
                                                uint32(plans[contracts[contractid].planid].refundWeeks),
                                                0,
                                                uint64(refundAmount)));
                emit WindupInitiated(contractid,
                                        contracts[contractid].owner,
                                        staking.viewStakedAmount(contractid),
                                        contracts[contractid].planid);
                return true;
            }

  /**
  * @dev Function
  */
    function takeLoan(
            uint256 contractid,
            uint256 loanamount
            )
            external
            onlyContractOwner(contractid)
            loanCanBeTaken(contractid)
            returns(bool) {
                require(loanamount < ((staking.viewStakedAmount(contractid)).div(2)));
                uint256 planid = contracts[contractid].planid;
                uint256 repayamount = loanamount.add((loanamount.mul(plans[planid].loanInterestRate)).div(100));
                require(staking.pause(planid, contractid));
                require(loanAndRefund.addLoan(contractid, uint32(plans[planid].loanPeriod), uint128(loanamount)));
                loanRepaymentAmount[contractid] = repayamount;
                contracts[contractid].status = 2;
                require(eraswapToken.transfer(contracts[contractid].owner, loanamount));
                emit LoanTaken(contractid, contracts[contractid].owner, loanamount, planid);
                return true;
            }

  /**
  * @dev Function
  */
    function rePayLoan(uint256 contractid)
        external
        onlyContractOwner(contractid)
        loanCanBeRepayed(contractid)
        returns(bool) {
            require(eraswapToken.allowance(msg.sender, address(this)) >= loanRepaymentAmount[contractid]);
            require(eraswapToken.transferFrom(msg.sender, address(this), loanRepaymentAmount[contractid]));
            require(loanAndRefund.removeLoan(contractid));
            uint256 planid = contracts[contractid].planid;
            ( , , uint256 amount) = loanAndRefund.viewLoan(contractid);
            uint256 luckPoolBal = loanRepaymentAmount[contractid].sub(amount);
            require(eraswapToken.transfer(nrtManagerAddress, luckPoolBal));
            require(nrtManager.UpdateLuckpool(luckPoolBal));
            require(staking.resume(planid, contractid));
            contracts[contractid].status = 1;
            emit LoanRepayed(contractid, contracts[contractid].owner, amount, luckPoolBal, planid);
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
    function viewContract(uint256 contractid)
        public view
        onlyContractOwner(contractid)
        returns(
            uint256,
            uint256,
            uint256,
            address
            )
    {
        return (
                contracts[contractid].status,
                contracts[contractid].timestamp,
                contracts[contractid].planid,
                contracts[contractid].owner
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
            require(planid <= planID);
            require(eraswapToken.allowance(msg.sender, address(this)) >= stakedamount);
            require(eraswapToken.transferFrom(msg.sender, address(this), stakedamount));
            require(staking.addStake(planid, contractID, plans[planid].planPeriod, stakedamount));
            require(newContract(owner, planid));
            return true;
        }

    function viewUserStakes(uint256 contractid)
        external
        view
        onlyContractOwner(contractid)
        returns(
            uint256,
            uint256,
            uint256) {
            (uint256 a, uint256 b, uint256 c) = staking.viewStake(contractid);
            return (a, b, c);
        }

    function viewUserLoan(uint256 contractid)
        external
        view
        onlyContractOwner(contractid)
        returns(
            uint256,
            uint256,
            uint256)
    {
        (uint256 a, uint256 b, uint256 c) = loanAndRefund.viewLoan(contractid);
        return (a, b, c);
    }

    function viewUserRefund(uint256 contractid)
        external
        view
        onlyContractOwner(contractid)
        returns(
            uint256,
            uint256,
            uint256)
    {
        (uint256 a, uint256 b, uint256 c) = loanAndRefund.viewRefund(contractid);
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
    function planDetails(uint256 planid)
        external
        view
        returns(
            uint256,
            uint256,
            uint256,
            uint256) {
            return(
            plans[planid].loanInterestRate,
            plans[planid].refundWeeks,
            plans[planid].loanPeriod,
            plans[planid].planPeriod
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
            require(planid <= planID);
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
            uint256 planid)
            internal
            returns(bool) {
                Contract memory tempContract;
                tempContract.status = 1;
                tempContract.planid = planid;
                tempContract.owner = contractOwner;
                tempContract.timestamp = now;
                contracts[contractID] = tempContract;
                contractIds[contractOwner].push(contractID);
                emit ContractCreated(contractID, contractOwner, planid);
                contractID = contractID.add(1);
                return true;
            }


}
