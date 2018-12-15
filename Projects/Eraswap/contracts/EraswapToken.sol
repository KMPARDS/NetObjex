pragma solidity ^0.4.24 ;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20Burnable.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20Mintable.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20Detailed.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20Pausable.sol";

contract EraswapToken is ERC20Detailed , ERC20Mintable , ERC20Burnable  , Ownable ,ERC20Pausable {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string  name, string  symbol, uint8  decimals,uint8 totalsupply) public ERC20Detailed(_name ,_symbol ,_decimals){
        _mint(msg.sender, totalsupply);
    }

}