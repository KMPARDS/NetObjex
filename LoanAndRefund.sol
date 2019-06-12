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

    mapping (uint256 => Refund) public refunds;

    uint256[] public refundList;
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

    function addLoan(
        uint256 contractid,
        uint32 loanperiod,
        uint128 loanamount
        )
        external
        onlyTimeAlly()
        returns(bool)
    {
        Loan memory loan;
        loan.loanPeriod = loanperiod;
        loan.loanAmount = uint128(loanamount);
        loan.loanStartTime = uint32(now);
        loan.loanListIndex = uint32((loanList.push(contractid)).sub(1));
        loans[contractid] = loan;
        return true;
    }

    function removeLoan(uint256 contractid)
        external
        onlyTimeAlly()
        returns(bool)
    {
        require(deleteLoanListElement(loans[contractid].loanListIndex));
        return true;
    }

    function addRefund(
        uint256 contractid,
        uint32 refundweeks,
        uint32 refundcount,
        uint64 refundamount)
        external
        onlyTimeAlly()
        returns(bool)
    {
        Refund memory refund;
        refund.refundWeeks = refundweeks;
        refund.refundCount = refundcount;
        refund.refundAmount = refundamount;
        refund.refundListIndex = uint32(refundList.push(contractid).sub(1));

        refunds[contractid] = refund;
        return true;
    }

    function monthlyLoanHandler(uint256 size)
        external
        onlyTimeAlly()
        returns(
            uint[] memory,
            uint
            )
    {
        uint256[] memory defaultlist;
        Loan memory loan;
        uint256 i = loanListUpdateCount;
        uint256 limit;
        if (i.add(size) >= loanList.length){
            limit = loanList.length;
        }else {
            limit = i.add(size);
        }
        while (i < limit) {
            uint256 contractid = loanList[i];
            loan = loans[contractid];
            if ((now.sub(loan.loanStartTime)) > loan.loanPeriod) {
                defaultlist[defaultlist.length] = contractid;
                deleteLoanListElement(loan.loanListIndex);
                emit LoanDefaulted(contractid);
                limit = limit.sub(1);
            }else {
                i++;
            }
        }
        if (limit == loanList.length) {
            loanListUpdateCount = 0;
        }else {
            loanListUpdateCount = limit;
        }
        return(defaultlist, loanList.length.sub(limit));
    }

    function monthlyRefundHandler(uint256 size)
        external
        onlyTimeAlly()
        returns(
            uint[] memory,
            uint)
    {
        uint256[] memory userPayment;
        uint256 character;
        Refund memory refund;
        uint256 i = refundListUpdateCount;
        uint256 limit;
        if (i.add(size) >= refundList.length) {
            limit = refundList.length;
        }else {
            limit = i.add(size);
        }
        while (i < limit) {
            uint256 contractid = refundList[i];
            refund = refunds[contractid];
            character = contractid;
            character |= refund.refundAmount<<128;
            userPayment[userPayment.length] = character;
            emit RefundInitiated(contractid, refund.refundCount, refund.refundAmount);
            refund.refundCount++;
            refunds[contractid] = refund;
            if (refund.refundCount == refund.refundWeeks) {
                require(deleteRefundListElement(refund.refundListIndex));
                emit RefundEnded(contractid);
                limit = limit.sub(1);
            }else {
                i++;
            }
        }
        if (limit == refundList.length) {
            refundListUpdateCount = 0;
        }else {
            refundListUpdateCount = limit;
        }
        return(userPayment, refundList.length.sub(limit));
    }

    function viewLoan(uint256 contractid)
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
            uint256(loans[contractid].loanPeriod),
            uint256(loans[contractid].loanStartTime),
            uint256(loans[contractid].loanAmount)
            );
    }

    function viewRefund(uint256 contractid)
        external
        onlyTimeAlly()
        view
        returns(
            uint256,
            uint256,
            uint256)
            {
        return(
            uint256(refunds[contractid].refundWeeks),
            uint256(refunds[contractid].refundCount),
            uint256(refunds[contractid].refundAmount)
            );
    }

    function deleteRefundListElement(uint32 index)
        internal
        returns(bool)
    {
        require(index < refundList.length);
        uint256 last = refundList.length.sub(1);
        refunds[refundList[last]].refundListIndex = index;
        refundList[index] = refundList[last];
        refundList.pop();
        return true;
    }

    function deleteLoanListElement(uint32 index)
        internal
        returns(bool)
    {
        require(index < loanList.length);
        uint256 last = loanList.length.sub(1);
        loans[loanList[last]].loanListIndex = index;
        loanList[index] = loanList[last];
        loanList.pop();
        return true;
    }

}

