// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import {Harness} from "ripfuzz/std.sol";

/// @title Accumulator
///
/// @dev Example target contract whose pending reward can grow unbounded.
contract Accumulator {
    // [*] State ==============================================================

    /// @dev Pending reward per account.
    mapping(address => uint256) public pending;

    // [*] Handlers ===========================================================

    /// @dev Add `value` to the caller's pending reward.
    /// @param value The amount to accrue.
    function accrue(uint256 value) external {
        pending[msg.sender] += value;
    }

    /// @dev Claim the caller's pending reward and reset it.
    /// @return The claimed amount.
    function claim() external returns (uint256) {
        uint256 claimed = pending[msg.sender];
        pending[msg.sender] = 0;
        return claimed;
    }
}

/// @title ExampleMax
///
/// @dev Example of max mode with a `value()` function measuring the highest
///      pending reward a single sequence of calls can accrue.
///
///      Run with:
///
///      ripfuzz max examples/ExampleMax.sol
///
///      The campaign maximizes `value()` and saves the shortest sequence
///      that produced it under `.ripfuzz/traces`.
contract ExampleMax is Harness {
    // [*] State ==============================================================

    /// @dev The contract under test.
    Accumulator internal accumulator;

    /// @dev Registered users measured by `value`.
    address[] internal users;

    // [*] Setup ==============================================================

    /// @dev Deploy the accumulator and register two users.
    function setup() external {
        accumulator = new Accumulator();
        addActor("alice");
        addActor("bob");
        users.push(getActor(0));
        users.push(getActor(1));
    }

    // [*] Handlers ===========================================================

    /// @dev Accrue a bounded reward as a fuzz-selected user.
    /// @param actorId The fuzzed user index.
    /// @param x The amount to accrue.
    function accrue(uint256 actorId, uint256 x) external useActor(actorId) {
        x = bound(x, 1, 10);
        accumulator.accrue(x);
    }

    /// @dev Claim the pending reward as a fuzz-selected user.
    /// @param actorId The fuzzed user index.
    function claim(uint256 actorId) external useActor(actorId) {
        accumulator.claim();
    }

    // [*] Value ==============================================================

    /// @dev Return the highest pending reward reachable in one sequence.
    /// @return The maximum pending reward across the registered users.
    function value() external view returns (uint256) {
        uint256 highest;
        for (uint256 i = 0; i < users.length; i++) {
            highest = _max(highest, accumulator.pending(users[i]));
        }
        return highest;
    }

    /// @dev Return the larger of `a` and `b`.
    /// @param a The first value.
    /// @param b The second value.
    /// @return The larger value.
    function _max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a : b;
    }
}
