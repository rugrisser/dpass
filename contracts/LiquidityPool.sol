// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.22;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract LiquidityPool is Ownable {

    IERC20 public immutable anchorToken;
    bool public isLocked = true;

    modifier onlyOpened {
        require(!isLocked, "Pool is locked");
        _;
    }

    constructor(address _anchorToken) Ownable(msg.sender) {
        anchorToken = IERC20(_anchorToken);
    }

    function unlockLiquidity() external onlyOwner {
        isLocked = false;
    }
}
