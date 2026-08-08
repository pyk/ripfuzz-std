// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import {Harness} from "ripfuzz/Harness.sol";

/// @title AssertionsHarness
///
/// @dev Example of assertion helpers that fail a campaign with logs.
contract AssertionsHarness is Harness {
    uint256 public value;
    address public who;
    bool public flag;

    /// @dev Seed known values used by invariants.
    function setup() external {
        value = 42;
        who = createAddress("who");
        flag = true;
    }

    /// @dev Keep `value` fixed while still accepting fuzz traffic.
    /// @param ignored Unused fuzz input.
    function touch(uint256 ignored) external {
        ignored = bound(ignored, 0, 1);
        value = 42;
        flag = true;
    }

    /// @dev Invariant: `ensure` and `eq` hold for seeded state.
    function invariant_AssertionsHold() external {
        ensure(flag, "flag stays true");
        eq(value, 42, "value stays 42");
        neq(who, address(0), "who is set");
        eq(who, createAddress("who"), "who is stable");
    }
}
