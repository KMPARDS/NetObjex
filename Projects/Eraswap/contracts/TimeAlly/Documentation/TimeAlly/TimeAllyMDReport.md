## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| TimeAlly.sol | 469b0cf6cb1e8b8a91158c546ecfc29712344be1 |


### Contracts Description Table


|  Contract  |         Type        |       Bases      |                  |                 |
|:----------:|:-------------------:|:----------------:|:----------------:|:---------------:|
|     └      |  **Function Name**  |  **Visibility**  |  **Mutability**  |  **Modifiers**  |
||||||
| **TimeAlly** | Implementation | TimeAllyCore |||
| └ | ViewContract | Public ❗️ |   | OnlyContractOwner |
| └ | ViewUserStakes | Public ❗️ |   | OnlyContractOwner |
| └ | ViewUserLoan | Public ❗️ |   | OnlyContractOwner |
| └ | ViewUserRefund | Public ❗️ |   | OnlyContractOwner |
| └ | AllContracts | Public ❗️ |   | |
| └ | PlanDetails | Public ❗️ |   | |
| └ | CreateContract | Public ❗️ | 🛑  | NotPaused |
| └ | CreateContractsByBatch | Public ❗️ | 🛑  | NotPaused OnlyOwner |
| └ | NewContract | Internal 🔒 | 🛑  | |
| └ | CreatePlan | Public ❗️ | 🛑  | NotPaused OnlyOwner |
| └ | windUpContract | External ❗️ | 🛑  | OnlyContractOwner CanBeWindedUp |
| └ | takeLoan | External ❗️ | 🛑  | OnlyContractOwner LoanCanBeTaken |
| └ | rePayLoan | External ❗️ | 🛑  | OnlyContractOwner LoanCanBeRepayed |
| └ | transferOwnership | Public ❗️ | 🛑  | OnlyContractOwner LoanCanBeTaken |
| └ | \<Constructor\> | Public ❗️ | 🛑  | |


### Legend

|  Symbol  |  Meaning  |
|:--------:|-----------|
|    🛑    | Function can modify state |
|    💵    | Function is payable |
