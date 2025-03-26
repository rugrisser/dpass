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

    uint64 chainId;

    mapping (address => Grants) public acl;
    mapping (address => uint256) public validUntil;

    modifier manageGrants {
        require(acl[msg.sender].manageGrants, "Not enough access");
        _;
    }

    modifier manageVerifications {
        require(acl[msg.sender].manageVerifications, "Not enough access");
        _;
    }

    constructor(address owner, uint64 _chainId) {
        acl[owner] = Grants({
            manageGrants: true,
            manageVerifications: true
        });
        chainId = _chainId;
    }

    function addVerificator(address verificator) public manageGrants {
        acl[verificator].manageVerifications = true;
    }
    
    function removeVerificator(address verificator) public manageGrants {
        acl[verificator].manageVerifications = false;
    }

    function issueVerification(address owner, uint256 _validUntil) public manageVerifications {
        validUntil[owner] = _validUntil;
    }
}
