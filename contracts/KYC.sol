// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.22;

struct Grants {
    bool manageGrants;
    bool manageVerifications;
}

contract KYC {

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

    constructor(address owner) {
        require(owner != address(0x0));
        acl[owner] = Grants({
            manageGrants: true,
            manageVerifications: true
        });
    }

    function addVerificator(address verificator) public manageGrants {
        acl[verificator].manageVerifications = true;
    }
    
    function removeVerificator(address verificator) public manageGrants {
        acl[verificator].manageVerifications = false;
    }

    function issueVerification(address owner, uint256 _validUntil) public manageVerifications {
        require(_validUntil > block.timestamp, "Verification should be actual");
        require(_validUntil > validUntil[owner], "Forbidden to reduce verification period");

        validUntil[owner] = _validUntil;
    }
}
