pragma solidity ^0.5.2;

import "./SafeMath.sol";


contract LoanAndRefund{
  using SafeMath for uint256;

  struct Loan {
  uint128 LoanAmount;
  uint32 LoanPeriod;
  uint32 loanStartTime;
  uint32 LoanListIndex;
  }
  mapping (uint256 => Loan) public Loans;

  struct Refund {
  uint32 RefundWeeks;
  uint32 Refundcount;
  uint32 RefundListIndex;
   uint64 RefundAmount;
  }
  mapping (uint256 => Refund) public Refunds;

  uint256[] public RefundList;
  uint256[] public LoanList;
  uint256 private RefundListUpdateCount;
  uint256 private LoanListUpdateCount;
  address TimeAlly;

event RefundInitiated(uint256 contractid, uint256 count, uint256 amount);
event RefundEnded(uint256 contractid);
event LoanDefaulted(uint256 contractid);


   modifier OnlyTimeAlly() {
     require(msg.sender == TimeAlly, "Owner TimeAlly should be calling");
     _;
   }

   constructor(address timeally) public {
     TimeAlly = timeally;
   }

  function ViewLoan(uint256 contractID) public OnlyTimeAlly() view returns(uint256, uint256, uint256){
   return(uint256(Loans[contractID].LoanPeriod), uint256(Loans[contractID].loanStartTime), uint256(Loans[contractID].LoanAmount));
  }

    function ViewRefund(uint256 contractID) public OnlyTimeAlly() view returns(uint256, uint256, uint256){
   return(uint256(Refunds[contractID].RefundWeeks), uint256(Refunds[contractID].Refundcount), uint256(Refunds[contractID].RefundAmount));
  }

  function AddLoan(uint256 contractID, uint32 loanperiod, uint128 loanamount) public OnlyTimeAlly() returns(bool) {
    Loan memory loan;
    loan.LoanPeriod = loanperiod;
    loan.LoanAmount = uint128(loanamount);
    loan.loanStartTime = uint32(now);
    loan.LoanListIndex = uint32(LoanList.push(contractID).sub(1));
    Loans[contractID] = loan;
  return true;
  }

  function RemoveLoan(uint256 contractID) public OnlyTimeAlly() returns(bool) {
  DeleteLoanListElement(Loans[contractID].LoanListIndex);
  return true;
  }

  function AddRefund(uint256 contractID, uint32 refundWeeks, uint32 refundcount, uint64 refundamount) public OnlyTimeAlly() returns(bool) {
  Refund memory refund;
  refund.RefundWeeks = refundWeeks;
  refund.Refundcount = refundcount;
  refund.RefundAmount = refundamount;
  refund.RefundListIndex = uint32(RefundList.push(contractID).sub(1));

  Refunds[contractID] = refund;
  return true;
  }

  function MonthlyRefundHandler(uint256 size) public OnlyTimeAlly() returns (uint[] memory, uint){
    uint256[] memory UserPayment;
    uint256 character;
    Refund memory refund;
    uint256 i = RefundListUpdateCount;
    if(i.add(size) >= RefundList.length){
    size = RefundList.length;
    }
    else{
    size = i.add(size);
    }
    while ( i < size) {
      uint256 contractID = RefundList[i];
      refund = Refunds[contractID];
      character = contractID;
      character |= refund.RefundAmount<<128;
      UserPayment[UserPayment.length] = character;
      emit RefundInitiated(contractID, refund.Refundcount, refund.RefundAmount);
      refund.Refundcount++;
      Refunds[contractID] = refund;
      if(refund.Refundcount == refund.RefundWeeks){
        DeleteRefundListElement(refund.RefundListIndex);
        emit RefundEnded(contractID);
        size = size.sub(1);
      }
      else {
        i++;  
      }
      
    }
  if(size == RefundList.length) {
  RefundListUpdateCount =  0;  
  }
  else {
  RefundListUpdateCount =  size;
  }
  return(UserPayment, RefundList.length.sub(size));
  }

  function MonthlyLoanHandler(uint256 size) public OnlyTimeAlly() returns (uint[] memory, uint){
    uint256[] memory Defaultlist;
    Loan memory loan;
    uint256 i = LoanListUpdateCount;
    if(i.add(size) >= LoanList.length){
    size = LoanList.length;
    }
    else{
    size = i.add(size);
    }
    while (i < size) {
      uint256 contractID = LoanList[i];
      loan = Loans[contractID];
      if ((now.sub(loan.loanStartTime)) > loan.LoanPeriod ) {
        Defaultlist[Defaultlist.length] = contractID;
        DeleteLoanListElement(loan.LoanListIndex);
        emit LoanDefaulted(contractID);
        size = size.sub(1);
      }
    else {
        i++;  
      }
      
    }
  if(size == LoanList.length) {
  LoanListUpdateCount =  0;  
  }
  else {
  LoanListUpdateCount =  size;
  }
    return(Defaultlist, LoanList.length.sub(size));
  }


    function DeleteRefundListElement(uint32 index) internal returns(bool){
      require(index < RefundList.length);
      uint256 last = RefundList.length.sub(1);
      Refunds[RefundList[last]].RefundListIndex = index;
      RefundList[index] = RefundList[last];
      RefundList.pop();
      return true;
    }

    function DeleteLoanListElement(uint32 index) internal returns(bool){
      require(index < LoanList.length);
      uint256 last = LoanList.length.sub(1);
      Loans[LoanList[last]].LoanListIndex = index;
      LoanList[index] = LoanList[last];
      LoanList.pop();
      return true;
    }

}

