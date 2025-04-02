// SPDX-License-Identifier: GPL-3.0-only
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.22;

import {KYC} from "./KYC.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

enum Status {
    INITIALIZED, ACTIVE, FREEZED, FINISHED, CANCELED
}

abstract contract IDO is Ownable {

    uint256 public immutable softCap;
    uint256 public immutable hardCap;
    uint256 public immutable finishTimestamp;
    uint256 public immutable unfreezeTimestamp;
    uint256 public immutable poolMintAmount;
    uint256 public immutable shareMintAmount;
    uint256 public totalAmount = 0;
    IERC20 public immutable idoToken;
    IERC20 public immutable targetToken;
    KYC public immutable kyc;
    Status public status = Status.INITIALIZED;

    mapping (address => uint256) public participantTokens;
    address[] public participants;

    uint8 public immutable rewardPercent;

    constructor(
        uint256 _softCap, 
        uint256 _hardCap,
        uint256 _finishTimestamp,
        uint256 _unfreezeTimestamp,
        uint256 _poolMintAmount,
        uint256 _shareMintAmount,
        address _idoToken,
        address _targetToken,
        address _kyc,
        address _owner,
        uint8 _rewardPercent
    ) Ownable(_owner) {
        require(_softCap < _hardCap);
        require(_finishTimestamp > block.timestamp);
        require(_unfreezeTimestamp > block.timestamp);
        require(_idoToken != address(0));
        require(_targetToken != address(0));
        require(_kyc != address(0));
        require(_rewardPercent < 100);

        softCap = _softCap;
        hardCap = _hardCap;
        finishTimestamp = _finishTimestamp;
        unfreezeTimestamp = _unfreezeTimestamp;
        poolMintAmount = _poolMintAmount;
        shareMintAmount = _shareMintAmount;
        idoToken = IERC20(_idoToken);
        targetToken = IERC20(_targetToken);
        kyc = KYC(_kyc);
        rewardPercent = _rewardPercent;
    }

    function initialize() external {
        require(status == Status.INITIALIZED, "IDO is already active");

        uint256 balance = targetToken.balanceOf(address(this));
        require(balance >= poolMintAmount + shareMintAmount, "Send tokens to contract");
        status = Status.ACTIVE;
    }

    function participate(uint256 tokenAmount) external {
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
        require(status == Status.ACTIVE, "IDO is not active");

        if (totalAmount < softCap && finishTimestamp < block.timestamp) {
            cancel();
        } else if (totalAmount >= softCap && finishTimestamp < block.timestamp) {
            status = Status.FREEZED;
        } else if (totalAmount > hardCap) {
            status = Status.FREEZED;
        }
    }


    function generateTargetTokens() external {
        require(status == Status.FREEZED, "Tokens are not freezed");
        require(unfreezeTimestamp <= block.timestamp);

        status = Status.FINISHED;
        uint256 share = 0;
        uint256 totalShare = 0;

        for (uint it = 0; it < participants.length; it++) {
            address participant = participants[it];
            share = shareMintAmount * participantTokens[participant] / totalAmount;
            totalShare += share;
            targetToken.transfer(participant, share);
        }

        uint256 finalLiquidity = poolMintAmount + (shareMintAmount - totalShare);
        addLiquidity(finalLiquidity);

        uint256 reward = totalAmount * rewardPercent / 100;
        idoToken.transfer(owner(), reward);
    }

    function cancel() public {
        require(status == Status.ACTIVE || status == Status.INITIALIZED, "Wrong status");

        for (uint it = 0; it < participants.length; it++) {
            address participant = participants[it];
            idoToken.transfer(participant, participantTokens[participant]);
        }

        status = Status.CANCELED;
    }

    function addLiquidity(uint256 liquidity) internal virtual;
}
