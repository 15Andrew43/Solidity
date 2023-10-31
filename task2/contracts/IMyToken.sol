// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

interface IMyToken {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function balanceOf(address _address) external view returns (uint);

    function addTokens(address _address, uint nTokens) external;

    event Transfer(address to, int amount);
}
