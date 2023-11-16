// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";
import "./Ownable.sol";

contract MyToken is ERC20,Ownable  {
   
    constructor(
        string memory name,
        string memory symbol,
        uint8 decimals,
        uint256 initialSupply
    ) ERC20(name, symbol) Ownable(msg.sender) {
        _mint(msg.sender, initialSupply * (10**decimals));
    }

    
    function mint(address account, uint256 amount) external onlyOwner {
        _mint(account, amount);
    }
}
