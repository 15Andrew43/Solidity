// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

library Math {
    function min(uint a, uint b) internal pure returns (uint) {
        return a < b ? a : b;
    }

    function max(uint a, uint b) internal pure returns (uint) {
        return a > b ? a : b;
    }
}
