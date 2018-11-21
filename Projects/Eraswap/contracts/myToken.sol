pragma solidity ^0.4.24 ;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20Burnable.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20Mintable.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20Detailed.sol";

contract myToken is ERC20Detailed , ERC20Mintable , ERC20Burnable  , Ownable {

    string private _name = "myToken";
    string private _symbol= "MIT";
    uint8 private _decimals= 5;
    uint256 private _totalSupply=1000000000;
    constructor () public ERC20Detailed(_name ,_symbol ,_decimals){
        mint(msg.sender, _totalSupply);
    }

}