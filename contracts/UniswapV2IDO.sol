// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.22;

import {IDO} from "./IDO.sol";
import {TransferHelper} from '@uniswap/lib/contracts/libraries/TransferHelper.sol';
import {IUniswapV2Pair} from '@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol';

contract UniswapV2IDO is IDO {

    IUniswapV2Pair private immutable uniswapPair;

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
        address _uniswapPair,
        uint8 _rewardPercent
    ) IDO(
        _softCap, 
        _hardCap,
        _finishTimestamp,
        _unfreezeTimestamp,
        _poolMintAmount,
        _shareMintAmount,
        _idoToken,
        _targetToken,
        _kyc,
        _owner,
        _rewardPercent
    ) {
        require(_uniswapPair != address(0));
        uniswapPair = IUniswapV2Pair(_uniswapPair);
    }

    function addLiquidity(uint256 idoLiquidity, uint256 targetLiquidity) internal override {
        TransferHelper.safeTransfer(address(idoToken), address(uniswapPair), idoLiquidity);
        TransferHelper.safeTransfer(address(targetToken), address(uniswapPair), targetLiquidity);
        uniswapPair.mint(owner());
    }
}