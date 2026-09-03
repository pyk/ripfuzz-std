// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import {InvariantTest} from "ripfuzz/std.sol";

/// @title Counter
///
/// @dev Example target contract mutated by the harness handlers.
contract Counter {
    // [*] State ===============================================================

    /// @dev The current count.
    uint256 public count;

    /// @dev The account that deployed the counter.
    address public owner;

    // [*] Constructor =========================================================

    /// @dev Deploy the counter owned by `msg.sender`.
    constructor() {
        owner = msg.sender;
    }

    // [*] Handlers ============================================================

    /// @dev Add `x` to `count`.
    /// @param x The amount to add.
    function add(uint256 x) external {
        count += x;
    }
}

/// @title ExampleInvariantTest
///
/// @dev Example of end-to-end invariant testing with invariant handles
///      reported via `BrokenInvariantError` with stable ids.
///
///      Run with:
///
///      ripfuzz test examples/ExampleInvariantTest.sol
///
///      A campaign reports one broken invariant. The trace saved under
///      `.ripfuzz/traces` shows the failing check under `Logs:`:
///
///      Logs:
///        INV-02: count must stay small
///          a: 101
///          b: 100
contract ExampleInvariantTest is InvariantTest {
    // [*] Invariants ==========================================================

    /// @dev Owner must never change after deployment.
    Invariant internal invOwner = createInvariant("INV-01", "owner never changes");

    /// @dev Count must stay small after every sequence.
    Invariant internal invSmall = createInvariant("INV-02", "count must stay small");

    // [*] State ===============================================================

    /// @dev The contract under test.
    Counter internal counter;

    // [*] Setup ===============================================================

    /// @dev Deploy the counter owned by a labeled actor.
    function setup() external {
        addActor("user");
        address user = getActor(0);
        rvm.prank(user);
        counter = new Counter();
    }

    // [*] Handlers ============================================================

    /// @dev Add a bounded amount to `count` as a fuzz-selected actor.
    /// @param actorId The fuzzed actor index.
    /// @param x The amount to add.
    function add(uint256 actorId, uint256 x) external useActor(actorId) {
        x = bound(x, 1, 10);
        counter.add(x);
    }

    // [*] Invariant functions =================================================

    /// @dev Invariant: `owner` never changes.
    function invariant_OwnerNeverChanges() external {
        eq(counter.owner(), getActor(0), invOwner);
    }

    /// @dev Invariant: `count` stays small.
    function invariant_CountStaysSmall() external {
        lt(counter.count(), 100, invSmall);
    }
}
