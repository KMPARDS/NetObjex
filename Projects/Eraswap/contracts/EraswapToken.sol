pragma solidity ^0.4.24 ;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20Burnable.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20Capped.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20Detailed.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20Pausable.sol";

contract EraswapToken is ERC20Detailed , ERC20Burnable ,ERC20Capped ,ERC20Pausable {
    string private _name = "Eraswap";
    string private _symbol = "EST";
    uint8 private _decimals = 18;
    uint256 private _cap = 9100000000000000000000000000;

    constructor() public
    ERC20Detailed(_name ,_symbol ,_decimals)
    ERC20Capped(_cap){
        _mint(msg.sender, _cap);
    }

}
