pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

/**
* @title  NRT Distribution Contract
* @dev This contract will be responsible for distributing the newly released tokens to the different pools.
*/

// Interface for Eraswap token so as to manipulate it

// contract EraswapTokenInterface{
//     function mint(address to, uint256 value) public onlyMinter returns (bool);
// }

// The contract addresses of different pools
contract NRT_Manager is Ownable{
    using SafeMath for uint256;

    // address of EraswapToken

    address public EraswapToken;

    // Different address to distribute to different pools
    address public Luck_pool;
    address public New_Talents_and_Partnerships;
    address public Platform_maintenance;
    address public Marketing_and_RNR;
    address public Kmpards;
    address public Contingency_Funds;
    address public ReaserchAndDevelopment;
    address public buzzCafe;
    address public powerToken;

    // balances present in different pools

    uint256 public Luck_pool_bal;
    uint256 public New_Talents_and_Partnerships_bal;
    uint256 public Platform_maintenance_bal;
    uint256 public Marketing_and_RNR_bal;
    uint256 public Kmpards_bal;
    uint256 public Contingency_Funds_bal;
    uint256 public ReaserchAndDevelopment_bal;
    uint256 public powerToken_bal;

    // balances timeAlly workpool ditribution

    uint256 public curators_bal;
    uint256 public timeTraders_bal;
    uint256 public daySwappers_bal;
    uint256 public buzzCafe_bal;
    uint256 public stakers_bal;


    // Amount received to the NRT pool

    uint NRT_bal;

    // constructor

    constructor (address token) public{
        EraswapToken = token;
    }

    // Functions to set the different pool addresses

    function set_Luck_pool(address pool_addr) external onlyOwner(){
        Luck_pool = pool_addr;
    }

    function set_New_Talents_and_Partnerships(address pool_addr) external onlyOwner(){
        New_Talents_and_Partnerships = pool_addr;
    }

    function set_Platform_maintenance(address pool_addr) external onlyOwner(){
        Platform_maintenance = pool_addr;
    }

    function set_Marketing_and_RNR(address pool_addr) external onlyOwner(){
        Marketing_and_RNR = pool_addr;
    }

    function set_Kmpards(address pool_addr) external onlyOwner(){
        Kmpards = pool_addr;
    }

    function set_Contingency_Funds(address pool_addr) external onlyOwner(){
        Contingency_Funds = pool_addr;
    }

    function set_ReaserchAndDevelopment(address pool_addr) external onlyOwner(){
        ReaserchAndDevelopment = pool_addr;
    }
    function set_buzzCafe(address pool_addr) external onlyOwner(){
        buzzCafe = pool_addr;
    }
    function set_powerToken(address pool_addr) external onlyOwner(){
        powerToken = pool_addr;
    }


    // function which is called internally to distribute tokens
    function distribute_NRT() private onlyOwner() returns(bool){
        require(NRT_bal != 0,"There are no NRT to distribute");
        // Distibuting the newly released tokens to eachof the pools
        New_Talents_and_Partnerships_bal = New_Talents_and_Partnerships_bal.add(NRT_bal.mul(uint256(0.05)));
        Platform_maintenance_bal = Platform_maintenance_bal.add(NRT_bal.mul(uint256(0.10)));
        Marketing_and_RNR_bal = Marketing_and_RNR_bal.add(NRT_bal.mul(uint256(0.10)));
        Kmpards_bal = Kmpards_bal.add(NRT_bal.mul(uint256(0.10)));
        Contingency_Funds_bal = Contingency_Funds_bal.add(NRT_bal.mul(uint256(0.10)));
        ReaserchAndDevelopment_bal = ReaserchAndDevelopment_bal.add(NRT_bal.mul(uint256(0.05)));
        curators_bal = curators_bal.add(NRT_bal.mul(uint256(0.05)));
        timeTraders_bal = timeTraders_bal.add(NRT_bal.mul(uint256(0.05)));
        daySwappers_bal = daySwappers_bal.add(NRT_bal.mul(uint256(0.125)));
        buzzCafe_bal = buzzCafe_bal.add(NRT_bal.mul(uint256(0.025)));
        powerToken_bal = powerToken_bal.add(NRT_bal.mul(uint256(0.10)));
        stakers_bal = stakers_bal.add(NRT_bal.mul(uint256(0.15)));
     
    }




}
