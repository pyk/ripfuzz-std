// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import {Assertions} from "./Assertions.sol";
import {Bound} from "./libraries/Bound.sol";
import {RVM} from "./RVM.sol";

/// @title Ripfuzz Harness
///
/// @dev Base contract for ripfuzz harnesses.
abstract contract Harness is Assertions {
    // [*] RVM ================================================================

    address internal constant RVM_ADDRESS = address(uint160(uint256(keccak256("ripfuzz cheatcode"))));

    RVM internal constant rvm = RVM(RVM_ADDRESS);

    // [*] Bound ==============================================================

    /// @dev Bound `x` between `min` and `max` (inclusive).
    /// @param x The value to bound.
    /// @param min The minimum bound (inclusive).
    /// @param max The maximum bound (inclusive).
    /// @return The bounded value.
    function bound(uint256 x, uint256 min, uint256 max) internal pure returns (uint256) {
        return Bound.bound(x, min, max);
    }
}
