// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.28;

import "./KYC.sol";

contract BridgeFacade {

    KYC _kycContract;

    constructor(address kycContract) {
        _kycContract = KYC(kycContract);
    }
}
