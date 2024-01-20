// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

interface IUniswapV3MintCallback {
    function uniswapV3MintCallback(uint256 amount1, uint256 amount2, bytes calldata data) external;
}
