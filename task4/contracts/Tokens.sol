// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MyToken is ERC20("myTOKEN", "my_token"), Ownable(msg.sender) {
    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
}

contract TokenForBorrowing is
    ERC20("myBorrowingTOKEN", "my_borrowing_token"),
    Ownable(msg.sender)
{
    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
}
