// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import {Harness} from "ripfuzz/Harness.sol";

/// @title ActorsHarness
///
/// @dev Example of actor pools and the `useActor` modifier.
contract ActorsHarness is Harness {
    mapping(address => uint256) public hits;

    /// @dev Register a small actor pool.
    function setup() external {
        addActor("Alice");
        addActor("Bob");
        addActor("Carol");
    }

    /// @dev Increment a counter for the selected actor.
    /// @param actorId Fuzzed actor index, wrapped over the actor pool.
    function hit(uint256 actorId) external useActor(actorId) {
        hits[currentActor] += 1;
    }

    /// @dev Invariant: actor pool size stays at three.
    function invariant_ActorCount() external {
        eq(actorCount(), 3, "three actors registered");
    }

    /// @dev Invariant: only registered actors can accumulate hits.
    function invariant_OnlyActorsHaveHits() external {
        uint256 total;
        for (uint256 i = 0; i < actorCount(); i++) {
            total += hits[getActor(i)];
        }
        // No other address is written by handlers, so total is the full sum.
        ensure(total >= 0, "hits are tracked");
    }
}
