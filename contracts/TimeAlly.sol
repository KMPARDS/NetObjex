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
        require(msg.sender == Contracts[contractid].owner, "Owner should be calling");
        _;
    }

    /**
    * @dev Modifier
    */
    //todo: this also should check whther the contract have any active loans or not
    modifier canBeWindedUp(uint256 contractID) {
        require(((now.sub(Contracts[contractID].timestamp)) >= Plans[Contracts[contractID].planid].PlanPeriod),
            "Contract can only be ended after 2 years");
        require(Contracts[contractID].status == 1);
        _;
    }

    /**
    * @dev Modifier
    */
    modifier loanCanBeTaken(uint256 contractID) {
        require(Contracts[contractID].status == 1, "Loan should not be present");
        _;
    }

    /**
    * @dev Modifier
    */
    modifier loanCanBeRepayed(uint256 contractID) {
        require(Contracts[contractID].status == 2, "Loan should not be present");
        _;
    }

    /**
     * @dev Constructor
     */
    constructor (address eraswapTokenAddress)
        public
        TimeAllyCore(eraswapTokenAddress) {
        }
        
    /**
    * @dev Function
    */
    function viewContract(uint256 contractID)
        public
        view
        onlyContractOwner(contractID)
        returns(
            uint256,
            uint256,
            uint256,
            address
            )
    {
        return (
                Contracts[ContractID].status,
                Contracts[ContractID].timestamp,
                Contracts[ContractID].planid,
                Contracts[ContractID].owner
            );
    }

    function viewUserStakes(uint256 contractID)
        public
        view
        onlyContractOwner(contractID)
        returns(
            uint256,
            uint256,
            uint256) {
            (uint256 a, uint256 b, uint256 c) = staking.ViewStake(contractID);
            return (a, b, c);
        }

    function viewUserLoan(uint256 contractID)
        public
        view
        onlyContractOwner(contractID)
        returns(
            uint256,
            uint256,
            uint256)
    {
        (uint256 a, uint256 b, uint256 c) = loanAndRefund.ViewLoan(contractID);
        return (a, b, c);
    }

    function viewUserRefund(uint256 contractID)
        public
        view
        onlyContractOwner(contractID)
        returns(
            uint256,
            uint256,
            uint256)
    {
        (uint256 a, uint256 b, uint256 c) = loanAndRefund.ViewRefund(contractID);
        return (a, b, c);
    }

  /**
  * @dev Function
  */
    function allContracts() public view returns(uint256[] memory) {
        return (ContractIds[msg.sender]);
    }

  /**
  * @dev Function
  */
    function planDetails(uint256 planID)
        public
        view
        returns(
            uint256,
            uint256,
            uint256,
            uint256) {
            return(
            Plans[planID].LoanInterestRate,
            Plans[planID].RefundWeeks,
            Plans[planID].LoanPeriod,
            Plans[planID].PlanPeriod
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
        public
        NotPaused()
        returns(bool) {
            require(EraswapToken.allowance(msg.sender, address(this)) >= stakedamount);
            require(EraswapToken.transferFrom(msg.sender, address(this), stakedamount));
            require(staking.AddStake(planid, ContractID, Plans[planid].PlanPeriod, stakedamount));
            require(newContract(owner, planid));
            return true;
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
        NotPaused()
        OnlyOwner()
        returns(bool) {
            require(EraswapToken.allowance(msg.sender, address(this)) >= total);
            require(EraswapToken.transferFrom(msg.sender, address(this), total));
            require(staking.BatchAddStake(batchlength, planid, ContractID, Plans[planid].PlanPeriod, amount));
            for (uint i = 0; i < batchlength; i++) {
                require(newContract(contractOwner[i], planid));
            }
            return true;
        }

    function newContract(address contractOwner, uint256 planID) internal returns(bool) {
        Contract memory tempContract;
        tempContract.status = 1;
        tempContract.planid = planID;
        tempContract.owner = contractOwner;
        tempContract.timestamp = now;
        Contracts[ContractID] = tempContract;
        ContractIds[contractOwner].push(ContractID);
        emit ContractCreated(ContractID, contractOwner, planID);
        ContractID = ContractID.add(1);
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
        public
        NotPaused()
        OnlyOwner()
        returns(bool) {
            TimeAllyPlan memory tempPlan;
            tempPlan.PlanPeriod = planperiod;
            tempPlan.LoanInterestRate = loanInterestRate;
            tempPlan.LoanPeriod = loanPeriod;
            tempPlan.RefundWeeks = refundWeeks;
            Plans[PlanID] = tempPlan;
            emit PlanCreated(PlanID);
            PlanID = PlanID.add(1);
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
                require(staking.Pause(Contracts[contractID].planid, contractID));
                Contracts[contractID].status = 3;
                uint256 refundAmount = (staking.ViewStakedAmount(contractID))
                                            .div(Plans[Contracts[contractID].planid].RefundWeeks);
                require(loanAndRefund.AddRefund(contractID,
                                                uint32(Plans[Contracts[contractID].planid].RefundWeeks),
                                                0,
                                                uint64(refundAmount)));
                emit WindupInitiated(contractID,
                                        Contracts[ContractID].owner,
                                        staking.ViewStakedAmount(contractID),
                                        Contracts[contractID].planid);
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
                require(loanamount < ((staking.ViewStakedAmount(contractID)).div(2)));
                uint256 planid = Contracts[contractID].planid;
                uint256 repayamount = loanamount.add((loanamount.mul(Plans[planid].LoanInterestRate)).div(100));
                require(staking.Pause(planid, contractID));
                require(loanAndRefund.AddLoan(contractID, uint32(Plans[planid].LoanPeriod), uint128(loanamount)));
                LoanRepaymentAmount[contractID] = repayamount;
                Contracts[contractID].status = 2;
                require(EraswapToken.transfer(Contracts[contractID].owner, loanamount));
                emit LoanTaken(contractID, Contracts[ContractID].owner, loanamount, planid);
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
            require(EraswapToken.allowance(msg.sender, address(this)) >= LoanRepaymentAmount[contractID]);
            require(EraswapToken.transferFrom(msg.sender, address(this), LoanRepaymentAmount[contractID]));
            require(loanAndRefund.RemoveLoan(contractID));
            uint256 planid = Contracts[contractID].planid;
            (, , uint256 amount) = loanAndRefund.ViewLoan(contractID);
            uint256 luckPoolBal = LoanRepaymentAmount[contractID].sub(amount);
            require(EraswapToken.approve(NRTManagerAddress, luckPoolBal));
            require(nrtManager.UpdateLuckpool(luckPoolBal));
            require(staking.Resume(planid, contractID));
            Contracts[contractID].status = 1;
            emit LoanRepayed(contractID, Contracts[ContractID].owner, amount, luckPoolBal, planid);
            return true;
        }



  /**
   * @dev To Transfer Staking Ownership
   * @return bool true if ownership successfully transffered
   */
    function transferOwnership(
        uint256 contractid,
        address newowner)
        public
        onlyContractOwner(contractid)
        loanCanBeTaken(contractid)
        returns(bool) {
            emit OwnershipTransfered(contractid, Contracts[contractid].owner, newowner);
            Contracts[contractid].owner = newowner;
            return true;
        }



}
