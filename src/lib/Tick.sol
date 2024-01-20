// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

library Tick {
    struct Info {
        bool initialized;
        // total liquidity at tick
        uint128 liquidityGross;
        // amount of liquidity added or subtracted when tick is crossed
        int128 liquidityNet;
    }

    function update(mapping(int24 => Tick.Info) storage self, int24 tick, uint128 liquidityDelta, bool upper)
        internal
        returns (bool flipped)
    {
        Tick.Info storage tickInfo = self[tick];
        uint128 liquidityBefore = tickInfo.liquidityGross;
        uint128 liquidityAfter = liquidityBefore + liquidityDelta;

        if (liquidityBefore == 0) {
            tickInfo.initialized = true;
        }

        tickInfo.liquidityGross = liquidityAfter;

        flipped = (liquidityAfter == 0) != (liquidityBefore == 0);

        tickInfo.liquidityNet = upper
            ? int128(int256(tickInfo.liquidityNet) - int256(uint256(liquidityDelta)))
            : int128(int256(tickInfo.liquidityNet) + int256(uint256(liquidityDelta)));
    }

    function cross(mapping(int24 => Tick.Info) storage self, int24 tick)
        internal
        view
        returns (int128 liquidityDelta)
    {
        Tick.Info storage info = self[tick];
        liquidityDelta = info.liquidityNet;
    }
}
