pragma solidity ^ 0.4.24;

import "./TimeAllyCore.sol";


contract TimeAlly is TimeAllyCore{

  using SafeMath for uint256;

  event ContractCreated(uint256 contractid, address owner, uint256 planid);
  event PlanCreated(uint256 planid);
  event WindupInitiated(uint256 contractid, address owner, uint256 amount, uint256 planid);
  event LoanTaken(uint256 contractid, address owner, uint256 loanamnt, uint256 planid);
  event LoanRepayed(uint256 contractid, address owner, uint256 loanamnt, uint256 interest, uint256 planid);
  event OwnershipTransfered(uint256 contractid, address owner, address newowner);



  modifier OnlyContractOwner(uint256 contractid) {
    require(msg.sender == Contracts[contractid].owner, "Owner should be calling");
    _;
  }


  /**
  * @dev Modifier
  */
  //todo: this also should check whther the contract have any active loans or not
  modifier CanBeWindedUp(uint256 contractID) {
    require(((now.sub(Contracts[contractID].timestamp)) >= Plans[Contracts[contractID].planid].PlanPeriod), "Contract can only be ended after 2 years");
    require(Contracts[contractID].status == 1);
    _;
  }

  /**
  * @dev Modifier
  */
  modifier LoanCanBeTaken(uint256 contractID) {
    require(Contracts[contractID].status == 1, "Loan should not be present");
    _;
  }

  /**
  * @dev Modifier
  */
  modifier LoanCanBeRepayed(uint256 contractID) {
    require(Contracts[contractID].status == 2, "Loan should not be present");
    _;
  }



  /**
  * @dev Function
  */

  function ViewContract(uint256 contractID) public view OnlyContractOwner(contractID) returns(uint256, uint256, uint256, address) {
    return (Contracts[ContractID].status, Contracts[ContractID].timestamp, Contracts[ContractID].planid, Contracts[ContractID].owner);
  }
  function ViewUserStakes(uint256 contractID) public view OnlyContractOwner(contractID) returns(uint256, uint256, uint256) {
    (uint256 a, uint256 b, uint256 c) = staking.ViewStake(contractID);
    return (a, b, c);
  }
  function ViewUserLoan(uint256 contractID) public view OnlyContractOwner(contractID) returns(uint256, uint256, uint256) {
    (uint256 a, uint256 b, uint256 c) = loanAndRefund.ViewLoan(contractID);
    return (a, b, c);
  }
  function ViewUserRefund(uint256 contractID) public view OnlyContractOwner(contractID) returns(uint256, uint256, uint256) {
    (uint256 a, uint256 b, uint256 c) = loanAndRefund.ViewRefund(contractID);
    return (a, b, c);
  }

  /**
  * @dev Function
  */

  function AllContracts() public view returns(uint256[]) {
    return (ContractIds[msg.sender]);
  }

  /**
  * @dev Function
  */

  function PlanDetails(uint256 planID) public view returns(uint256, uint256, uint256, uint256) {
    return (Plans[planID].LoanInterestRate, Plans[planID].RefundWeeks, Plans[planID].LoanPeriod, Plans[planID].PlanPeriod);
  }


  /**
   * @dev Function to create a contract
   * @return orderId of created
   */

  function CreateContract(address owner, uint256 planid, uint256 stakedamount) public NotPaused() returns(bool) {
    require(EraswapTokens.allowance(msg.sender, address(this)) >= stakedamount);
    require(EraswapTokens.transferFrom(msg.sender, address(this), stakedamount));

   require(staking.AddStake(planid, ContractID, Plans[planid].PlanPeriod, stakedamount));
   require(NewContract(owner, planid));
    return true;
  }

  /**
   * @dev To create staking contract by batch
   * @return orderIds of created contracts
   */

  function CreateContractsByBatch(uint256 batchlength, uint256 planid, address[] contractOwner, uint256[] amount, uint256 total) public NotPaused() OnlyOwner() returns(bool) {
     require(EraswapTokens.allowance(msg.sender, address(this)) >= total);
     require(EraswapTokens.transferFrom(msg.sender, address(this), total));
    require(staking.BatchAddStake(batchlength, planid, ContractID, Plans[planid].PlanPeriod, amount));
    for (uint i = 0; i < batchlength; i++) {
         require(NewContract(contractOwner[i], planid));
    }
    return true;
  }

  function NewContract(address contractOwner, uint256 planID) internal returns(bool) {
    Contract memory tempContract;
    tempContract.status = 1;
    tempContract.planid = planID;
    tempContract.owner = contractOwner;
    tempContract.timestamp = now;
    Contracts[ContractID] = tempContract;
    ContractIds[contractOwner].push(ContractID);
    emit ContractCreated(ContractID, contractOwner, planID);
    ContractID = ContractID++;
  }

  /**
  * @dev Function
  */
  function CreatePlan(uint256 planperiod, uint256 loanInterestRate, uint256 loanPeriod, uint256 refundWeeks) public NotPaused() OnlyOwner() returns(bool) {
    TimeAllyPlan memory tempPlan;
    tempPlan.PlanPeriod = planperiod;
    tempPlan.LoanInterestRate = loanInterestRate;
    tempPlan.LoanPeriod = loanPeriod;
    tempPlan.RefundWeeks = refundWeeks;
    Plans[PlanID] = tempPlan;
    emit PlanCreated(PlanID);
    PlanID = PlanID++;
    return true;
  }


  /**
  * @dev Function
  */

  function windUpContract(uint256 contractID) external OnlyContractOwner(contractID) CanBeWindedUp(contractID) returns(bool) {
    require(staking.Pause(Contracts[contractID].planid, contractID));
    Contracts[contractID].status = 3;
    uint256 refundAmount = (staking.ViewStakedAmount(contractID)).div(Plans[Contracts[contractID].planid].RefundWeeks);
    require(loanAndRefund.AddRefund(contractID, uint32(Plans[Contracts[contractID].planid].RefundWeeks), 0, uint64(refundAmount)));
    emit WindupInitiated(contractID, Contracts[ContractID].owner, staking.ViewStakedAmount(contractID), Contracts[contractID].planid);
    return true;
  }

  /**
  * @dev Function
  */

  function takeLoan(uint256 contractID, uint256 loanamount) external OnlyContractOwner(contractID) LoanCanBeTaken(contractID) returns(bool) {
    require(loanamount < ((staking.ViewStakedAmount(contractID)).div(2)));
    uint256 planid = Contracts[contractID].planid;
    uint256 repayamount = loanamount.add((loanamount.mul(Plans[planid].LoanInterestRate)).div(100));
    require(staking.Pause(planid, contractID));
    require(loanAndRefund.AddLoan(contractID, uint32(Plans[planid].LoanPeriod), uint128(loanamount)));
    LoanRepaymentAmount[contractID] = repayamount;
    Contracts[contractID].status = 2;
   // require(EraswapTokens.transfer(Contracts[contractID].owner, loanamount));
    emit LoanTaken(contractID, Contracts[ContractID].owner, loanamount, planid);
    return true;
  }

  /**
  * @dev Function
  */

  function rePayLoan(uint256 contractID) external OnlyContractOwner(contractID) LoanCanBeRepayed(contractID) returns(bool) {
  //  require(EraswapTokens.allowance(msg.sender, address(this)) >= LoanRepaymentAmount[contractID]));
  //  require(EraswapTokens.transferFrom(msg.sender, address(this), LoanRepaymentAmount[contractID]));
    require(loanAndRefund.RemoveLoan(contractID));
    uint256 planid = Contracts[contractID].planid;
    ( , , uint256 amount) = loanAndRefund.ViewLoan(contractID);
    uint256 luckPoolBal = LoanRepaymentAmount[contractID].sub(amount);
    //require(EraswapTokens.increaseApproval(EraswapTokenAddress, luckPoolBal));
    //require(EraswapTokens.UpdateLuckpool(luckPoolBal));
    require(staking.Resume(planid, contractID));
    Contracts[contractID].status = 1;
    emit LoanRepayed(contractID, Contracts[ContractID].owner, amount, luckPoolBal, planid);
    return true;
  }



  /**
   * @dev To Transfer Staking Ownership
   * @return bool true if ownership successfully transffered
   */
  function transferOwnership(uint256 contractid, address newowner) public OnlyContractOwner(contractid) LoanCanBeTaken(contractid) returns(bool) {
    emit OwnershipTransfered(contractid, Contracts[contractid].owner, newowner);
    Contracts[contractid].owner = newowner;
    return true;
  }

  /**
   * @dev Constructor
   */

  constructor(address eraswapTokenAddress, address stakingaddress, address loanandrefundaddress) public {
    EraswapTokenAddress = eraswapTokenAddress;
    StakingAddress = stakingaddress;
    LoanandRefundAddress = loanandrefundaddress;
    EraswapTokens = EraswapToken(eraswapTokenAddress);
    staking = Staking(stakingaddress);
    loanAndRefund = LoanAndRefund(loanandrefundaddress);
  }

}
