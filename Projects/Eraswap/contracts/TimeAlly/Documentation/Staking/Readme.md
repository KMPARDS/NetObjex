

The constructor is used to add the TimeAlly address to the conrtact.
└ 	<Constructor> 	Public exclamation 	stop_sign 	


The contract can be used to create, pause and resume a stake. A function to add a batch of stake. When stake is added, it is also added to the active planlist and activeplanamount is also updated. When a stake is paused, it is removed from activeplanlist and activeplanamount.
└ 	AddStake 	OnlyTimeAlly
└ 	BatchAddStake OnlyTimeAlly
└ 	Pause OnlyTimeAlly
└ 	Resume OnlyTimeAlly

The contract provides functions to view details of stake.
└ 	ViewStake OnlyTimeAlly
└ 	ViewStakedAmount OnlyTimeAlly

The contract has two functions to perform the monthly updation.

The function can recieve an NRT amount and which will be divided among different plans and luckpool balance will also be allocated.
└ 	MonthlyNRTHandler 	Public exclamation 	stop_sign 	OnlyTimeAlly

This NRT balance of each plan is divided to its users. 50% of the amount a user recieves is added back as principal to stake and 50% is released to accounts. 
The contract keeps track of when each principal is added and releases the corresponding amount when its reaches the plan time. This continues forever.
eg: Lets suppose the plan period is 12 months.
  In month 0, the initial stake was added and will be relesed exactly after 12 months.
  In month 1, 50% of the first interest will be added as principal and will be released after 12 months from this day.
The function also handles the release of principals if the plan period of the corresponding principal has reached.
└ 	MonthlyPlanHandler 	Public exclamation 	stop_sign 	OnlyTimeAlly

This is an internal function used to remove a stake from ActiveplanList.
└ 	DeleteActivePlanListElement 	Internal lock 	stop_sign 	
