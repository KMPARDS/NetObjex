## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| Staking.sol | b35b8e814d4bec0c3de322f3fd550b50e915205d |


### Contracts Description Table


|  Contract  |         Type        |       Bases      |                  |                 |
|:----------:|:-------------------:|:----------------:|:----------------:|:---------------:|
|     └      |  **Function Name**  |  **Visibility**  |  **Mutability**  |  **Modifiers**  |
||||||
| **Staking** | Implementation |  |||
| └ | \<Constructor\> | Public ❗️ | 🛑  | |
| └ | ViewStake | Public ❗️ |   | OnlyTimeAlly |
| └ | ViewStakedAmount | Public ❗️ |   | OnlyTimeAlly |
| └ | AddStake | Public ❗️ | 🛑  | OnlyTimeAlly |
| └ | BatchAddStake | Public ❗️ | 🛑  | OnlyTimeAlly |
| └ | Pause | Public ❗️ | 🛑  | OnlyTimeAlly |
| └ | Resume | Public ❗️ | 🛑  | OnlyTimeAlly |
| └ | MonthlyNRTHandler | Public ❗️ | 🛑  | OnlyTimeAlly |
| └ | MonthlyPlanHandler | Public ❗️ | 🛑  | OnlyTimeAlly |
| └ | DeleteActivePlanListElement | Internal 🔒 | 🛑  | |


### Legend

|  Symbol  |  Meaning  |
|:--------:|-----------|
|    🛑    | Function can modify state |
|    💵    | Function is payable |
