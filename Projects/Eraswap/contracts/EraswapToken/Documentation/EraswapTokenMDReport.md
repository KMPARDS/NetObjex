## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| EraswapToken.sol | 91f561c201cef470e07b8b9e67d5b34ea9a7611c |


### Contracts Description Table


|  Contract  |         Type        |       Bases      |                  |                 |
|:----------:|:-------------------:|:----------------:|:----------------:|:---------------:|
|     └      |  **Function Name**  |  **Visibility**  |  **Mutability**  |  **Modifiers**  |
||||||
| **ERC20Basic** | Implementation |  |||
| └ | totalSupply | Public ❗️ |   | |
| └ | balanceOf | Public ❗️ |   | |
| └ | transfer | Public ❗️ | 🛑  | |
||||||
| **BasicToken** | Implementation | ERC20Basic |||
| └ | totalSupply | Public ❗️ |   | |
| └ | transfer | Public ❗️ | 🛑  | |
| └ | balanceOf | Public ❗️ |   | |
||||||
| **BurnableToken** | Implementation | BasicToken |||
| └ | burn | Public ❗️ | 🛑  | |
| └ | _burn | Internal 🔒 | 🛑  | |
||||||
| **ERC20** | Implementation | ERC20Basic |||
| └ | allowance | Public ❗️ |   | |
| └ | transferFrom | Public ❗️ | 🛑  | |
| └ | approve | Public ❗️ | 🛑  | |
||||||
| **DetailedERC20** | Implementation | ERC20 |||
| └ | \<Constructor\> | Public ❗️ | 🛑  | |
||||||
| **Ownable** | Implementation |  |||
| └ | \<Constructor\> | Public ❗️ | 🛑  | |
| └ | renounceOwnership | Public ❗️ | 🛑  | onlyOwner |
| └ | transferOwnership | Public ❗️ | 🛑  | onlyOwner |
| └ | _transferOwnership | Internal 🔒 | 🛑  | |
||||||
| **SafeMath** | Library |  |||
| └ | mul | Internal 🔒 |   | |
| └ | div | Internal 🔒 |   | |
| └ | sub | Internal 🔒 |   | |
| └ | add | Internal 🔒 |   | |
||||||
| **StandardToken** | Implementation | ERC20, BasicToken |||
| └ | transferFrom | Public ❗️ | 🛑  | |
| └ | approve | Public ❗️ | 🛑  | |
| └ | allowance | Public ❗️ |   | |
| └ | increaseApproval | Public ❗️ | 🛑  | |
| └ | decreaseApproval | Public ❗️ | 🛑  | |
||||||
| **MintableToken** | Implementation | StandardToken, Ownable |||
| └ | mint | Public ❗️ | 🛑  | hasMintPermission canMint |
| └ | finishMinting | Public ❗️ | 🛑  | onlyOwner canMint |
||||||
| **CappedToken** | Implementation | MintableToken |||
| └ | \<Constructor\> | Public ❗️ | 🛑  | |
| └ | mint | Public ❗️ | 🛑  | |
||||||
| **EraswapERC20** | Implementation | DetailedERC20, BurnableToken, CappedToken |||
| └ | \<Constructor\> | Public ❗️ | 🛑  | DetailedERC20 CappedToken |
||||||
| **NRTManager** | Implementation | Ownable, EraswapERC20 |||
| └ | burnTokens | Internal 🔒 | 🛑  | |
| └ | MonthlyNRTRelease | External ❗️ | 🛑  | |
| └ | \<Constructor\> | Public ❗️ | 🛑  | |
||||||
| **PausableEraswap** | Implementation | NRTManager |||
| └ | transfer | Public ❗️ | 🛑  | whenNotPaused |
| └ | transferFrom | Public ❗️ | 🛑  | whenNotPaused |
| └ | approve | Public ❗️ | 🛑  | whenNotPaused |
| └ | increaseApproval | Public ❗️ | 🛑  | whenNotPaused |
| └ | decreaseApproval | Public ❗️ | 🛑  | whenNotPaused |
||||||
| **EraswapToken** | Implementation | PausableEraswap |||
| └ | UpdateAddresses | Public ❗️ | 🛑  | onlyOwner |
| └ | UpdateLuckpool | External ❗️ | 🛑  | OnlyTimeAlly |
| └ | UpdateBurnBal | External ❗️ | 🛑  | OnlyTimeAlly |
| └ | UpdateBalance | External ❗️ | 🛑  | OnlyTimeAlly |


### Legend

|  Symbol  |  Meaning  |
|:--------:|-----------|
|    🛑    | Function can modify state |
|    💵    | Function is payable |
