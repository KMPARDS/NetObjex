
pragma solidity ^0.5.2;

import "./ERC20Capped.sol";
import "./ERC20Burnable.sol";
import "./ERC20Detailed.sol";
import "./ERC20Pausable.sol";


contract Eraswap is ERC20Detailed,ERC20Burnable,ERC20Capped,ERC20Pausable {

event NRTManagerAdded(address NRTManager);

    constructor()
        public
         ERC20Detailed ("Era Swap", "ES", 18) ERC20Capped(9100000000000000000000000000) {
             mint(msg.sender, 910000000000000000000000000);
        }
        
        
    /**
    * @dev Function to add NRT Manager to have minting rights
    * It will transfer the minting rights to NRTManager and revokes it from existing minter
    * @param NRTManager Address of NRT Manager C ontract
    */
    function AddNRTManager(address NRTManager) public onlyMinter returns (bool) {
        addMinter(NRTManager);
        addPauser(NRTManager);
        renounceMinter();
        renouncePauser();
        emit NRTManagerAdded(NRTManager);
        return true;
      }

}
