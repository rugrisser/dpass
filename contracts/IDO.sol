// SPDX-License-Identifier: GPL-3.0-only
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.22;

import {KYC} from "./KYC.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

enum Status {
    ACTIVE, FREEZED, FINISHED, CANCELED
}

contract IDO is Ownable {

    uint256 public immutable softCap;
    uint256 public immutable hardCap;
    uint256 public immutable finishTimestamp;
    uint256 public immutable unfreezeTimestamp;
    uint256 public totalAmount = 0;
    IERC20 public immutable idoToken;
    KYC public immutable kyc;
    Status public status = Status.ACTIVE;

    mapping (address => uint256) public participantTokens;
    address[] public participants;

    uint8 public immutable rewardPercent;

    constructor(
        uint256 _softCap, 
        uint256 _hardCap,
        uint256 _finishTimestamp,
        uint256 _unfreezeTimestamp,
        address _kyc,
        address _idoToken,
        address _owner,
        uint8 _rewardPercent
    ) Ownable(_owner) {
        require(_softCap < _hardCap);
        require(_finishTimestamp > block.timestamp);
        require(_unfreezeTimestamp > block.timestamp);
        require(_kyc != address(0));
        require(_idoToken != address(0));
        require(_rewardPercent < 100);

        softCap = _softCap;
        hardCap = _hardCap;
        finishTimestamp = _finishTimestamp;
        unfreezeTimestamp = _unfreezeTimestamp;
        kyc = KYC(_kyc);
        idoToken = IERC20(_idoToken);
        rewardPercent = _rewardPercent;
    }

    function participate(uint256 tokenAmount) public {
        require(status == Status.ACTIVE, "IDO is not active");

        if (finishTimestamp < block.timestamp) {
            finish();
        }

        require(kyc.validUntil(msg.sender) >= block.timestamp, "Address is not verified");
        (bool success, bytes memory data) = address(idoToken).delegatecall(
            abi.encodeWithSignature("transfer(address,uint256)", address(this), tokenAmount)
        );
        require(success, "Token transfer failed");

        participantTokens[msg.sender] += tokenAmount;

        bool isParticipatedPreviously = false;

        for (uint it = 0; it < participants.length; it++) {
            if (participants[it] == msg.sender) {
                isParticipatedPreviously = true;
                break;
            }
        }

        if (!isParticipatedPreviously) {
            participants.push(msg.sender);
        }

        totalAmount += tokenAmount;

        if (totalAmount > hardCap) {
            finish();
        }
    }

    function finish() public {
        if (totalAmount < softCap && finishTimestamp < block.timestamp) {
            cancel();
        } else if (totalAmount >= softCap && finishTimestamp < block.timestamp) {
            status = Status.FREEZED;
        } else if (totalAmount > hardCap) {
            status = Status.FREEZED;
        }
    }


    function unfreezeTokens() public {
        status = Status.FINISHED;

        uint256 reward = totalAmount * rewardPercent / 100;
        uint256 share = totalAmount - reward;

        idoToken.transfer(owner(), reward);

        // TGE
    }

    function cancel() private {
        for (uint it = 0; it < participants.length; it++) {
            address participant = participants[it];
            idoToken.transfer(participant, participantTokens[participant]);
        }

        status = Status.CANCELED;
    }
}
