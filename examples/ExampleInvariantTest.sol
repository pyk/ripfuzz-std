// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import {InvariantTest} from "ripfuzz/std.sol";

/// @title ExampleInvariantTest
///
/// @dev Example of invariant handles reported via `rvm.bail` with stable ids.
///
///      Run with:
///
///      ripfuzz test examples/ExampleInvariantTest.sol
///
///      A campaign reports two broken invariants. The trace saved under
///      `.ripfuzz/traces` shows the failing check under `Logs:`:
///
///      Logs:
///        INV-01: counter must stay even
///          a: 1
///          b: 0
contract ExampleInvariantTest is InvariantTest {
    // [*] Invariants ==========================================================

    /// @dev Counter parity must hold after every sequence.
    Invariant internal invEven = createInvariant("INV-01", "counter must stay even");

    /// @dev Handler-level guard on `counter`.
    Invariant internal invSmall = createInvariant("INV-02", "counter must stay small");

    uint256 public counter;

    // [*] Handlers ============================================================

    /// @dev Add `x` to `counter` as an even amount.
    /// @param x The amount to add.
    function addEven(uint256 x) external {
        x = bound(x, 0, 5) * 2;
        counter += x;
        gt(counter, 100, invSmall);
    }

    /// @dev Add `x` to `counter` as any amount.
    /// @param x The amount to add.
    function addAny(uint256 x) external {
        x = bound(x, 0, 5);
        counter += x;
    }

    // [*] Invariant functions =================================================

    /// @dev Invariant: `counter` stays even.
    function invariant_CounterEven() external {
        eq(counter % 2, 0, invEven);
    }
}
