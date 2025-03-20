// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.28;

struct Grants {
    bool manageGrants;
    bool manageVerifications;
}

struct Verification {
    address grantedTo;
    // Some Chain ID
    uint256 validUntil;
}

contract KYC {

    mapping (address => Grants) _acl;

    modifier manageGrants {
        require(_acl[msg.sender].manageGrants, "Not enough access");
        _;
    }

    modifier manageVerifications {
        require(_acl[msg.sender].manageVerifications, "Not enough access");
        _;
    }

    constructor(address owner) {
        _acl[owner] = Grants({
            manageGrants: true,
            manageVerifications: true
        });
    }

    function addVerificator(address verificator) public manageGrants {
        _acl[verificator].manageVerifications = true;
    }
    
    function removeVerificator(address verificator) public manageGrants {
        _acl[verificator].manageVerifications = false;
    }
}
