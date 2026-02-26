// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.5.0
pragma solidity ^0.8.27;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract NurscaToken is ERC20 {
    uint8 constant decimal = 18;
    uint256 total_supply;

    constructor(uint256 _totalSupply) ERC20("NurscaToken", "NUR") {
        total_supply = _totalSupply;
        _mint(msg.sender, total_supply);
    }
}