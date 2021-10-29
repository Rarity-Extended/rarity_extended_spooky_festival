// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "./rERC20.sol";

contract Candies is rERC20 {
    constructor(address _rm) rERC20("Candies", "Candies", _rm) {}
}
