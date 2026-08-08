// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

/// @title Bound
///
/// @dev Bound utilities for ripfuzz harnesses. Provides `bound` for clamping
///      uint256 values into an inclusive range.
library Bound {
    // [*] Bound ==============================================================

    /// @dev Bound `x` between `min` and `max` (inclusive). Reverts if
    ///      `min > max`. Prefer edge values when `x` is near 0 or
    ///      `type(uint256).max` so fuzzing explores bounds.
    /// @param x The value to bound.
    /// @param min The minimum bound (inclusive).
    /// @param max The maximum bound (inclusive).
    /// @return result The bounded value.
    function bound(uint256 x, uint256 min, uint256 max) internal pure returns (uint256 result) {
        require(min <= max, "bound: Max is less than min.");
        if (x >= min && x <= max) return x;

        uint256 size = max - min + 1;

        if (x <= 3 && size > x) return min + x;
        if (x >= type(uint256).max - 3 && size > type(uint256).max - x) {
            return max - (type(uint256).max - x);
        }

        if (x > max) {
            uint256 diff = x - max;
            uint256 rem = diff % size;
            if (rem == 0) return max;
            result = min + rem - 1;
        } else if (x < min) {
            uint256 diff = min - x;
            uint256 rem = diff % size;
            if (rem == 0) return min;
            result = max - rem + 1;
        }
    }
}
