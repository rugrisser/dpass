// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.28;

struct Grants {
    bool manageGrants;
    bool manageVerifications;
}

struct Verification {
    address grantedTo;
    uint256 validUntil;
    uint64 chainId;
}

contract KYC {

    uint64 _chainId;

    mapping (address => Grants) _acl;
    mapping (address => uint256) _validUntil;

    modifier manageGrants {
        require(_acl[msg.sender].manageGrants, "Not enough access");
        _;
    }

    modifier manageVerifications {
        require(_acl[msg.sender].manageVerifications, "Not enough access");
        _;
    }

    constructor(address owner, uint64 chainId) {
        _acl[owner] = Grants({
            manageGrants: true,
            manageVerifications: true
        });
        _chainId = chainId;
    }

    function addVerificator(address verificator) public manageGrants {
        _acl[verificator].manageVerifications = true;
    }
    
    function removeVerificator(address verificator) public manageGrants {
        _acl[verificator].manageVerifications = false;
    }

    function issueVerification(address owner, uint256 validUntil) public manageVerifications {
        _validUntil[owner] = validUntil;
    }
}
