// SPDX-License-Identifier: GPL-3.0-only
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.22;

import {KYC} from "./KYC.sol";
import {LiquidityPool} from "./LiquidityPool.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

enum Status {
    ACTIVE, FINISHED, CANCELED
}

contract IDO {

    uint256 public immutable softCap;
    uint256 public immutable hardCap;
    uint256 public immutable finishTimestamp;
    uint256 public totalAmount = 0;
    KYC public immutable kyc;
    LiquidityPool public immutable liquidityPool;
    Status public status = Status.ACTIVE;

    mapping (address => uint256) public participantTokens;
    address[] public participants;

    IERC20 private immutable idoToken;

    constructor(
        uint256 _softCap, 
        uint256 _hardCap,
        uint256 _finishTimestamp,
        address _kyc,
        address _liquidityPool
    ) {
        softCap = _softCap;
        hardCap = _hardCap;
        finishTimestamp = _finishTimestamp;
        kyc = KYC(_kyc);
        liquidityPool = LiquidityPool(_liquidityPool);

        idoToken = liquidityPool.anchorToken();
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
            finishSuccessfully();
        } else if (totalAmount > hardCap) {
            finishSuccessfully();
        }
    }

    function finishSuccessfully() private {
        status = Status.FINISHED;

        // add liquidity
    }

    function cancel() private {
        for (uint it = 0; it < participants.length; it++) {
            address participant = participants[it];
            idoToken.transfer(participant, participantTokens[participant]);
        }

        status = Status.CANCELED;
    }
}
