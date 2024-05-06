// SPDX-License-Identifier: MIT
/*
2024 © Atlaspad Launchpad
Virjilakrum
Compatible with OpenZeppelin Contracts ^5.0.0
*/

pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract APToken is ERC20, ERC20Burnable, Ownable {
    uint private constant _numTokens = 500000000;

    // event NameChanged(string newName, address by);

    constructor(
        address initialOwner
    ) ERC20("APToken", "AP") Ownable(initialOwner) {
        _mint(address(this), _numTokens * (10 ** decimals()));
    }

    function getBalance() external view returns(uint256) {
        return balanceOf(address(this));
    }

    function transferTokens(address recipient, uint256 amount) public returns (bool) {
        require(recipient != address(0), "ERC20: transfer to the zero address");
        //require(amount <= balanceOf(msg.sender), "ERC20: transfer amount exceeds balance");
        
        _transfer(address(this), recipient, amount * (10 ** decimals()));
        return true;
    }

    // function changeName(string memory name) public onlyOwner{
    //     _name = name;
    //     emit NameChanged(name, msg.sender);
    // }

    // function name() public view returns (string memory) {
    //     return _name;
    // }
}
