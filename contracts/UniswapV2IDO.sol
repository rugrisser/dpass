// SPDX-License-Identifier: GPL-3.0-only
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.22;

import {IDO} from "./IDO.sol";
import {IUniswapV2Router02} from "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";

contract UniswapV2IDO is IDO {

    IUniswapV2Router02 private immutable uniswapRouter;

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
        address _uniswapRouter,
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
        require(_uniswapRouter != address(0));
        uniswapRouter = IUniswapV2Router02(_uniswapRouter);
    }

    function addLiquidity(uint256 liquidity) internal override {
        // uniswapRouter.addLiquidity(
        //     idoToken,
        //     targetToken,

        // );
    }
}
