// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import {Harness} from "ripfuzz/Harness.sol";

/// @title BoundHarness
///
/// @dev Example of clamping fuzz inputs with `bound`.
contract BoundHarness is Harness {
    uint256 public last;

    /// @dev No setup required.
    function setup() external {}

    /// @dev Bound `x` into `[10, 20]` and store it.
    /// @param x Unbounded fuzz input.
    function setBounded(uint256 x) external {
        last = bound(x, 10, 20);
    }

    /// @dev Invariant: stored value always stays inside the bound range.
    function invariant_LastIsBounded() external {
        ensure(last == 0 || (last >= 10 && last <= 20), "last is unset or bounded");
    }
}
