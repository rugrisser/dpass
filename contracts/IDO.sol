// SPDX-License-Identifier: GPL-3.0-only
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.22;

enum Status {
    INITIALIZED, STARTED, FINISHED, CANCELED
}

contract IDO {

    uint256 softCap;
    uint256 hardCap;
    uint256 finishTimestamp;
    Status status;
}
