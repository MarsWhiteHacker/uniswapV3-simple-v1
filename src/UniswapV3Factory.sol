// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "./interfaces/IUniswapV3PoolDeployer.sol";
import "./UniswapV3Pool.sol";

contract UniswapV3Factory is IUniswapV3PoolDeployer {
    error PoolAlreadyExists();
    error TokenXCannotBeZero();
    error TokensMustBeDifferent();
    error UnsupportedTickSpacing();

    PoolParameters public parameters;

    mapping(uint24 => uint24) public fees;
    mapping(address => mapping(address => mapping(uint24 => address))) public pools;

    event PoolCreated(address tokenX, address tokenY, uint24 tickSpacing, address pool);

    constructor() {
        fees[500] = 10;
        fees[3000] = 60;
    }

    function createPool(address tokenX, address tokenY, uint24 fee) public returns (address pool) {
        if (tokenX == tokenY) revert TokensMustBeDifferent();
        if (fees[fee] == 0) revert UnsupportedTickSpacing();

        (tokenX, tokenY) = tokenX < tokenY ? (tokenX, tokenY) : (tokenY, tokenX);

        if (tokenX == address(0)) revert TokenXCannotBeZero();
        if (pools[tokenX][tokenY][fees[fee]] != address(0)) {
            revert PoolAlreadyExists();
        }

        parameters =
            PoolParameters({factory: address(this), token0: tokenX, token1: tokenY, tickSpacing: fees[fee], fee: fee});

        pool = address(
            new UniswapV3Pool{
                salt: keccak256(abi.encodePacked(tokenX, tokenY, fees[fee]))
            }()
        );

        delete parameters;

        pools[tokenX][tokenY][fees[fee]] = pool;
        pools[tokenY][tokenX][fees[fee]] = pool;

        emit PoolCreated(tokenX, tokenY, fees[fee], pool);
    }
}
