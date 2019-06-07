pragma solidity ^0.5.2;

import "./SafeMath.sol";


contract LoanAndRefund {
    using SafeMath for uint256;

    struct Loan {
        uint128 loanAmount;
        uint32 loanPeriod;
        uint32 loanStartTime;
        uint32 loanListIndex;
    }

    mapping (uint256 => Loan) public loans;

    struct Refund {
        uint32 refundWeeks;
        uint32 refundCount;
        uint32 refundListIndex;
        uint64 refundAmount;
    }

    mapping (uint256 => Refund) public reFunds;

    uint256[] public reFundList;
    uint256[] public loanList;
    uint256 private refundListUpdateCount;
    uint256 private loanListUpdateCount;
    address public timeAlly;

    event RefundInitiated(uint256 contractid, uint256 count, uint256 amount);
    event RefundEnded(uint256 contractid);
    event LoanDefaulted(uint256 contractid);

    modifier onlyTimeAlly() {
        require(msg.sender == timeAlly, "Owner TimeAlly should be calling");
        _;
    }

    constructor(address timeally) public {
        timeAlly = timeally;
    }

    function viewLoan(uint256 contractID)
        external
        onlyTimeAlly()
        view
        returns(
            uint256,
            uint256,
            uint256
            )
    {
        return(
            uint256(loans[contractID].loanPeriod),
            uint256(loans[contractID].loanStartTime),
            uint256(loans[contractID].loanAmount)
            );
    }

    function ViewRefund(uint256 contractID) external onlyTimeAlly() view returns(uint256, uint256, uint256){
   return(uint256(reFunds[contractID].refundWeeks), uint256(reFunds[contractID].refundCount), uint256(reFunds[contractID].refundAmount));
  }

  function AddLoan(uint256 contractID, uint32 loanperiod, uint128 loanamount) external onlyTimeAlly() returns(bool) {
      Loan memory loan;
      loan.loanPeriod = loanperiod;
      loan.loanAmount = uint128(loanamount);
      loan.loanStartTime = uint32(now);
      loan.loanListIndex = uint32(loanList.push(contractID).sub(1));
      loans[contractID] = loan;
  return true;
  }

  function RemoveLoan(uint256 contractID) external onlyTimeAlly() returns(bool) {
  DeleteLoanListElement(loans[contractID].loanListIndex);
  return true;
  }

  function AddRefund(uint256 contractID, uint32 refundweeks, uint32 refundcount, uint64 refundamount) external onlyTimeAlly() returns(bool) {
      Refund memory refund;
      refund.refundWeeks = refundweeks;
      refund.refundCount = refundcount;
      refund.refundAmount = refundamount;
      refund.refundListIndex = uint32(reFundList.push(contractID).sub(1));

      reFunds[contractID] = refund;
      return true;
  }

  function MonthlyRefundHandler(uint256 size) external onlyTimeAlly() returns (uint[] memory, uint){
      uint256[] memory UserPayment;
      uint256 character;
      Refund memory refund;
      uint256 i = refundListUpdateCount;
      if(i.add(size) >= reFundList.length){
          size = reFundList.length;
      }
      else{
          size = i.add(size);
      }
      while ( i < size) {
          uint256 contractID = reFundList[i];
          refund = reFunds[contractID];
          character = contractID;
          character |= refund.refundAmount<<128;
          UserPayment[UserPayment.length] = character;
          emit RefundInitiated(contractID, refund.refundCount, refund.refundAmount);
          refund.refundCount++;
          reFunds[contractID] = refund;
          if(refund.refundCount == refund.refundWeeks){
              DeleteRefundListElement(refund.refundListIndex);
              emit RefundEnded(contractID);
              size = size.sub(1);
          }
          else {
              i++;
          }

      }
      if(size == reFundList.length) {
          refundListUpdateCount =  0;
      }
      else {
          refundListUpdateCount =  size;
      }
      return(UserPayment, reFundList.length.sub(size));
  }

  function MonthlyLoanHandler(uint256 size) external onlyTimeAlly() returns (uint[] memory, uint){
      uint256[] memory Defaultlist;
      Loan memory loan;
      uint256 i = loanListUpdateCount;
      if(i.add(size) >= loanList.length){
          size = loanList.length;
      }
      else{
          size = i.add(size);
      }
      while (i < size) {
          uint256 contractID = loanList[i];
          loan = loans[contractID];
          if ((now.sub(loan.loanStartTime)) > loan.loanPeriod ) {
              Defaultlist[Defaultlist.length] = contractID;
              DeleteLoanListElement(loan.loanListIndex);
              emit LoanDefaulted(contractID);
              size = size.sub(1);
          }
          else {
              i++;
          }

      }
      if(size == loanList.length) {
          loanListUpdateCount =  0;
      }
      else {
          loanListUpdateCount =  size;
      }
      return(Defaultlist, loanList.length.sub(size));
  }


    function DeleteRefundListElement(uint32 index) internal returns(bool){
        require(index < reFundList.length);
        uint256 last = reFundList.length.sub(1);
        reFunds[reFundList[last]].refundListIndex = index;
        reFundList[index] = reFundList[last];
        reFundList.pop();
        return true;
    }

    function DeleteLoanListElement(uint32 index) internal returns(bool){
        require(index < loanList.length);
        uint256 last = loanList.length.sub(1);
        loans[loanList[last]].loanListIndex = index;
        loanList[index] = loanList[last];
        loanList.pop();
        return true;
    }

}
