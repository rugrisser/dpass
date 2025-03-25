// SPDX-License-Identifier: GPL-3.0-only
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.22;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract BridgeToken is ERC20, ERC20Permit {
    constructor(address recipient) ERC20("Bridge", "BRG") ERC20Permit("Bridge") {
        _mint(recipient, 10000 * 10 ** decimals());
    }
}
