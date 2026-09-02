// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import {Harness} from "./Harness.sol";
import {Logger} from "./Logger.sol";
import {RVM} from "./RVM.sol";

/// @title InvariantTest
///
/// @dev Base contract for ripfuzz invariant tests. Provides invariant handles
///      created via `createInvariant` and checks that report a broken
///      invariant through `rvm.bail` instead of an assert panic.
abstract contract InvariantTest is Harness, Logger {
    // [*] Invariant ===========================================================

    /// @dev Identifies a broken invariant reported via `bail`.
    ///
    /// @dev Mirrors `RVM.Invariant` because Solidity cannot alias struct
    ///      types, and a nested type is inherited into harness scope.
    struct Invariant {
        /// @dev Stable invariant identifier such as `INV-01`. Must not be
        ///      empty.
        string id;
        /// @dev Human-readable description of the broken invariant.
        string description;
    }

    /// @dev Create an invariant handle with `id` and `description`.
    /// @param id The stable invariant identifier.
    /// @param description The human-readable invariant description.
    /// @return The invariant handle.
    function createInvariant(string memory id, string memory description) internal pure returns (Invariant memory) {
        return Invariant(id, description);
    }

    // [*] Checks ==============================================================

    /// @dev Report a broken invariant when `condition` does not hold.
    /// @param condition The condition that must hold.
    /// @param inv The invariant reported when the check fails.
    function ensure(bool condition, Invariant memory inv) internal {
        if (!condition) {
            fail(inv);
        }
    }

    /// @dev Assert that two `uint256` values are equal.
    /// @param a The first value.
    /// @param b The second value.
    /// @param inv The invariant reported when the check fails.
    function eq(uint256 a, uint256 b, Invariant memory inv) internal {
        if (a != b) {
            fail(inv, a, b);
        }
    }

    /// @dev Assert that two `int256` values are equal.
    /// @param a The first value.
    /// @param b The second value.
    /// @param inv The invariant reported when the check fails.
    function eq(int256 a, int256 b, Invariant memory inv) internal {
        if (a != b) {
            fail(inv, a, b);
        }
    }

    /// @dev Assert that two `address` values are equal.
    /// @param a The first value.
    /// @param b The second value.
    /// @param inv The invariant reported when the check fails.
    function eq(address a, address b, Invariant memory inv) internal {
        if (a != b) {
            fail(inv, a, b);
        }
    }

    /// @dev Assert that two `bool` values are equal.
    /// @param a The first value.
    /// @param b The second value.
    /// @param inv The invariant reported when the check fails.
    function eq(bool a, bool b, Invariant memory inv) internal {
        if (a != b) {
            fail(inv, a, b);
        }
    }

    /// @dev Assert that two `bytes32` values are equal.
    /// @param a The first value.
    /// @param b The second value.
    /// @param inv The invariant reported when the check fails.
    function eq(bytes32 a, bytes32 b, Invariant memory inv) internal {
        if (a != b) {
            fail(inv, a, b);
        }
    }

    /// @dev Assert that two `uint256` values are not equal.
    /// @param a The first value.
    /// @param b The second value.
    /// @param inv The invariant reported when the check fails.
    function neq(uint256 a, uint256 b, Invariant memory inv) internal {
        if (a == b) {
            fail(inv, a, b);
        }
    }

    /// @dev Assert that two `int256` values are not equal.
    /// @param a The first value.
    /// @param b The second value.
    /// @param inv The invariant reported when the check fails.
    function neq(int256 a, int256 b, Invariant memory inv) internal {
        if (a == b) {
            fail(inv, a, b);
        }
    }

    /// @dev Assert that two `address` values are not equal.
    /// @param a The first value.
    /// @param b The second value.
    /// @param inv The invariant reported when the check fails.
    function neq(address a, address b, Invariant memory inv) internal {
        if (a == b) {
            fail(inv, a, b);
        }
    }

    /// @dev Assert that two `bool` values are not equal.
    /// @param a The first value.
    /// @param b The second value.
    /// @param inv The invariant reported when the check fails.
    function neq(bool a, bool b, Invariant memory inv) internal {
        if (a == b) {
            fail(inv, a, b);
        }
    }

    /// @dev Assert that two `bytes32` values are not equal.
    /// @param a The first value.
    /// @param b The second value.
    /// @param inv The invariant reported when the check fails.
    function neq(bytes32 a, bytes32 b, Invariant memory inv) internal {
        if (a == b) {
            fail(inv, a, b);
        }
    }

    /// @dev Assert that `a` is greater than `b`.
    /// @param a The value that must be greater.
    /// @param b The value to compare against.
    /// @param inv The invariant reported when the check fails.
    function gt(uint256 a, uint256 b, Invariant memory inv) internal {
        if (a <= b) {
            fail(inv, a, b);
        }
    }

    /// @dev Assert that `a` is greater than or equal to `b`.
    /// @param a The value that must be greater or equal.
    /// @param b The value to compare against.
    /// @param inv The invariant reported when the check fails.
    function gte(uint256 a, uint256 b, Invariant memory inv) internal {
        if (a < b) {
            fail(inv, a, b);
        }
    }

    /// @dev Assert that `a` is less than `b`.
    /// @param a The value that must be less.
    /// @param b The value to compare against.
    /// @param inv The invariant reported when the check fails.
    function lt(uint256 a, uint256 b, Invariant memory inv) internal {
        if (a >= b) {
            fail(inv, a, b);
        }
    }

    /// @dev Assert that `a` is less than or equal to `b`.
    /// @param a The value that must be less or equal.
    /// @param b The value to compare against.
    /// @param inv The invariant reported when the check fails.
    function lte(uint256 a, uint256 b, Invariant memory inv) internal {
        if (a > b) {
            fail(inv, a, b);
        }
    }

    /// @dev Assert that `a` is greater than `b`.
    /// @param a The value that must be greater.
    /// @param b The value to compare against.
    /// @param inv The invariant reported when the check fails.
    function gt(int256 a, int256 b, Invariant memory inv) internal {
        if (a <= b) {
            fail(inv, a, b);
        }
    }

    /// @dev Assert that `a` is greater than or equal to `b`.
    /// @param a The value that must be greater or equal.
    /// @param b The value to compare against.
    /// @param inv The invariant reported when the check fails.
    function gte(int256 a, int256 b, Invariant memory inv) internal {
        if (a < b) {
            fail(inv, a, b);
        }
    }

    /// @dev Assert that `a` is less than `b`.
    /// @param a The value that must be less.
    /// @param b The value to compare against.
    /// @param inv The invariant reported when the check fails.
    function lt(int256 a, int256 b, Invariant memory inv) internal {
        if (a >= b) {
            fail(inv, a, b);
        }
    }

    /// @dev Assert that `a` is less than or equal to `b`.
    /// @param a The value that must be less or equal.
    /// @param b The value to compare against.
    /// @param inv The invariant reported when the check fails.
    function lte(int256 a, int256 b, Invariant memory inv) internal {
        if (a > b) {
            fail(inv, a, b);
        }
    }

    // [*] Bail ================================================================

    /// @dev Report `inv` as broken and revert the active call.
    /// @param inv The broken invariant.
    function bail(Invariant memory inv) internal {
        rvm.bail(RVM.Invariant({id: inv.id, description: inv.description}));
    }

    /// @dev Log a failed check for `inv`, then bail.
    /// @param inv The broken invariant.
    function fail(Invariant memory inv) private {
        log(_describe(inv));
        bail(inv);
    }

    /// @dev Log a failed check for `inv` with observed values, then bail.
    /// @param inv The broken invariant.
    /// @param a The first observed value.
    /// @param b The second observed value.
    function fail(Invariant memory inv, uint256 a, uint256 b) private {
        log(_describe(inv));
        log("  a: ", a);
        log("  b: ", b);
        bail(inv);
    }

    /// @dev Log a failed check for `inv` with observed values, then bail.
    /// @param inv The broken invariant.
    /// @param a The first observed value.
    /// @param b The second observed value.
    function fail(Invariant memory inv, int256 a, int256 b) private {
        log(_describe(inv));
        log(string(abi.encodePacked("  a: ", rvm.toString(a))));
        log(string(abi.encodePacked("  b: ", rvm.toString(b))));
        bail(inv);
    }

    /// @dev Log a failed check for `inv` with observed values, then bail.
    /// @param inv The broken invariant.
    /// @param a The first observed value.
    /// @param b The second observed value.
    function fail(Invariant memory inv, address a, address b) private {
        log(_describe(inv));
        log("  a: ", a);
        log("  b: ", b);
        bail(inv);
    }

    /// @dev Log a failed check for `inv` with observed values, then bail.
    /// @param inv The broken invariant.
    /// @param a The first observed value.
    /// @param b The second observed value.
    function fail(Invariant memory inv, bool a, bool b) private {
        log(_describe(inv));
        log("  a: ", a);
        log("  b: ", b);
        bail(inv);
    }

    /// @dev Log a failed check for `inv` with observed values, then bail.
    /// @param inv The broken invariant.
    /// @param a The first observed value.
    /// @param b The second observed value.
    function fail(Invariant memory inv, bytes32 a, bytes32 b) private {
        log(_describe(inv));
        log("  a: ", abi.encodePacked(a));
        log("  b: ", abi.encodePacked(b));
        bail(inv);
    }

    /// @dev Describe `inv` as `id: description`.
    /// @param inv The invariant to describe.
    /// @return The composed description.
    function _describe(Invariant memory inv) private pure returns (string memory) {
        return string(abi.encodePacked(inv.id, ": ", inv.description));
    }
}
