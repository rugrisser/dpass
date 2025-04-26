// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.22;

import {KYC} from "./KYC.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

interface ICelerMessageBusSender {
    function sendMessage(
        address _receiver,
        uint256 _dstChainId,
        bytes calldata _message
    ) external payable;

    function calcFee(bytes calldata _message) external view returns (uint256);
}

interface ICelerReceiver {
    enum ExecutionStatus {
        Fail,
        Success,
        Retry
    }

    function executeMessage(
        address _sender,
        uint64 _srcChainId,
        bytes calldata _message,
        address _executor
    ) external payable returns (ExecutionStatus);
}

contract BridgeFacade is Ownable, ICelerReceiver {

    KYC kycContract;
    address messageBus;
    ICelerMessageBusSender sender;

    mapping (uint256 => address) public destinationAddresses;

    constructor(
        address _kycContract,
        address _messageBus,
        address _owner
    ) Ownable(_owner) {
        require(_kycContract != address(0));
        require(_messageBus != address(0));

        kycContract = KYC(kycContract);
        messageBus = _messageBus;
        sender = ICelerMessageBusSender(_messageBus);
    }

    function assignDestinationToChainId(uint256 chainId, address destination) external onlyOwner {
        require(chainId != block.chainid);
        destinationAddresses[chainId] = destination;
    }

    function calcTransferFee() external view returns (uint256) {
        bytes memory payload = abi.encode(type(uint256).max, type(uint256).max);
        return sender.calcFee(payload);
    }

    function transferVerification(uint256 chainId, address verifiedAddress) external payable {
        require(chainId != block.chainid);

        address destination = destinationAddresses[chainId];
        require(destination != address(0));

        uint256 expiration = kycContract.validUntil(verifiedAddress);
        require(expiration != 0);

        bytes memory payload = abi.encode(verifiedAddress, expiration);

        uint256 fee = sender.calcFee(payload);
        sender.sendMessage{value: fee}(destination, chainId, payload);
    }

    function executeMessage(
        address _sender,
        uint64 _srcChainId,
        bytes calldata _message,
        address _executor
    ) external payable returns (ExecutionStatus) {
        if (msg.sender != messageBus) {
            return ExecutionStatus.Fail;
        }

        return ExecutionStatus.Success;
    }
}
