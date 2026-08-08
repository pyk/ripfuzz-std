// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import {Harness} from "ripfuzz/Harness.sol";

/// @title Counter
///
/// @dev Minimal counter used by the README harness example.
contract Counter {
    uint256 public count;
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    /// @dev Increment `count` by one. Caller must be `owner`.
    function increment() external {
        require(msg.sender == owner, "not owner");
        count += 1;
    }

    /// @dev Add `x` to `count`. Caller must be `owner`.
    /// @param x The amount to add.
    function add(uint256 x) external {
        require(msg.sender == owner, "not owner");
        count += x;
    }
}

/// @title CounterHarness
///
/// @dev README example harness. Kept under `examples/` and run by `make test`
///      so the public example stays working as the API evolves.
contract CounterHarness is Harness {
    Counter counter;

    /// @dev Register a single actor, fund it, and deploy a counter it owns.
    function setup() external {
        addActor("user");
        address user = getActor(0);
        rvm.deal(user, 100 ether);

        // Deploy as `user` so that user owns the counter.
        rvm.prank(user);
        counter = new Counter();
    }

    /// @dev Call `counter.increment` as a fuzz-selected actor.
    /// @param actorId Fuzzed actor index, wrapped over the actor pool.
    function increment(uint256 actorId) external useActor(actorId) {
        counter.increment();
    }

    /// @dev Call `counter.add` as a fuzz-selected actor with a bounded input.
    /// @param actorId Fuzzed actor index, wrapped over the actor pool.
    /// @param x Unbounded fuzz input, clamped to `[1, 100]`.
    function add(uint256 actorId, uint256 x) external useActor(actorId) {
        x = bound(x, 1, 100);
        counter.add(x);
    }

    /// @dev Invariant: `owner` remains the funded actor from `setup`.
    function invariant_OwnerIsUser() external {
        eq(counter.owner(), getActor(0), "owner is user");
    }

    /// @dev Invariant: `count` stays below a generous upper bound for default
    ///      ripfuzz call sequence limits with `bound(x, 1, 100)`.
    function invariant_CountStaysBounded() external {
        ensure(counter.count() < 1_000_000, "count stayed below 1_000_000");
    }
}
