pragma solidity ^0.4.24 ;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20Burnable.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20Capped.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20Detailed.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20Pausable.sol";

contract EraswapToken is ERC20Detailed , ERC20Burnable ,ERC20Capped , Ownable ,ERC20Pausable {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string  name, string  symbol, uint8  decimals, uint256 cap) public
    ERC20Detailed(name ,symbol ,decimals)
    ERC20Capped(cap){
        _mint(msg.sender, cap);
    }

}
