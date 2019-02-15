## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| LoanAndRefund.sol | 7c1ef3ef84d358cdc3564f9283063056c7ab0a62 |


### Contracts Description Table


|  Contract  |         Type        |       Bases      |                  |                 |
|:----------:|:-------------------:|:----------------:|:----------------:|:---------------:|
|     └      |  **Function Name**  |  **Visibility**  |  **Mutability**  |  **Modifiers**  |
||||||
| **LoanAndRefund** | Implementation |  |||
| └ | \<Constructor\> | Public ❗️ | 🛑  | |
| └ | ViewLoan | Public ❗️ |   | OnlyTimeAlly |
| └ | ViewRefund | Public ❗️ |   | OnlyTimeAlly |
| └ | AddLoan | Public ❗️ | 🛑  | OnlyTimeAlly |
| └ | RemoveLoan | Public ❗️ | 🛑  | OnlyTimeAlly |
| └ | AddRefund | Public ❗️ | 🛑  | OnlyTimeAlly |
| └ | MonthlyRefundHandler | Public ❗️ | 🛑  | OnlyTimeAlly |
| └ | MonthlyLoanHandler | Public ❗️ | 🛑  | OnlyTimeAlly |
| └ | DeleteRefundListElement | Internal 🔒 | 🛑  | |
| └ | DeleteLoanListElement | Internal 🔒 | 🛑  | |


### Legend

|  Symbol  |  Meaning  |
|:--------:|-----------|
|    🛑    | Function can modify state |
|    💵    | Function is payable |
