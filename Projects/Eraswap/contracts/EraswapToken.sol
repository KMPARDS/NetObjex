pragma solidity ^0.4.24 ;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20Burnable.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20Mintable.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20Detailed.sol";

contract EraswapToken is ERC20Detailed , ERC20Mintable , ERC20Burnable  , Ownable {

    string private _name = "EraswapToken";
    string private _symbol= "EST";
    uint8 private _decimals= 18;
    constructor () public ERC20Detailed(_name ,_symbol ,_decimals){
        
    }

}