The function provides a constructor to add the timeAlly address to the contract.
└ 	<Constructor> 	Public exclamation 	stop_sign 	



The contract provides function to add and remove a loan. The functions add it to active loanlista and removes from it respectively.
└ 	AddLoan 	Public exclamation 	stop_sign 	OnlyTimeAlly
└ 	RemoveLoan 	Public exclamation 	stop_sign 	OnlyTimeAlly


The contract provides function to add refund and add it to refundlist.
└ 	AddRefund 	Public exclamation 	stop_sign 	OnlyTimeAlly

The contract provides functions to view the loan and refund details
└ 	ViewLoan 	Public exclamation 		OnlyTimeAlly
└ 	ViewRefund 	Public exclamation 		OnlyTimeAlly


The contract has 2 functions to perform monthly operations on loan and refund.

The function issues the refund amount to contracts in the refundlist. 
It also updtaes the refund count. If the refund count reaches the numberof months of refund of the plan, it'll be removed from the refunlist.  
└ 	MonthlyRefundHandler 	Public exclamation 	stop_sign 	OnlyTimeAlly

The function checks whether the loantime has exceed the loan period of the plan. If so, it removes the contract from loanlist and addsthe amount to defaultlist.
└ 	MonthlyLoanHandler 	Public exclamation 	stop_sign 	OnlyTimeAlly

The function has two internal functions to remove the contract from the activeloanlist and activerefundlist.
└ 	DeleteRefundListElement 	Internal lock 	stop_sign 	
└ 	DeleteLoanListElement 	Internal lock 	stop_sign 	
