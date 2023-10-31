// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

import "./IMyToken.sol";

contract MyToken is IMyToken {
    string name_;
    string symbol_;
    address shop_;
    mapping(address => uint) tokens_;
    uint public totalNumber;

    constructor(string memory _name, string memory _symbol) {
        name_ = _name;
        symbol_ = _symbol;
    }

    function name() external view returns (string memory) {
        return name_;
    }

    function symbol() external view returns (string memory) {
        return symbol_;
    }

    function balanceOf(address _address) external view returns (uint) {
        return tokens_[_address];
    }

    function addTokens(address _address, uint nTokens) external {
        tokens_[_address] += nTokens;
        totalNumber += nTokens;
        emit Transfer(_address, int(nTokens));
    }
}
