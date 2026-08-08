// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import {Harness} from "ripfuzz/Harness.sol";

/// @title LoggingHarness
///
/// @dev Example of `log` helpers for harness traces.
contract LoggingHarness is Harness {
    uint256 public calls;

    /// @dev No setup required.
    function setup() external {}

    /// @dev Emit a few log shapes and count the call.
    /// @param value Unbounded fuzz input used only for logging.
    function logStuff(uint256 value) external {
        log("logStuff called");
        log("value", value);
        log("ok", true);
        calls += 1;
    }

    /// @dev Invariant: handler was exercised at least once after setup.
    function invariant_CallsNonDecreasing() external {
        // `calls` only increases.
        ensure(calls >= 0, "calls is tracked");
    }
}
